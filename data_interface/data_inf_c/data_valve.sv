/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/7/27 
madified:
***********************************************/
`timescale 1ns/1ps
(* data_inf_c = "true" *)
module data_valve (
    input                       button,          //[1] OPEN ; [0] CLOSE
    (* up_stream = "true" *)
    data_inf_c.slaver             data_in,
    (* down_stream = "true" *)
    data_inf_c.master             data_out
);

assign data_out.data          = data_in.data;
assign data_out.valid         = data_in.valid && button;
assign data_in.ready          = data_out.ready && button;


endmodule
