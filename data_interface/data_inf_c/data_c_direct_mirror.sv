/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:   covert A to B
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/12/14 
madified:
***********************************************/
`timescale 1ns/1ps
(* data_inf_c = "true" *)
module data_c_direct_mirror (
    (* data_up = "true" *)
    data_inf_c.mirror         slaver,
    (* data_down = "true" *)
    data_inf_c.out_mirror     master
);
// genvar KK;
// generate
// for(KK=0;KK<NUM;KK++)begin
    assign master.ready     = slaver.ready;
    assign master.valid     = slaver.valid;
    assign master.data      = slaver.data;
// end
// endgenerate

endmodule
