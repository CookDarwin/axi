/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.1 2018-4-17 11:11:39
    data_c_pipe_inf replace data_connect_pipe
creaded: 2016/12/8 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_connect_pipe (
    (* up_stream = "true" *)
    axi_stream_inf.slaver      axis_in,
    (* down_stream = "true" *)
    axi_stream_inf.master      axis_out
);

// parameter DSIZE = axis_in.DSIZE;
// parameter KSIZE = (DSIZE/8 > 0)? DSIZE/8 : 1;

import SystemPkg::*;

initial begin
    assert(axis_in.DSIZE == axis_out.DSIZE)
    else $error("SLAVER AXIS DSIZE != MASTER AXIS DSIZE");
end

wire    clock,rst_n;

assign  clock   = axis_in.aclk;
assign  rst_n   = axis_in.aresetn;


// logic[DSIZE+1+1+KSIZE-1:0]        pipe_data_in,pipe_data_out;
//
// logic                   to_up_ready     ;
// logic                   from_down_ready ;
//
// assign pipe_data_in      = {axis_in.axis_tkeep,axis_in.axis_tuser,axis_in.axis_tlast,axis_in.axis_tdata};
// // assign pipe_data_in[DSIZE]          = axis_in.axis_tlast;
// // assign pipe_data_in[DSIZE+1]        = axis_in.axis_tuser;
// // assign pipe_data_in[DSIZE+2+:KSIZE] = axis_in.axis_tkeep;
// assign axis_in.axis_tready          = to_up_ready;
//
// assign axis_out.axis_tdata          = pipe_data_out[DSIZE-1:0]      ;
// assign axis_out.axis_tlast          = pipe_data_out[DSIZE]          ;
// assign axis_out.axis_tuser          = pipe_data_out[DSIZE+1]        ;
// assign axis_out.axis_tkeep          = pipe_data_out[DSIZE+2+:KSIZE] ;
// assign from_down_ready              = axis_out.axis_tready          ;

// data_connect_pipe #(
//     .DSIZE  (DSIZE+1+1+KSIZE)
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

data_inf_c #(axis_in.DSIZE+axis_in.KSIZE+1) slaver_inf (clock,rst_n);
data_inf_c #(axis_in.DSIZE+axis_in.KSIZE+1) master_inf (clock,rst_n);

axis_full_to_data_c axis_full_to_data_c_inst(
/*  axi_stream_inf.slaver */ .axis_in           (axis_in    ),
/*  data_inf_c.master     */ .data_out_inf      (slaver_inf )
);

data_c_pipe_inf data_c_pipe_inf_inst(
/*  data_inf_c.slaver   */  .slaver     (slaver_inf ),
/*  data_inf_c.master   */  .master     (master_inf )
);

data_c_to_axis_full data_c_to_axis_full_inst(
/*  data_inf_c.slaver     */ .data_in_inf       (master_inf ),
/*  axi_stream_inf.master */ .axis_out          (axis_out   )
);

endmodule
