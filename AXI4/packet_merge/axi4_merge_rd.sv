/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    out of order
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/30 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_merge_rd #(
    parameter MAX = 8                   //MUST LARGER THAN 2
)(
    axi_inf.slaver_rd slaver,           //Out of Last
    axi_inf.master_rd master            //Out of Last
);

logic clock,rst_n;

assign  clock   = slaver.axi_aclk;
assign  rst_n   = slaver.axi_aresetn;

typedef enum {IDLE,GET_BASE,CHECK_NEXT,MIX,WR_DOMN} STATUS;

STATUS nstate,cstate;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cstate  <= IDLE;
    else        cstate  <= nstate;


logic [slaver.ASIZE-1:0]    base_addr;
logic [master.LSIZE-1:0]    base_len;

logic [slaver.ASIZE-1:0]    curr_addr;
logic [slaver.LSIZE-1:0]    curr_len;
logic [$clog2(MAX)-1:0]     cnt;
logic                       enough_slaver;
logic                       alone_aux;
logic                       aux_fifo_full;
logic                       aux_fifo_empty;
logic                       aux_fifo_wren;

logic       next_serial;

assign  next_serial = curr_addr+curr_len+1 == slaver.axi_araddr && !enough_slaver;

always_comb begin
    case(cstate)
    IDLE:
        if(slaver.axi_arvalid && slaver.axi_arready)
                nstate  = GET_BASE;
        else    nstate  = IDLE;
    GET_BASE:
        if(alone_aux)
                nstate  = WR_DOMN;
        else if(slaver.axi_arvalid)begin
            if(next_serial)
                    nstate  = MIX;
            else    nstate  = WR_DOMN;
        end else    nstate  = GET_BASE;
    CHECK_NEXT:
        if(alone_aux)
                nstate  = WR_DOMN;
        else if(slaver.axi_arvalid)begin
            if(next_serial)
                    nstate  = MIX;
            else    nstate  = WR_DOMN;
        end else    nstate  = CHECK_NEXT;
    MIX:
        if(slaver.axi_arvalid && slaver.axi_arready)
                nstate  = CHECK_NEXT;
        else    nstate  = MIX;
    WR_DOMN:
        if(!aux_fifo_full)
                nstate  = IDLE;
        else    nstate  = WR_DOMN;
    default:    nstate  = IDLE;
    endcase
end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  slaver.axi_arready  <= 1'b0;
    else
        case(nstate)
        IDLE,MIX:
                slaver.axi_arready  <= 1'b1;
        default:slaver.axi_arready  <= 1'b0;
        endcase


always@(posedge clock,negedge rst_n)
    if(~rst_n)  base_addr   <= '0;
    else
        case(nstate)
        GET_BASE:
                base_addr   <= slaver.axi_araddr;
        default:base_addr   <= base_addr;
        endcase

always@(posedge clock,negedge rst_n)
    if(~rst_n)  base_len   <= '0;
    else
        case(nstate)
        GET_BASE:
                base_len   <= slaver.axi_arlen;
        MIX:
            if(slaver.axi_arvalid)
                    base_len    <= slaver.axi_araddr + slaver.axi_arlen;
            else    base_len    <= base_len;

        default:base_len   <= base_len;
        endcase

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cnt   <= '0;
    else
        case(nstate)
        GET_BASE:
                cnt   <= '0;
        MIX:
            if(slaver.axi_arvalid)
                    cnt    <= cnt + 1;
            else    cnt    <= cnt;

        default:cnt   <= cnt;
        endcase

always@(posedge clock,negedge rst_n)
    if(~rst_n)  enough_slaver   <= '0;
    else
        case(nstate)
        GET_BASE:
                enough_slaver   <= '0;
        MIX:
            if(slaver.axi_arvalid)
                    enough_slaver    <= cnt == MAX-2;
            else    enough_slaver    <= enough_slaver;

        default:enough_slaver   <= enough_slaver;
        endcase

always@(posedge clock,negedge rst_n)
    if(~rst_n)  curr_addr   <= '0;
    else
        case(nstate)
        GET_BASE,CHECK_NEXT:
                curr_addr   <= slaver.axi_araddr;
        default:curr_addr   <= curr_addr;
        endcase

always@(posedge clock,negedge rst_n)
    if(~rst_n)  curr_len   <= '0;
    else
        case(nstate)
        GET_BASE,CHECK_NEXT:
                curr_len   <= slaver.axi_arlen;
        default:curr_len   <= curr_len;
        endcase

always@(posedge clock,negedge rst_n)
    if(~rst_n)  aux_fifo_wren   <= '0;
    else
        case(nstate)
        WR_DOMN:
                aux_fifo_wren   <= 1'b1;
        default:aux_fifo_wren   <= 1'b0;
        endcase
