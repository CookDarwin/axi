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
module axis_master_empty (
    (* axis_down = "true" *)
    axi_stream_inf.master       master
);

assign master.axis_tvalid = 1'b0;
assign master.axis_tdata  = '0;
assign master.axis_tuser  = '0;
assign master.axis_tlast  = 1'b0;
assign master.axis_tkeep  = '1;
// assign master.valid     = 1'b0;
// assign master.data      = '0;

endmodule
