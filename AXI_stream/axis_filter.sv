/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
    build from axis_valve
creaded: 22017/7/21 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_filter (
    input                      button,          //[1] pass ; [0] filter
    (* up_stream = "true" *)
    axi_stream_inf.slaver      axis_in,
    (* down_stream = "true" *)
    axi_stream_inf.master      axis_out
);

axi_stream_inf #(.DSIZE(axis_in.DSIZE)) filter_inf  (.aclk(axis_in.aclk),.aresetn(axis_in.aresetn),.aclken(axis_in.aclken));


assign filter_inf.axis_tdata          = axis_in.axis_tdata;
assign filter_inf.axis_tlast          = axis_in.axis_tlast;
assign filter_inf.axis_tvalid         = axis_in.axis_tvalid;
assign filter_inf.axis_tkeep          = axis_in.axis_tkeep;
assign filter_inf.axis_tuser          = axis_in.axis_tuser;
assign axis_in.axis_tready            = filter_inf.axis_tready || !button;

axis_valve axis_valve_inst(
/*  input                   */   .button        (button         ),          //[1] OPEN ; [0] CLOSE
/*  axi_stream_inf.slaver   */   .axis_in       (filter_inf     ),
/*  axi_stream_inf.master   */   .axis_out      (axis_out       )
);;

endmodule
