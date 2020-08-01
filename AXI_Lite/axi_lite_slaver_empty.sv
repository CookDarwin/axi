/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/11/10 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_lite = "true" *)
module axi_lite_slaver_empty(
    (* axil_up = "true" *)
    axi_lite_inf.slaver     lite
);


assign  lite.axi_awready     = '1;
assign  lite.axi_wready      = '1;
assign  lite.axi_bresp       = '0;
assign  lite.axi_bvalid      = '0;
assign  lite.axi_arready     = '1;
assign  lite.axi_rvalid      = '0;
assign  lite.axi_rdata       = '0;

endmodule
