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
module axi_lite_master_empty(
    (* axil_down = "true" *)
    axi_lite_inf.master     lite
);


assign    lite.axi_awvalid     = '0;
assign    lite.axi_awaddr      = '0;
assign    lite.axi_awlock      = '0;
assign    lite.axi_wvalid      = '0;
assign    lite.axi_wdata       = '0;
assign    lite.axi_bready      = '1;
assign    lite.axi_arvalid     = '0;
assign    lite.axi_araddr      = '0;
assign    lite.axi_arlock      = '0;
assign    lite.axi_rready      = '1;

endmodule
