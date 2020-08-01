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
(* datainf_c = "true" *)
module datainf_c_slaver_empty (
    (* data_up = "true" *)
    data_inf_c.slaver       slaver
);

assign slaver.ready = 1'b1;
// assign master.valid     = 1'b0;
// assign master.data      = '0;

endmodule
