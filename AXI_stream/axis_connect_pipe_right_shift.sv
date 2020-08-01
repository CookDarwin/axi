/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0 ###### Wed Apr 29 19:12:51 CST 2020
    use 
    data_c_pipe_inf_right_shift
creaded: ###### Wed Apr 29 19:13:07 CST 2020
madified:
***********************************************/
`timescale 1ns/1ps
module axis_connect_pipe_right_shift #(
    parameter SHIFT_BITS  = 1
)(
    axi_stream_inf.slaver      axis_in,
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


data_inf_c #(axis_in.DSIZE) slaver_inf (clock,rst_n);
data_inf_c #(axis_in.DSIZE) master_inf (clock,rst_n);

// axis_full_to_data_c axis_full_to_data_c_inst(
// /*  axi_stream_inf.slaver */ .axis_in           (axis_in    ),
// /*  data_inf_c.master     */ .data_out_inf      (slaver_inf )
// );
assign  slaver_inf.data     = axis_in.axis_tdata;
assign  slaver_inf.valid    = axis_in.axis_tvalid;
assign  axis_in.axis_tready = slaver_inf.ready;

data_c_pipe_inf_right_shift #(
    .SHIFT_BITS (SHIFT_BITS),
    .EX_SIZE    (1)
) data_c_pipe_inf_inst(
/*  input [EX_SIZE-1:0]       */  .ex_in      (axis_in.axis_tlast   ),
/*  output logic[EX_SIZE-1:0] */  .ex_out     (axis_out.axis_tlast  ),
/*  data_inf_c.slaver         */  .slaver     (slaver_inf ),
/*  data_inf_c.master         */  .master     (master_inf )
);

// data_c_to_axis_full data_c_to_axis_full_inst(
// /*  data_inf_c.slaver     */ .data_in_inf       (master_inf ),
// /*  axi_stream_inf.master */ .axis_out          (axis_out   )
// );

assign axis_out.axis_tdata      = master_inf.data;
assign axis_out.axis_tvalid     = master_inf.valid;
assign master_inf.ready         = axis_out.axis_tready;

endmodule
