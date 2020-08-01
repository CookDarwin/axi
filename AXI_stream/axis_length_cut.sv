/**********************************************
______________   ______________
______________ X ______________
______________  ______________

descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/5/12 
madified:
***********************************************/
`timescale 1ns/1ps
module axis_length_cut (
    input [31:0]           length,
    axi_stream_inf.slaver  axis_in,
    axi_stream_inf.master  axis_out
);

wire    clock,rst_n,clken;

assign  clock   = axis_in.aclk;
assign  rst_n   = axis_in.aresetn;
assign  clken   = axis_in.aclken;

axi_stream_inf #(.DSIZE(axis_in.DSIZE)) axis_pre (.aclk(clock),.aresetn(rst_n),.aclken(clken));

logic   new_last;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  new_last    <= 1'b0;
    else begin
        if(axis_in.axis_tvalid  && axis_in.axis_tready && axis_in.axis_tcnt==(length-2))
                new_last    <= 1'b1;
        else if(axis_in.axis_tvalid  && axis_in.axis_tready && (new_last||axis_in.axis_tlast))
                new_last    <= 1'b0;
        else    new_last    <= new_last;
    end

logic   mark_tail;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  mark_tail   <= 1'b0;
    else begin
        if(axis_in.axis_tvalid  && axis_in.axis_tready && axis_in.axis_tlast)
                mark_tail   <= 1'b0;
        else if(axis_in.axis_tvalid  && axis_in.axis_tready && axis_in.axis_tcnt==(length-1))
                mark_tail   <= 1'b1;
        else    mark_tail   <= mark_tail;
    end

assign axis_pre.axis_tvalid = axis_in.axis_tvalid && !mark_tail;
assign axis_pre.axis_tdata  = axis_in.axis_tdata;
assign axis_pre.axis_tlast  = new_last || (!mark_tail && axis_in.axis_tlast);
assign axis_pre.axis_tkeep  = axis_in.axis_tkeep;
assign axis_pre.axis_tuser  = axis_in.axis_tuser;

assign axis_in.axis_tready  = axis_pre.axis_tready;

axis_connect_pipe axis_connect_pipe_inst(
/*  axi_stream_inf.slaver  */  .axis_in     (axis_pre   ),
/*  axi_stream_inf.master  */  .axis_out    (axis_out   )
);

endmodule
