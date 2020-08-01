/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.1 2018-4-19 12:22:05
    use data_c_pipe_in to replace data_connect_pipe_inf
creaded: 2017/9/25 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_connect_pipe_with_info #(
    parameter IFSIZE = 32
)(
    input [IFSIZE-1:0]         info_in,
    output logic[IFSIZE-1:0]   info_out,
    (* up_stream = "true" *)
    axi_stream_inf.slaver      axis_in,
    (* down_stream = "true" *)
    axi_stream_inf.master      axis_out
);

import SystemPkg::*;

initial begin
    assert(axis_in.DSIZE == axis_out.DSIZE)
    else $error("SLAVER AXIS DSIZE != MASTER AXIS DSIZE");
end

wire    clock,rst_n;

assign  clock   = axis_in.aclk;
assign  rst_n   = axis_in.aresetn;

//
// logic[axis_in.DSIZE+1+1+axis_in.KSIZE+IFSIZE-1:0]        pipe_data_in,pipe_data_out;
//
// logic                   to_up_ready     ;
// logic                   from_down_ready ;
//
// assign pipe_data_in      = {info_in,axis_in.axis_tkeep,axis_in.axis_tuser,axis_in.axis_tlast,axis_in.axis_tdata};
// // assign pipe_data_in[DSIZE]          = axis_in.axis_tlast;
// // assign pipe_data_in[DSIZE+1]        = axis_in.axis_tuser;
// // assign pipe_data_in[DSIZE+2+:KSIZE] = axis_in.axis_tkeep;
// assign axis_in.axis_tready          = to_up_ready;
//
// assign axis_out.axis_tdata          = pipe_data_out[axis_in.DSIZE-1:0]      ;
// assign axis_out.axis_tlast          = pipe_data_out[axis_in.DSIZE]          ;
// assign axis_out.axis_tuser          = pipe_data_out[axis_in.DSIZE+1]        ;
// assign axis_out.axis_tkeep          = pipe_data_out[axis_in.DSIZE+2+:axis_in.KSIZE] ;
// assign from_down_ready              = axis_out.axis_tready          ;
//
// assign info_out                     = pipe_data_out[axis_in.DSIZE+2+axis_in.KSIZE+:IFSIZE];
//
// data_connect_pipe #(
//     .DSIZE  (axis_in.DSIZE+1+1+axis_in.KSIZE+IFSIZE)
// )data_connect_pipe_inst(
// /*    input             */  .clock             (clock           ),
// /*    input             */  .rst_n             (rst_n           ),
// /*    input             */  .clk_en            (axis_in.aclken  ),
// /*    input             */  .from_up_vld       (axis_in.axis_tvalid     ),
// /*    input [DSIZE-1:0] */  .from_up_data      (pipe_data_in            ),
// /*    output            */  .to_up_ready       (to_up_ready             ),
// /*    input             */  .from_down_ready   (from_down_ready         ),
// /*    output            */  .to_down_vld       (axis_out.axis_tvalid    ),
// /*    output[DSIZE-1:0] */  .to_down_data      (pipe_data_out           )
// );

data_inf_c#(axis_in.DSIZE+1+1+axis_in.KSIZE+IFSIZE) pre_data_inf (clock,rst_n);
data_inf_c#(axis_in.DSIZE+1+1+axis_in.KSIZE+IFSIZE) post_data_inf (clock,rst_n);

data_c_pipe_inf data_c_pipe_inf_inst(
/*  data_inf_c.slaver  */   .slaver     (pre_data_inf           ),
/*  data_inf_c.master  */   .master     (post_data_inf          )
);

assign pre_data_inf.valid   = axis_in.axis_tvalid;
assign pre_data_inf.data    = {info_in,axis_in.axis_tkeep,axis_in.axis_tuser,axis_in.axis_tlast,axis_in.axis_tdata};
assign axis_in.axis_tready  = pre_data_inf.ready;

assign axis_out.axis_tvalid = post_data_inf.valid;
assign axis_out.axis_tdata  = post_data_inf.data[axis_in.DSIZE-1:0];
assign axis_out.axis_tlast  = post_data_inf.data[axis_in.DSIZE]          ;
assign axis_out.axis_tuser  = post_data_inf.data[axis_in.DSIZE+1]        ;
assign axis_out.axis_tkeep  = post_data_inf.data[axis_in.DSIZE+2+:axis_in.KSIZE] ;

assign post_data_inf.ready  = axis_out.axis_tready;

assign info_out             = post_data_inf.data[axis_in.DSIZE+2+axis_in.KSIZE+:IFSIZE];

endmodule