//--->> ALONE <<----------------------
logic [5:0]     alone_cnt;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  alone_cnt   <= '0;
    else
        case(nstate)
        GET_BASE,CHECK_NEXT:
                alone_cnt   <= alone_cnt + 1'b1;
        default:alone_cnt   <= '0;
        endcase

always@(posedge clock,negedge rst_n)
    if(~rst_n)  alone_aux   <= '0;
    else        alone_aux   <= &alone_cnt;

//---<< ALONE >>----------------------
common_fifo #(
    .DEPTH      (4      ),
    .DSIZE      (master.ASIZE + master.LSIZE)
)aux_common_fifo_inst(
/*  input                   */  .clock      (clock      ),
/*  input                   */  .rst_n      (rst_n      ),
/*  input [DSIZE-1:0]       */  .wdata      ({base_addr,base_len}),
/*  input                   */  .wr_en      (aux_fifo_wren      ),
/*  output logic[DSIZE-1:0] */  .rdata      ({master.axi_araddr,master.axi_arlen}),
/*  input                   */  .rd_en      (master.axi_arready ),
/*  output logic[CSIZE-1:0] */  .count      (),
/*  output logic            */  .empty      (aux_fifo_empty     ),
/*  output logic            */  .full       (aux_fifo_full      )
);

assign  master.axi_arvalid  = !aux_fifo_empty;
assign  master.axi_arid     = '0;
//------>> READ BEAK AUX <<-------------------
logic [slaver.ASIZE-1:0]    slaver_addr;
logic [slaver.LSIZE-1:0]    slaver_len;
logic [slaver.IDSIZE-1:0]   slaver_aid;
logic                       slaver_burst_1;
logic                       slaver_fifo_full;
logic                       slaver_fifo_empty;

common_fifo #(
    .DEPTH      (MAX      ),
    .DSIZE      (1+slaver.ASIZE + slaver.LSIZE +slaver.IDSIZE)
)slaver_common_fifo_inst(
/*  input                   */  .clock      (clock      ),
/*  input                   */  .rst_n      (rst_n      ),
/*  input [DSIZE-1:0]       */  .wdata      ({(slaver.axi_arlen=='0),slaver.axi_araddr,slaver.axi_arlen,slaver.axi_arid}   ),
/*  input                   */  .wr_en      ((slaver.axi_arvalid && slaver.axi_arready)             ),
/*  output logic[DSIZE-1:0] */  .rdata      ({slaver_burst_1,slaver_addr,slaver_len,slaver_aid}                    ),
/*  input                   */  .rd_en      ((slaver.axi_rvalid==1'b1 && slaver.axi_rready && slaver.axi_rlast)          ),
/*  output logic[CSIZE-1:0] */  .count      (),
/*  output logic            */  .empty      (slaver_fifo_empty      ),
/*  output logic            */  .full       (slaver_fifo_full       )
);


logic [master.LSIZE-1:0]        partition_cnt;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  partition_cnt   <= '0;
    else begin
        if(master.axi_rvalid && master.axi_rready && master.axi_rlast)
                partition_cnt   <= '0;
        else if(master.axi_rvalid && master.axi_rready)begin
            if(partition_cnt==slaver_len)
                    partition_cnt   <= '0;
            else    partition_cnt   <= partition_cnt + 1'b1;
        end else
                partition_cnt   <= partition_cnt;
    end



// always@(posedge clock,negedge rst_n)
//     if(~rst_n)  slaver.axi_rlast    <= 1'b0;
//     else begin
//         if(!slaver_fifo_empty && slaver_burst_1)
//             slaver.axi_rlast    <= 1'b1;
//         else if(slaver.axi_rvalid && slaver.axi_rready && slaver.axi_rlast)
//                 slaver.axi_rlast    <= 1'b0;
//         else if(slaver.axi_rvalid && slaver.axi_rready && (slaver.axi_rcnt == (slaver_len-1)))
//                 slaver.axi_rlast    <= 1'b1;
//         else    slaver.axi_rlast    <= slaver.axi_rlast;
//     end

logic   cnt_last;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cnt_last    <= 1'b0;
    else begin
        if(slaver.axi_rvalid && slaver.axi_rready && slaver.axi_rlast)
                cnt_last    <= 1'b0;
        else if(slaver.axi_rvalid && slaver.axi_rready && (slaver.axi_rcnt == (slaver_len-1)))
                cnt_last    <= 1'b1;
        else    cnt_last    <= cnt_last;
    end

assign  slaver.axi_rdata    = master.axi_rdata;
assign  slaver.axi_rvalid   = master.axi_rvalid;
assign  slaver.axi_rid      = slaver_aid;
assign  master.axi_rready   = slaver.axi_rready;

assign  slaver.axi_rlast    = cnt_last || slaver_burst_1;

//------<< READ BEAK AUX >>-------------------

endmodule
