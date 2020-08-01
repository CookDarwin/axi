/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2016/10/12
madified:
***********************************************/
`timescale 1ns / 1ps
module axi4_to_native_for_ddr_ip #(
    parameter ADDR_WIDTH            = 27,
    parameter DATA_WIDTH            = 256
)(
    axi_inf.slaver                  axi_inf,
    output logic[ADDR_WIDTH-1:0]    app_addr,
    output logic[2:0]               app_cmd,
    output logic                    app_en,
    output logic[DATA_WIDTH-1:0]    app_wdf_data,
    output logic                    app_wdf_end,
    output logic[DATA_WIDTH/8-1:0]  app_wdf_mask,
    output logic                    app_wdf_wren,
    input  [DATA_WIDTH-1:0]         app_rd_data,
    input                           app_rd_data_end,
    input                           app_rd_data_valid,
    input                           app_rdy,
    input                           app_wdf_rdy,
    input                           init_calib_complete
);

logic clock,rst;

assign clock = axi_inf.axi_aclk;
assign rst   = !axi_inf.axi_aresetn;
//assign rst  =   !axi_inf.axi_aresetn ||  axi_inf.axi_wevld || axi_inf.axi_revld;
typedef enum {
        NOP=0,
        WIDLE=1,
        RIDLE=2,
        EXEC_WR=3,
        WR_CMD_E=4,
        WR_FIFO_E=5,
        WR_END=6,
        EXEC_RD=7,
        RD_FIFO_E=8,
        RD_END=9,
        RD_AXI_E=10,
        APP_CMD_E=11,
        CLEAR_WR_FIFO=12
        } MASTER_STATE;

MASTER_STATE mnstate,mcstate;

always@(posedge clock,posedge rst)begin
    if(rst)     mcstate <= NOP;
    // else if(axi_inf.axi_wevld ||��?axi_inf.axi_revld)
    //             mcstate <= NOP;
    else        mcstate <= mnstate;
end

logic   wr_fifo_empty;
// (* dont_touch = "true" *)
// logic           app_en_last;
(* dont_touch = "true" *)
logic           app_en_wr_last;
(* dont_touch = "true" *)
logic           app_en_rd_last;
logic [8:0]     app_len;
logic [8:0]     app_wr_len;
logic [8:0]     app_rd_len;
logic [9:0]     wdf_cnt;
(* dont_touch = "true" *)
logic           wdf_last;

always@(*)
    case(mcstate)
    NOP:
        if(init_calib_complete && app_rdy)
                mnstate = WIDLE;
        else    mnstate = NOP;
    WIDLE:
        if(axi_inf.axi_awvalid && axi_inf.axi_awready)
                mnstate = EXEC_WR;
        else    mnstate = RIDLE;
    RIDLE:
        if(axi_inf.axi_arvalid && axi_inf.axi_arready)
                mnstate = EXEC_RD;
        else    mnstate = WIDLE;
    EXEC_WR:
        // if(axi_inf.axi_wlast && axi_inf.axi_wvalid && axi_inf.axi_wready)
        // if(!wr_fifo_empty && axi_inf.axi_wvalid && axi_inf.axi_wready)
        if(!wr_fifo_empty)
                // mnstate = WR_FIFO_E;
                mnstate = WR_CMD_E;
        else    mnstate = EXEC_WR;
    WR_CMD_E:
        if(app_en_wr_last && app_rdy && app_en && wdf_last && app_wdf_wren && app_wdf_rdy)
                mnstate = WR_END;
        else if(app_en_wr_last && app_rdy && app_en)
        // if(app_en_last)
                mnstate = WR_FIFO_E;
        else if(wdf_last && app_wdf_wren && app_wdf_rdy)           //data burst first
                mnstate = APP_CMD_E;
        else    mnstate = WR_CMD_E;
    APP_CMD_E:
        if(app_en_wr_last && app_rdy && app_en)
                mnstate = WR_END;
        else    mnstate = APP_CMD_E;
    WR_FIFO_E:
        // if(wr_fifo_empty)
        if(wdf_last && app_wdf_wren && app_wdf_rdy)
        // if(app_en_last && wr_fifo_empty)
                mnstate = WR_END;
        else    mnstate = WR_FIFO_E;
    WR_END:
        if(axi_inf.axi_bready)begin
            if(wr_fifo_empty)
                    mnstate = RIDLE;
            else    mnstate = CLEAR_WR_FIFO;
        end else    mnstate = WR_END;
    EXEC_RD:
        if(app_en_rd_last && app_rdy && app_en)
                mnstate = RD_AXI_E;
        else    mnstate = EXEC_RD;
    RD_AXI_E:
        if(axi_inf.axi_rvalid && axi_inf.axi_rlast && axi_inf.axi_rready)
                mnstate = WIDLE;
        else    mnstate = RD_AXI_E;
    // EXEC_RD:
    //     // if(axi_inf.axi_rvalid && axi_inf.axi_rlast && axi_inf.axi_rready)
    //     if(app_en_last && app_rdy)
    //             mnstate = RD_FIFO_E;
    //     else    mnstate = EXEC_RD;
    // RD_FIFO_E:
    //     if(axi_inf.axi_rvalid && axi_inf.axi_rlast && axi_inf.axi_rready)
    //             mnstate = IDLE;
    //     else    mnstate = RD_FIFO_E;
    CLEAR_WR_FIFO:
        if(wr_fifo_empty)
                mnstate = RIDLE;
        else    mnstate = CLEAR_WR_FIFO;
    default:    mnstate = NOP;
    endcase

//--->> FORCE CLEAR FIFO <<------------------
logic   clear_wr_fifo_en;
always@(posedge clock,posedge rst)
    if(rst) clear_wr_fifo_en    <= 1'b0;
    else begin
        case(mnstate)
        CLEAR_WR_FIFO:
            clear_wr_fifo_en    <= 1'b1;
        default:
            clear_wr_fifo_en    <= 1'b0;
        endcase
    end
//---<< FORCE CLEAR FIFO >>------------------
logic   wr_enable,rd_enable;
logic   rd_app_enable;

always@(posedge clock,posedge rst)
    if(rst) wr_enable   <= 1'b0;
    else
        case(mnstate)
        // EXEC_WR,WR_CMD_E,WR_FIFO_E:
        WR_CMD_E,APP_CMD_E:
                    wr_enable   <= 1'b1;
        default:    wr_enable   <= 1'b0;
        endcase

always@(posedge clock,posedge rst)
    if(rst) rd_app_enable   <= 1'b0;
    else
        case(mnstate)
        EXEC_RD,RD_AXI_E:
                    rd_app_enable   <= 1'b1;
        default:    rd_app_enable   <= 1'b0;
        endcase

always@(posedge clock,posedge rst)
    if(rst) rd_enable   <= 1'b0;
    else
        case(mnstate)
        EXEC_RD:
                    rd_enable   <= 1'b1;
        default:    rd_enable   <= 1'b0;
        endcase
//--->> WR DDR DATA <<-------------------
logic   rd_fifo_full;
logic   rd_fifo_empty;
(* dont_touch = "true" *)
logic   rd_fifo_en;
// assign  rd_fifo_en  = (rd_enable && axi_inf.axi_rready) || wr_enable;
assign  rd_fifo_en  = (rd_app_enable && axi_inf.axi_rready && !rd_fifo_empty) ;
// assign  rd_fifo_en  = (rd_app_enable && axi_inf.axi_rready && !rd_fifo_empty) || wr_enable;
generate
if(DATA_WIDTH!=512)begin
FIFO_DDR_IP_BRG FIFO_DDR_IP_BRG_rd (
/*  input          */ .clk          (clock                  ),
/*  input          */ .rst          (rst                    ),
/*  input [255:0]  */ .din          (app_rd_data            ),
// /*  input          */ .wr_en        (app_rd_data_valid && !rd_fifo_full   ),
/*  input          */ .wr_en        (app_rd_data_valid      ),
/*  input          */ .rd_en        (/*rd_enable && axi_inf.axi_rready*/rd_fifo_en    ),
/*  output [255:0] */ .dout         (axi_inf.axi_rdata       ),
/*  output         */ .full         (rd_fifo_full            ),
/*  output         */ .empty        (rd_fifo_empty           )
);
end else begin
FIFO_DDR_IP_BRG_512 FIFO_DDR_IP_BRG_rd (
/*  input          */   .clk          (clock                  ),
/*  input          */   .srst         (rst                    ),
/*  input [511:0]  */   .din          (app_rd_data            ),
// /*  input          */   .wr_en        (app_rd_data_valid && !rd_fifo_full   ),
/*  input          */   .wr_en        (app_rd_data_valid      ),
/*  input          */   .rd_en        (/*rd_enable && axi_inf.axi_rready */rd_fifo_en    ),
/*  output [511:0] */   .dout         (axi_inf.axi_rdata       ),
/*  output         */   .full         (rd_fifo_full            ),
/*  output         */   .empty        (rd_fifo_empty           )
);
end
endgenerate

assign axi_inf.axi_rvalid = !rd_fifo_empty && rd_app_enable;
//---<< WR DDR DATA >>-------------------
//--->> RD DDR DATA <<-------------------
(* dont_touch = "true" *)
wire        wr_fifo_wen;
// assign      wr_fifo_wen  = wr_enable && axi_inf.axi_wvalid && axi_inf.axi_wready;
assign      wr_fifo_wen  = axi_inf.axi_wvalid && axi_inf.axi_wready;
(* dont_touch = "true" *)
wire        wr_fifo_ren;
// assign      wr_fifo_ren = (wr_enable && app_wdf_rdy) || rd_enable;
assign      wr_fifo_ren = (app_wdf_wren && app_wdf_rdy) || clear_wr_fifo_en;
// assign      wr_fifo_ren = (app_wdf_wren && app_wdf_rdy);
logic wr_fifo_full;
generate
if(DATA_WIDTH!=512)begin
FIFO_DDR_IP_BRG FIFO_DDR_IP_BRG_wr (
/*  input          */ .clk          (clock                  ),
/*  input          */ .rst          (rst                    ),
/*  input [255:0]  */ .din          (axi_inf.axi_wdata      ),
/*  input          */ .wr_en        (/*wr_enable && axi_inf.axi_wvalid && axi_inf.axi_wready*/wr_fifo_wen  ),
/*  input          */ .rd_en        (/*wr_enable && app_wdf_rdy*/ wr_fifo_ren  ),
/*  output [255:0] */ .dout         (app_wdf_data               ),
/*  output         */ .full         (wr_fifo_full               ),
/*  output         */ .empty        (wr_fifo_empty              )
);
end else begin
FIFO_DDR_IP_BRG_512 FIFO_DDR_IP_BRG_wr (
/*  input          */   .clk          (clock                  ),
/*  input          */   .srst         (rst                    ),
/*  input [511:0]  */   .din          (axi_inf.axi_wdata      ),
/*  input          */   .wr_en        (/*wr_enable && axi_inf.axi_wvalid && axi_inf.axi_wready*/ wr_fifo_wen ),
/*  input          */   .rd_en        (/*wr_enable && app_wdf_rdy*/ wr_fifo_ren  ),
/*  output [511:0] */   .dout         (app_wdf_data               ),
/*  output         */   .full         (wr_fifo_full               ),
/*  output         */   .empty        (wr_fifo_empty              )
);
end
endgenerate

// assign axi_inf.axi_wready = !wr_fifo_full && wr_enable;
// assign axi_inf.axi_wready =  wr_enable;
assign axi_inf.axi_wready =  !wr_fifo_full;
// assign app_wdf_wren       = !wr_fifo_empty;
assign app_wdf_mask       = {(DATA_WIDTH/8){1'b0}};
assign app_wdf_end        = 1'b1;

//---->> APP WRITE <<--------------------
always@(posedge clock,posedge rst)
    if(rst) wdf_cnt <= '0;
    else begin
        if(axi_inf.axi_awready)
                wdf_cnt <= '0;
        else if(wdf_last && app_wdf_wren && app_wdf_rdy)
                wdf_cnt <= '0;
        else if(app_wdf_wren && app_wdf_rdy)
                wdf_cnt <= wdf_cnt + 1'b1;
        else    wdf_cnt <= wdf_cnt;
    end

always@(posedge clock,posedge rst)
    if(rst) wdf_last    <= 1'b0;
    else begin
        if(axi_inf.axi_awvalid && axi_inf.axi_awready && axi_inf.axi_awlen==0)
                wdf_last    <= 1'b1;
        else if(wdf_last && app_wdf_wren && app_wdf_rdy)
                wdf_last    <= 1'b0;
        else if(app_wdf_wren && app_wdf_rdy && (wdf_cnt == app_wr_len-2))
                wdf_last    <= 1'b1;
        else    wdf_last    <= wdf_last;
    end


always@(posedge clock,posedge rst)
    if(rst) app_wdf_wren   <= 1'b0;
    else
        case(mnstate)
        WR_CMD_E,WR_FIFO_E:
                    app_wdf_wren   <= 1'b1;
        default:    app_wdf_wren   <= 1'b0;
        endcase
//----<< APP WRITE >>--------------------
//--->> RD DDR DATA <<-------------------
//--->> WR AXI CMD <<--------------------
// typedef enum {AWIDLE,AWRDY,AWEND} AWSTATE;
// AWSTATE awcstate,awnstate;
//
// always@(posedge clock,posedge rst)
//     if(rst) awcstate    <= AWIDLE;
//     else    awcstate    <= awnstate;
//
// always@(*)
//     case(awcstate)
//     AWIDLE:
//         if(wr_enable)
//                 awnstate    = AWRDY;
//         else    awnstate    = AWIDLE;
//     AWRDY:
//         if(axi_inf.axi_awvalid)
//                 awnstate    = AWEND;
//         else    awnstate    = AWIDLE;
//     AWEND:
//         if(!wr_enable)
//                 awnstate    = AWIDLE;
//         else    awnstate    = AWEND;
//     default:    awnstate    = AWIDLE;
//     endcase

always@(posedge clock,posedge rst)
    if(rst)     axi_inf.axi_awready <= 1'b0;
    else
        case(mnstate)
        WIDLE:  axi_inf.axi_awready <= 1'b1;
        default:axi_inf.axi_awready <= 1'b0;
        endcase

always@(posedge clock,posedge rst)
    if(rst)     axi_inf.axi_arready <= 1'b0;
    else
        case(mnstate)
        RIDLE:  axi_inf.axi_arready <= 1'b1;
        default:axi_inf.axi_arready <= 1'b0;
        endcase
//---<< WR AXI CMD >>--------------------
//--->> AXI BURST <<------------------
// always@(posedge clock,posedge rst)
//     if(rst) app_len    <= 9'd0;
//     else begin
//         if(axi_inf.axi_awvalid && axi_inf.axi_awready)
//                 app_len    <= axi_inf.axi_awlen+1'b1;
//         else if(axi_inf.axi_arvalid && axi_inf.axi_arready)
//                 app_len    <= axi_inf.axi_arlen+1'b1;
//         else    app_len    <= app_len;
//     end

always@(posedge clock,posedge rst)
    if(rst) app_wr_len    <= 9'd0;
    else begin
        if(axi_inf.axi_awvalid && axi_inf.axi_awready)
                app_wr_len    <= axi_inf.axi_awlen+1'b1;
        else    app_wr_len    <= app_wr_len;
    end


always@(posedge clock,posedge rst)
    if(rst) app_rd_len    <= 9'd0;
    else begin
        if(axi_inf.axi_arvalid && axi_inf.axi_arready)
                app_rd_len    <= axi_inf.axi_arlen+1'b1;
        else    app_rd_len    <= app_rd_len;
    end

logic [8:0] len_cnt;
always@(posedge clock,posedge rst)
    if(rst) len_cnt  <=  9'd0;
    else begin
        if(wr_enable || rd_enable)begin
            if(app_rdy && app_en)
                    len_cnt  <= len_cnt + 1'b1;
            else    len_cnt  <= len_cnt;
        end else    len_cnt  <= 9'd0;
    end
//---<< AXI BURST >>------------------
// (* dont_touch = "true" *)
// logic       app_en_last;
// always@(posedge clock,posedge rst)
//     if(rst) app_en_last   <= 1'b0;
//     else begin
//         // if(wr_enable || rd_enable)
//         //         // app_en_last   <= (len_cnt==(app_len-1 ) && app_en && app_rdy) || app_en_last;
//         //         app_en_last   <= len_cnt==(app_len-1 ) || (len_cnt==(app_len-2 ) && app_en && app_rdy);
//         // // else if(app_en_last && app_rdy && app_en)
//         // //         app_en_last   <= 1'b0;
//         // // else    app_en_last   <= app_en_last;
//         // else    app_en_last   <= 1'b0;
//         if(wr_enable)
//                 app_en_last   <= len_cnt==(app_wr_len-1 ) || (len_cnt==(app_wr_len-2 ) && app_en && app_rdy);
//         else if(rd_enable)
//                 app_en_last   <= len_cnt==(app_rd_len-1 ) || (len_cnt==(app_rd_len-2 ) && app_en && app_rdy);
//         else    app_en_last   <= 1'b0;
//     end

//
always@(posedge clock,posedge rst)
    if(rst) app_en_wr_last   <= 1'b0;
    else begin
        if(axi_inf.axi_awvalid && axi_inf.axi_awready && axi_inf.axi_awlen==0)
                app_en_wr_last   <= 1'b1;
        else if(app_en && app_rdy && app_en_wr_last)
                app_en_wr_last   <= 1'b0;
        else if(len_cnt==(app_wr_len-2 ) && app_en && app_rdy)
                app_en_wr_last   <= 1'b1;
        else    app_en_wr_last   <= app_en_wr_last;
    end

always@(posedge clock,posedge rst)
    if(rst) app_en_rd_last   <= 1'b0;
    else begin
        if(axi_inf.axi_arvalid && axi_inf.axi_arready && axi_inf.axi_arlen==0)
                app_en_rd_last  <= 1'b1;
        else if(rd_enable)
                app_en_rd_last   <= len_cnt==(app_rd_len-1 ) || (len_cnt==(app_rd_len-2 ) && app_en && app_rdy);
        else    app_en_rd_last   <= 1'b0;
    end

always@(posedge clock,posedge rst)
    if(rst) axi_inf.axi_bvalid   <= 1'b0;
    else
        case(mnstate)
        WR_END:     axi_inf.axi_bvalid   <= 1'b1;
        default:    axi_inf.axi_bvalid   <= 1'b0;
        endcase

assign axi_inf.axi_bresp    = 2'b00;
// assign axi_inf.axi_bid      = 0;
// assign app_en_last = app_en_last;
//---<< AXI WR BURST >>------------------
//--->> DDR ADDR <<-------------------
logic [26:0] base_wr_addr;

always@(posedge clock,posedge rst)
    if(rst) base_wr_addr    <= 27'd0;
    else begin
        if(axi_inf.axi_awvalid && axi_inf.axi_awready)
                base_wr_addr    <= axi_inf.axi_awaddr;
        else    base_wr_addr    <= base_wr_addr;
    end

always@(posedge clock,posedge rst)begin
    if(rst)     app_addr    <= 27'd0;
    else begin
        if(app_rdy && app_en)
                app_addr    <= app_addr + 8;
        else if(axi_inf.axi_awvalid && axi_inf.axi_awready)
                app_addr    <= axi_inf.axi_awaddr;
        else if(axi_inf.axi_arvalid && axi_inf.axi_arready)
                app_addr    <= axi_inf.axi_araddr;
        else    app_addr    <= app_addr;
    end
end

// always@(posedge clock,posedge rst)
//     if(rst) app_en  <= 1'b0;
//     else begin
//         // // if(wr_enable || rd_enable)begin
//         // // app_en  <= 1'b1;
//         // if(wr_enable || rd_enable)begin
//         //     if(app_en_last)begin
//         //         // app_en  <= 1'b0;
//         //         // app_en  <= !app_rdy;
//         //         if(app_en)begin
//         //             if(app_rdy)
//         //                     app_en   <= 1'b0;
//         //             else    app_en   <= app_en;
//         //         end else    app_en   <= 1'b0;
//         //     end else    app_en  <= 1'b1;
//         //
//         //     // if(app_en_last && app_en && app_rdy)
//         //     //         app_en  <= 1'b0;
//         //     // else    app_en  <= app_en;
//         //
//         // end else    app_en  <= 1'b0;
//
//
//     end

assign app_en   = wr_enable || rd_enable;
assign app_cmd  = wr_enable ? 3'b000 : (rd_enable? 3'b001 : 3'b111);
// reg [2:0]   app_cmd_reg;
// always@(posedge clock,posedge rst)
//     if(rst) app_cmd_reg <= 3'b111;
//     else begin
//         if(wr_enable)
//                 app_cmd_reg <= 3'b000;
//         else if(rd_enable)
//                 app_cmd_reg <= 3'b001;
//         else    app_cmd_reg <= app_cmd_reg;
//     end
//
// assign app_cmd = app_cmd_reg;

//--->> axi read data last <<-------------
logic [8:0]     axi_rd_cnt;

always@(posedge clock,posedge rst)
    if(rst)     axi_rd_cnt  <= 9'd0;
    else begin
        // if(rd_enable)begin
        if(rd_app_enable)begin
            if(axi_inf.axi_rready && axi_inf.axi_rvalid)
                    axi_rd_cnt  <= axi_rd_cnt + 1'b1;
            else    axi_rd_cnt  <= axi_rd_cnt;
        end else    axi_rd_cnt  <= 9'd0;
    end
always@(posedge clock,posedge rst)
    if(rst) axi_inf.axi_rlast  <= 1'b0;
    else begin
        // if(!rd_enable)
        if(!rd_app_enable)
                axi_inf.axi_rlast   <= 1'b0;
        else if(app_rd_len==1)
                axi_inf.axi_rlast   <= 1'b1;
        else if(axi_inf.axi_rready && axi_inf.axi_rvalid && axi_inf.axi_rlast)
                axi_inf.axi_rlast   <= 1'b0;
        else if(axi_inf.axi_rready && axi_inf.axi_rvalid && axi_rd_cnt == (app_rd_len-2))
                axi_inf.axi_rlast   <= 1'b1;
        else    axi_inf.axi_rlast   <= axi_inf.axi_rlast;
    end
//---<< axi read data last >>-------------
// assign axi_inf.axi_rid      = 0;
assign axi_inf.axi_rresp    = 2'b00;
//--->> WR ID <<--------------------------
always@(posedge clock,posedge rst)
    if(rst)     axi_inf.axi_bid <= 0;
    else begin
        if(axi_inf.axi_awvalid && axi_inf.axi_awready)
                axi_inf.axi_bid <= axi_inf.axi_awid;
        else    axi_inf.axi_bid <= axi_inf.axi_bid;
    end
//---<< WR ID >>--------------------------
//--->> RD ID <<--------------------------
always@(posedge clock,posedge rst)
    if(rst)     axi_inf.axi_rid <= 0;
    else begin
        if(axi_inf.axi_arvalid && axi_inf.axi_arready)
                axi_inf.axi_rid <= axi_inf.axi_arid;
        else    axi_inf.axi_rid <= axi_inf.axi_rid;
    end
//---<< RD ID >>--------------------------
//--->> APP WRITE CNT <<------------------
(* dont_touch="true" *)
logic [5:0]        app_wr_cmd_cnt;
(* dont_touch="true" *)
logic [5:0]        app_wr_data_cnt;
(* dont_touch="true" *)
logic [5:0]        app_cnt_delta;

always@(posedge clock,posedge rst)
    if(rst)     app_wr_cmd_cnt  <= '0;
    else begin
        if(app_en && app_rdy && app_cmd == 2'b00)
                app_wr_cmd_cnt  <= app_wr_cmd_cnt + 1'b1;
        else    app_wr_cmd_cnt  <= app_wr_cmd_cnt;
    end

always@(posedge clock,posedge rst)
    if(rst)     app_wr_data_cnt  <= '0;
    else begin
        if(app_wdf_wren && app_wdf_rdy)
        // if(app_rd_data_valid)
                app_wr_data_cnt  <= app_wr_data_cnt + 1'b1;
        else    app_wr_data_cnt  <= app_wr_data_cnt;
    end

always@(posedge clock,posedge rst)
    if(rst)     app_cnt_delta   <= '0;
    else begin
        if(!app_wdf_wren && !app_en)
        // if(!app_rd_data_valid && !app_en)
                app_cnt_delta   <= app_wr_cmd_cnt-app_wr_data_cnt;
        else    app_cnt_delta   <= app_cnt_delta;
    end
//---<< APP WRITE CNT >>------------------


endmodule
