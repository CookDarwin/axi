/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
    build from axi_stream_packet_fifo
Version: VERA.1.0 2018/1/25 
    add axis_tuser
creaded: 2017/9/14 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_pkt_fifo_filter_keep_A1 #(
    parameter DEPTH   = 2   //2-4
)(
    (* up_stream = "true" *)
    axi_stream_inf.slaver      axis_in,
    (* down_stream = "true" *)
    axi_stream_inf.master      axis_out
);

logic       clock;
logic       rst_n;

assign  clock   = axis_in.aclk;
assign  rst_n   = axis_in.aresetn;

axi_stream_inf #(axis_in.DSIZE) post_axis_in (clock,rst_n,1'b1);

localparam ESIZE = 5;

logic [ESIZE-1:0]   origin_status;
logic [ESIZE-1:0]   binding_status;

axis_ex_status #(
    .ESIZE  (ESIZE)
)axis_ex_status_inst(
/*  input [ESIZE-1:0]     */  .origin_status        (origin_status  ),
/*  output[ESIZE-1:0]     */  .binding_status       (binding_status ),
/*  axi_stream_inf.slaver */  .axis_in              (axis_in        ),
/*  axi_stream_inf.master */  .axis_out             (post_axis_in   )
);

logic               only_last_and_nokeep;
logic               all_nokeep;
logic               w_total_eq_1;
logic               in_last_valid;
logic               last_nokeep;

