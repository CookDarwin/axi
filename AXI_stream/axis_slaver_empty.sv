/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/6/13 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_slaver_empty (
    (* axis_up = "true" *)
    axi_stream_inf.slaver       slaver
);

assign slaver.axis_tready = 1'b1;
// assign master.valid     = 1'b0;
// assign master.data      = '0;

endmodule
