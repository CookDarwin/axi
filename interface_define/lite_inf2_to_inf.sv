/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018-3-21 17:05:16
madified:
***********************************************/
`timescale 1ns/1ps
module lite_inf2_to_inf (
    axi_lite_inf2.slaver    lite2,
    axi_lite_inf.master     lite
);

always@(*)begin
    lite.axi_awaddr      = lite2.axi_awaddr;
    lite.axi_awvalid     = lite2.axi_awvalid;
    lite.axi_wdata       = lite2.axi_wdata;
    lite.axi_wvalid      = lite2.axi_wvalid;
    lite.axi_bready      = lite2.axi_bready;
    lite.axi_araddr      = lite2.axi_araddr;
    lite.axi_arvalid     = lite2.axi_arvalid;
    lite.axi_rready      = lite2.axi_rready;
end


assign lite2.axi_wready  = lite.axi_wready;
assign lite2.axi_bresp   = lite.axi_bresp;
assign lite2.axi_bvalid  = lite.axi_bvalid;
assign lite2.axi_awready = lite.axi_awready;
assign lite2.axi_arready = lite.axi_arready;
assign lite2.axi_rdata   = lite.axi_rdata;
//assign lite2.axi_rresp   = '0;
assign lite2.axi_rvalid  = lite.axi_rvalid;

endmodule
