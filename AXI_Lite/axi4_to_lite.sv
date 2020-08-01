/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/7/14 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_to_lite(
    axi_inf.slaver          axi4,
    axi_lite_inf.master     lite
);


assign lite.axi_awvalid     = axi4.axi_awvalid;
assign axi4.axi_awready     = lite.axi_awready;
assign lite.axi_awaddr      = axi4.axi_awaddr;
assign lite.axi_awlock      = axi4.axi_awlock;
assign lite.axi_wvalid      = axi4.axi_wvalid;
assign axi4.axi_wready      = lite.axi_wready;
assign lite.axi_wdata       = axi4.axi_wdata;
assign axi4.axi_bresp       = lite.axi_bresp;
assign axi4.axi_bvalid      = lite.axi_bvalid;
assign lite.axi_bready      = axi4.axi_bready;
assign lite.axi_arvalid     = axi4.axi_arvalid;
assign axi4.axi_arready     = lite.axi_arready;
assign lite.axi_araddr      = axi4.axi_araddr;
assign lite.axi_arlock      = axi4.axi_arlock;
assign axi4.axi_rvalid      = lite.axi_rvalid;
assign lite.axi_rready      = axi4.axi_rready;
assign axi4.axi_rdata       = lite.axi_rdata;

endmodule
