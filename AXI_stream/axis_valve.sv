/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/1/19 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_valve (
    input                      button,          //[1] OPEN ; [0] CLOSE
    (* up_stream = "true" *)
    axi_stream_inf.slaver      axis_in,
    (* down_stream = "true" *)
    axi_stream_inf.master      axis_out
);

assign axis_out.axis_tdata          = axis_in.axis_tdata;
assign axis_out.axis_tlast          = axis_in.axis_tlast && button;
assign axis_out.axis_tvalid         = axis_in.axis_tvalid && button;
assign axis_out.axis_tkeep          = axis_in.axis_tkeep;
assign axis_out.axis_tuser          = axis_in.axis_tuser;
assign axis_in.axis_tready          = axis_out.axis_tready && button;


endmodule
