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
module axi4_merge_wr #(
    parameter MAX = 8                   //MUST LARGER THAN 2
)(
    axi_inf.slaver_wr slaver,           //Out of Last
    axi_inf.master_wr master            //Out of Last
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
logic                       aux_fifo_wren;
logic                       resp_fifo_full;
logic                       resp_fifo_empty;

logic       next_serial;

assign  next_serial = curr_addr+curr_len+1 == slaver.axi_awaddr && !enough_slaver;

always_comb begin
    case(cstate)
    IDLE:
        if(slaver.axi_awvalid && slaver.axi_awready)
                nstate  = GET_BASE;
        else    nstate  = IDLE;
    GET_BASE:
        if(alone_aux)
                nstate  = WR_DOMN;
        else if(slaver.axi_awvalid)begin
            if(next_serial)
                    nstate  = MIX;
            else    nstate  = WR_DOMN;
        end else    nstate  = GET_BASE;
    CHECK_NEXT:
        if(alone_aux)
                nstate  = WR_DOMN;
        else if(slaver.axi_awvalid)begin
            if(next_serial)
                    nstate  = MIX;
            else    nstate  = WR_DOMN;
        end else    nstate  = CHECK_NEXT;
    MIX:
        if(slaver.axi_awvalid && slaver.axi_awready)
                nstate  = CHECK_NEXT;
        else    nstate  = MIX;
    WR_DOMN:
        if(!resp_fifo_full)
                nstate  = IDLE;
        else    nstate  = WR_DOMN;
    default:    nstate  = IDLE;
    endcase
end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  slaver.axi_awready  <= 1'b0;
    else
        case(nstate)
        IDLE,MIX:
                slaver.axi_awready  <= 1'b1;
        default:slaver.axi_awready  <= 1'b0;
        endcase


always@(posedge clock,negedge rst_n)
    if(~rst_n)  base_addr   <= '0;
    else
        case(nstate)
        GET_BASE:
                base_addr   <= slaver.axi_awaddr;
        default:base_addr   <= base_addr;
        endcase

always@(posedge clock,negedge rst_n)
    if(~rst_n)  base_len   <= '0;
    else
        case(nstate)
        GET_BASE:
                base_len   <= slaver.axi_awlen;
        MIX:
            if(slaver.axi_awvalid)
                    base_len    <= slaver.axi_awaddr + slaver.axi_awlen + 1;
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
            if(slaver.axi_awvalid)
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
            if(slaver.axi_awvalid)
                    enough_slaver    <= cnt == MAX-2;
            else    enough_slaver    <= enough_slaver;

        default:enough_slaver   <= enough_slaver;
        endcase

always@(posedge clock,negedge rst_n)
    if(~rst_n)  curr_addr   <= '0;
    else
        case(nstate)
        GET_BASE,CHECK_NEXT:
                curr_addr   <= slaver.axi_awaddr;
        default:curr_addr   <= curr_addr;
        endcase

always@(posedge clock,negedge rst_n)
    if(~rst_n)  curr_len   <= '0;
    else
        case(nstate)
        GET_BASE,CHECK_NEXT:
                curr_len   <= slaver.axi_awlen;
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
/*  output logic[DSIZE-1:0] */  .rdata      ({master.axi_awaddr,master.axi_awlen}),
/*  input                   */  .rd_en      (master.axi_awready ),
/*  output logic[CSIZE-1:0] */  .count      (),
/*  output logic            */  .empty      (aux_fifo_empty     ),
/*  output logic            */  .full       (aux_fifo_full      )
);

assign  master.axi_awvalid  = !aux_fifo_empty;
assign  master.axi_awid     = '0;
//------>> READ BEAK AUX <<-------------------
logic                       master_burst_1;
logic [slaver.LSIZE-1:0]    master_len;
logic                       master_fifo_full;
logic                       master_fifo_empty;

common_fifo #(
    .DEPTH      (MAX      ),
    .DSIZE      (1+master.LSIZE)
)master_common_fifo_inst(
/*  input                   */  .clock      (clock      ),
/*  input                   */  .rst_n      (rst_n      ),
/*  input [DSIZE-1:0]       */  .wdata      ({(master.axi_awlen=='0),master.axi_awlen}),
/*  input                   */  .wr_en      ((master.axi_awvalid && master.axi_awready)             ),
/*  output logic[DSIZE-1:0] */  .rdata      ({master_burst_1,master_len}                    ),
/*  input                   */  .rd_en      ((master.axi_wvalid && master.axi_wready && master.axi_wlast)          ),
/*  output logic[CSIZE-1:0] */  .count      (),
/*  output logic            */  .empty      (master_fifo_empty      ),
/*  output logic            */  .full       (master_fifo_full       )
);

always@(posedge clock,negedge rst_n)
    if(~rst_n)  master.axi_wlast    <= 1'b0;
    else begin
        if(master.axi_wvalid && master.axi_wready && master.axi_wlast)
                master.axi_wlast    <= 1'b0;
        else if(!master_fifo_empty && master_burst_1)
                master.axi_wlast    <= 1'b1;
        else if(master.axi_wvalid && master.axi_wready && master.axi_wcnt == (master_len-1))
                master.axi_wlast    <= 1'b1;
        else    master.axi_wlast    <= master.axi_wlast;
    end

assign  master.axi_wdata    = slaver.axi_wdata;
assign  master.axi_wvalid   = slaver.axi_wvalid && !master_fifo_empty;
assign  slaver.axi_wready   = master.axi_wready && !master_fifo_empty;
// assign  master.axi_wid      = '0;
//------<< READ BEAK AUX >>-------------------
//------>> SLAVER RESP <<----------------------------
logic [slaver.LSIZE-1:0]    resp_len;
logic [slaver.IDSIZE-1:0]   resp_aid;
logic                       resp_burst_1;

common_fifo #(
    .DEPTH      (MAX      ),
    .DSIZE      (slaver.IDSIZE)
)slaver_resp_common_fifo_inst(
/*  input                   */  .clock      (clock      ),
/*  input                   */  .rst_n      (rst_n      ),
/*  input [DSIZE-1:0]       */  .wdata      (slaver.axi_awid   ),
/*  input                   */  .wr_en      ((slaver.axi_awvalid && slaver.axi_awready)             ),
/*  output logic[DSIZE-1:0] */  .rdata      (slaver.axi_bid             ),
/*  input                   */  .rd_en      (slaver.axi_bready          ),
/*  output logic[CSIZE-1:0] */  .count      (),
/*  output logic            */  .empty      (resp_fifo_empty      ),
/*  output logic            */  .full       (resp_fifo_full       )
);

assign slaver.axi_bvalid    = !resp_fifo_empty;
//------<< SALVER RESP >>----------------------------
assign master.axi_bready    = 1'b1;

endmodule
