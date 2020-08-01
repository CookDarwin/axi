/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.1 2017/9/28 
    user axi4 addr_step
creaded: 2016/10/12
madified:
***********************************************/
`timescale 1ns / 1ps
(* axi4 = "true" *)
module axi4_to_native_for_ddr_ip_verb #(
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
        WIDLE,
        RIDLE,
        WR_BURST_APP,
        WAIT_AXI_LAST,
        WAIT_APP_LAST,
        WR_AXI_RESP,
        RD_BURST_APP
        } MASTER_STATE;

MASTER_STATE mnstate,mcstate;

always@(posedge clock,posedge rst)begin
    if(rst)     mcstate <= NOP;
    else        mcstate <= mnstate;
end


logic           app_cmd_last;
logic           app_cmd_just_one;

logic [axi_inf.LSIZE:0]     app_len;
logic [axi_inf.LSIZE:0]     rd_cnt;
logic [axi_inf.LSIZE:0]     app_cmd_cnt;
(* dont_touch="true" *)
logic           axi_rd_idle;

always@(*)
    case(mcstate)
    NOP:
        if(init_calib_complete && app_rdy)
                mnstate = WIDLE;
        else    mnstate = NOP;
    WIDLE:
        if(axi_inf.axi_awvalid && axi_inf.axi_awready)
                mnstate = WR_BURST_APP;
        else begin
            if(axi_rd_idle)
                    mnstate = RIDLE;
            else    mnstate = WIDLE;
        end
    RIDLE:
        if(axi_inf.axi_arvalid && axi_inf.axi_arready)
                mnstate = RD_BURST_APP;
        else    mnstate = WIDLE;
    WR_BURST_APP:
        if((app_cmd_last && app_en && app_rdy) && (axi_inf.axi_wlast && axi_inf.axi_wvalid && axi_inf.axi_wready))
                mnstate = WR_AXI_RESP;
        else if(app_cmd_last && app_en && app_rdy)
                mnstate = WAIT_AXI_LAST;
        else if(axi_inf.axi_wlast && axi_inf.axi_wvalid && axi_inf.axi_wready)
                mnstate = WAIT_APP_LAST;
        else    mnstate = WR_BURST_APP;
    WAIT_AXI_LAST:
        if(axi_inf.axi_wlast && axi_inf.axi_wvalid && axi_inf.axi_wready)
                mnstate = WR_AXI_RESP;
        else    mnstate = WAIT_AXI_LAST;
    WAIT_APP_LAST:
        if(app_cmd_last && app_en && app_rdy)
                mnstate = WR_AXI_RESP;
        else    mnstate = WAIT_APP_LAST;
    WR_AXI_RESP:
        if(axi_inf.axi_bready && axi_inf.axi_bvalid)begin
            if(axi_rd_idle)
                    mnstate = RIDLE;
            else    mnstate = WIDLE;
        end else    mnstate = WR_AXI_RESP;
    RD_BURST_APP:
        if((app_cmd_last || app_cmd_just_one) && app_en && app_rdy)
                mnstate = WIDLE;
        else    mnstate = RD_BURST_APP;
    default:    mnstate = NOP;
    endcase

//--->> APP CMD <<--------------------------------
always@(posedge clock,posedge rst)
    if(rst)     app_cmd <= 3'b111;
    else begin
        case(mnstate)
        WR_BURST_APP,WAIT_APP_LAST:
                        app_cmd <= 3'd0;
        RD_BURST_APP:   app_cmd <= 3'd1;
        default:        app_cmd <= 3'b111;
        endcase
    end

always@(posedge clock,posedge rst)
    if(rst)     app_en  <= 1'b0;
    else
        case(mnstate)
        WR_BURST_APP,WAIT_APP_LAST:begin
            if(app_en && app_rdy && app_cmd_last)
                    app_en  <= #(1ps) 1'b0;
            else if(app_len == '0)
                    app_en  <= #(1ps) 1'b1;
            else    app_en  <= #(1ps) 1'b1;
        end
        RD_BURST_APP:begin
            if(app_en && app_rdy && (app_cmd_last || app_cmd_just_one))
                    app_en  <= #(1ps) 1'b0;
            // else if(app_len == '0)
            else if(app_cmd_just_one)
                    app_en  <= #(1ps) 1'b1;
            else    app_en  <= #(1ps) 1'b1;
        end
        default:app_en  <= #(1ps) 1'b0;
        endcase

always@(posedge clock,posedge rst)
    if(rst) app_cmd_cnt     <= '0;
    else begin
        case(mnstate)
        WR_BURST_APP,WAIT_APP_LAST,
        RD_BURST_APP:begin
            if(app_en && app_rdy)
                    app_cmd_cnt <= app_cmd_cnt + 1'b1;
            else    app_cmd_cnt <= app_cmd_cnt;
        end
        default:    app_cmd_cnt <= '0;
        endcase
    end

logic   axi_aux_req;

always@(posedge clock,posedge rst)
    if(rst) axi_aux_req <= 1'b0;
    else begin
        axi_aux_req <= (axi_inf.axi_awvalid && axi_inf.axi_awready) || (axi_inf.axi_arvalid && axi_inf.axi_arready);
    end

always@(posedge clock,posedge rst)
    if(rst) app_cmd_last    <= 1'b0;
    else begin
        case(mnstate)
        WIDLE,RIDLE:
            app_cmd_last    <= 1'b0;
        default:
            if(app_len  == '0 && axi_aux_req)
                    app_cmd_last    <= 1'b1;
            else if(app_en && app_rdy && app_cmd_last)
                    app_cmd_last    <= 1'b0;
            else if(app_en && app_rdy && app_cmd_cnt==(app_len-1))
                    app_cmd_last    <= 1'b1;
            else    app_cmd_last    <= app_cmd_last;
        endcase
    end

always@(posedge clock,posedge rst)
    if(rst) app_len     <= '0;
    else begin
        if(axi_inf.axi_awvalid && axi_inf.axi_awready)
                app_len <= axi_inf.axi_awlen;
        else if(axi_inf.axi_arvalid && axi_inf.axi_arready)
                app_len <= axi_inf.axi_arlen;
        else    app_len <= app_len;
    end



always@(posedge clock,posedge rst)
    if(rst) app_cmd_just_one     <= '0;
    else begin
        if(axi_inf.axi_awvalid && axi_inf.axi_awready)
                app_cmd_just_one <= axi_inf.axi_awlen == '0;
        else if(axi_inf.axi_arvalid && axi_inf.axi_arready)
                app_cmd_just_one <= axi_inf.axi_arlen == '0;
        // else if(axi_inf.axi_wvalid && axi_inf.axi_wready)
        //         app_cmd_just_one <= 1'b0;
        // else if(axi_inf.axi_rvalid && axi_inf.axi_rready)
        //         app_cmd_just_one <= 1'b0;
        else if(app_en && app_rdy)
                app_cmd_just_one <= 1'b0;
        else    app_cmd_just_one <= app_cmd_just_one;
    end


logic [axi_inf.LSIZE:0]     app_rd_len;

always@(posedge clock,posedge rst)
    if(rst) app_rd_len     <= '0;
    else begin
        if(axi_inf.axi_arvalid && axi_inf.axi_arready)
                app_rd_len <= axi_inf.axi_arlen;
        else    app_rd_len <= app_rd_len;
    end

always@(posedge clock,posedge rst)
    if(rst) rd_cnt     <= '0;
    else begin
        if(axi_inf.axi_arvalid && axi_inf.axi_arready)
                rd_cnt  <= '0;
        else if(axi_inf.axi_rvalid && axi_inf.axi_rlast)
                rd_cnt  <= '0;
        else if(axi_inf.axi_rvalid)
                rd_cnt  <= rd_cnt + 1'b1;
        else    rd_cnt  <= rd_cnt;
    end

always@(posedge clock,posedge rst)
    if(rst)     axi_inf.axi_rlast <= 1'b0;
    else begin
        if(axi_inf.axi_arvalid && axi_inf.axi_arready && axi_inf.axi_arlen=='0)
                axi_inf.axi_rlast   <= 1'b1;
        else if(axi_inf.axi_rvalid && axi_inf.axi_rlast)
                axi_inf.axi_rlast   <= 1'b0;
        else if(axi_inf.axi_rvalid && rd_cnt==(app_rd_len-1))
                axi_inf.axi_rlast   <= 1'b1;
        else    axi_inf.axi_rlast   <= axi_inf.axi_rlast;
    end



always@(posedge clock,posedge rst)
    if(rst) axi_rd_idle <= 1'b1;
    else begin
        if(axi_inf.axi_arvalid && axi_inf.axi_arready)
                axi_rd_idle <= 1'b0;
        else if(axi_inf.axi_rvalid && axi_inf.axi_rlast)
                axi_rd_idle <= 1'b1;
        else    axi_rd_idle <= axi_rd_idle;
    end

logic   en_wdy_ready;
always@(posedge clock,posedge rst)
    if(rst) en_wdy_ready     <= 1'b0;
    else begin
        case(mnstate)
        WR_BURST_APP,WAIT_AXI_LAST:
                en_wdy_ready    <= 1'b1;
        default:en_wdy_ready    <= 1'b0;
        endcase
    end

assign app_wdf_wren         = axi_inf.axi_wvalid && en_wdy_ready;
assign axi_inf.axi_wready   = app_wdf_rdy && en_wdy_ready;
assign axi_inf.axi_rvalid   = app_rd_data_valid;

assign app_wdf_mask       = {(DATA_WIDTH/8){1'b0}};
assign app_wdf_end        = 1'b1;

assign app_wdf_data       = axi_inf.axi_wdata;
assign axi_inf.axi_rdata  = app_rd_data;
//___________________________________________________________
//--->> WR AXI CMD <<--------------------
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
//--->> AXI WR RESP<<------------------
always@(posedge clock,posedge rst)
    if(rst) axi_inf.axi_bvalid   <= 1'b0;
    else
        case(mnstate)
        WR_AXI_RESP:
                    axi_inf.axi_bvalid   <= 1'b1;
        default:    axi_inf.axi_bvalid   <= 1'b0;
        endcase

assign axi_inf.axi_bresp    = 2'b00;
//---<< AXI WR RESP>>------------------
//--->> DDR ADDR <<-------------------

always@(posedge clock,posedge rst)begin
    if(rst)     app_addr    <= 27'd0;
    else begin
        if(app_rdy && app_en)
                // app_addr    <= app_addr + 8;
                app_addr    <= app_addr + (axi_inf.ADDR_STEP/1024);
        else if(axi_inf.axi_awvalid && axi_inf.axi_awready)
                app_addr    <= axi_inf.axi_awaddr;
        else if(axi_inf.axi_arvalid && axi_inf.axi_arready)
                app_addr    <= axi_inf.axi_araddr;
        else    app_addr    <= app_addr;
    end
end
//---<< DDR ADDR >>-------------------

assign axi_inf.axi_rresp    = 2'b00;
//--->> RD ID <<--------------------------
always@(posedge clock,posedge rst)begin
    if(rst) axi_inf.axi_rid     <= '0;
    else begin
        if(axi_inf.axi_arvalid && axi_inf.axi_arready)
                axi_inf.axi_rid     <= axi_inf.axi_arid;
        else    axi_inf.axi_rid     <= axi_inf.axi_rid;
    end
end

//---<< RD ID >>--------------------------
//--->> RESP ID <<--------------------------
always@(posedge clock,posedge rst)begin
    if(rst) axi_inf.axi_bid     <= '0;
    else begin
        if(axi_inf.axi_awvalid && axi_inf.axi_awready)
                axi_inf.axi_bid     <= axi_inf.axi_awid;
        else    axi_inf.axi_bid     <= axi_inf.axi_bid;
    end
end

//---<< RESP ID >>--------------------------
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