assign origin_status[0] = (axis_in.axis_tcnt == '0) && axis_in.axis_tvalid && axis_in.axis_tready && axis_in.axis_tlast && (axis_in.axis_tkeep == '0);
assign origin_status[1] = axis_in.axis_tvalid && axis_in.axis_tready && (axis_in.axis_tkeep == '0);
assign origin_status[2] = (axis_in.axis_tcnt == '0) && axis_in.axis_tvalid && axis_in.axis_tready && axis_in.axis_tlast;
assign origin_status[3] =   ((axis_in.axis_tcnt != '0) && axis_in.axis_tvalid && axis_in.axis_tready && axis_in.axis_tlast) ||
                            ((axis_in.axis_tcnt == '0) && axis_in.axis_tvalid && axis_in.axis_tready && axis_in.axis_tlast && (axis_in.axis_tkeep != '0));

assign origin_status[4] = axis_in.axis_tvalid && axis_in.axis_tready && axis_in.axis_tlast && (axis_in.axis_tkeep == '0);

assign only_last_and_nokeep = binding_status[0];
assign all_nokeep           = binding_status[1];
assign w_total_eq_1         = binding_status[2];
assign in_last_valid        = binding_status[3];
assign last_nokeep          = binding_status[4];

//--->> NATIVE FIFO IP <<------------------------------
logic   data_fifo_full;
logic   data_fifo_empty;
logic [axis_in.DSIZE + axis_in.KSIZE+1-1:0]   stream_fifo_data;

xilinx_fifo_verb #(
//xilinx_fifo #(
    .DSIZE      (axis_in.DSIZE + axis_in.KSIZE + 1)
) stream_packet_fifo_inst (
/*  input          */ .wr_clk       (axis_in.aclk        ),
/*  input          */ .wr_rst       (!axis_in.aresetn    ),
/*  input          */ .rd_clk       (axis_out.aclk       ),
/*  input          */ .rd_rst       (!axis_out.aresetn   ),
/*  input [255:0]  */ .din          ({post_axis_in.axis_tuser,post_axis_in.axis_tkeep,post_axis_in.axis_tdata}  ),
/*  input          */ .wr_en        ((post_axis_in.axis_tvalid && post_axis_in.axis_tready && !all_nokeep)      ),
/*  input          */ .rd_en        ((axis_out.axis_tvalid && axis_out.axis_tready)    ),
/*  output [255:0] */ .dout         (stream_fifo_data    ),
/*  output         */ .full         (data_fifo_full      ),
/*  output         */ .empty        (data_fifo_empty     ),
/*  output [LSIZE-1:0] */ .rdcount  (),
/*  output [LSIZE-1:0] */ .wrcount  ()
);

assign {axis_out.axis_tuser,axis_out.axis_tkeep,axis_out.axis_tdata} = axis_out.axis_tvalid? stream_fifo_data : '0;
//---<< NATIVE FIFO IP >>------------------------------

//--->> PACKET <<--------------------------------------
logic   packet_fifo_full;
logic   packet_fifo_empty;
logic [15:0]      w_bytes_total;
logic [15:0]      r_bytes_total;
logic             r_total_eq_1;
logic             r_last_nokeep;


localparam IDEPTH   = (DEPTH<4)? 4 : DEPTH;

independent_clock_fifo #(
    .DEPTH      (IDEPTH     ),
    .DSIZE      (16+1+1      )
)independent_clock_fifo_inst(
/*    input                     */  .wr_clk     (axis_in.aclk        ),
/*    input                     */  .wr_rst_n   (axis_in.aresetn     ),
/*    input                     */  .rd_clk     (axis_out.aclk       ),
/*    input                     */  .rd_rst_n   (axis_out.aresetn    ),
/*    input [DSIZE-1:0]         */  .wdata      ({last_nokeep,w_total_eq_1,w_bytes_total}      ),
/*    input                     */  .wr_en      ((post_axis_in.axis_tvalid && post_axis_in.axis_tlast && post_axis_in.axis_tready && in_last_valid)      ),
/*    output logic[DSIZE-1:0]   */  .rdata      ({r_last_nokeep,r_total_eq_1,r_bytes_total}      ),
/*    input                     */  .rd_en      ((axis_out.axis_tvalid && axis_out.axis_tlast && axis_out.axis_tready)    ),
/*    output logic              */  .empty      (packet_fifo_empty   ),
/*    output logic              */  .full       (packet_fifo_full    )
);

assign post_axis_in.axis_tready  = !packet_fifo_full && !data_fifo_full;
assign axis_out.axis_tvalid      = !packet_fifo_empty && !data_fifo_empty;
//---<< PACKET >>--------------------------------------
//--->> bytes counter <<-------------------------------
logic reset_w_bytes;
assign #1 reset_w_bytes = post_axis_in.axis_tvalid && post_axis_in.axis_tlast && post_axis_in.axis_tready;

always@(posedge axis_in.aclk,negedge axis_in.aresetn)
    if(~axis_in.aresetn)    w_bytes_total   <= '0;
    else begin
        if(reset_w_bytes)
                w_bytes_total   <= '0;
        else if(post_axis_in.axis_tvalid && post_axis_in.axis_tready && !all_nokeep)
                w_bytes_total   <= w_bytes_total + 1'b1;
        else    w_bytes_total   <= w_bytes_total;
    end

logic [15:0]    out_cnt;

always@(posedge axis_out.aclk,negedge axis_out.aresetn)
    if(~axis_out.aresetn)   out_cnt <= '0;
    else begin
        if(axis_out.axis_tvalid && axis_out.axis_tlast && axis_out.axis_tready)
                out_cnt   <= '0;
        else if(axis_out.axis_tvalid && axis_out.axis_tready)
                out_cnt   <= out_cnt + 1'b1;
        else    out_cnt   <= out_cnt;
    end
//---<< bytes counter >>-------------------------------
//--->> READ LAST <<-----------------------------------
logic   native_last;

always@(posedge axis_out.aclk,negedge axis_out.aresetn)
    if(~axis_out.aresetn) native_last   <= 1'b0;
    else begin
        if(axis_out.axis_tvalid && native_last && axis_out.axis_tready)
                native_last <= 1'b0;
        else if(out_cnt == (r_bytes_total-1) && axis_out.axis_tvalid  && axis_out.axis_tready && !r_last_nokeep)
                native_last <= 1'b1;
        else if(out_cnt == (r_bytes_total-2) && axis_out.axis_tvalid  && axis_out.axis_tready && r_last_nokeep)
                native_last <= 1'b1;
        else    native_last <= native_last;
    end

assign axis_out.axis_tlast  = native_last || r_total_eq_1;
//---<< READ LAST >>-----------------------------------
endmodule
