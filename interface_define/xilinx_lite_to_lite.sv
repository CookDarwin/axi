/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/7/13 
madified:
***********************************************/
`timescale 1ns/1ps
module xilinx_axi_to_lite #(
    parameter ASIZE     = 32,
    parameter DSIZE     = 32
)(
    input               s_axi_aclk,
    input               s_axi_aresetn,
    input [ASIZE-1:0]   s_axi_awaddr,
    input               s_axi_awvalid,
    output              s_axi_awready,
    input [DSIZE-1:0]   s_axi_wdata,
    input [DSIZE/8-1:0] s_axi_wstrb,
    input               s_axi_wvalid,
    output              s_axi_wready,
    output [1:0]        s_axi_bresp,
    output              s_axi_bvalid,
    input               s_axi_bready,
    input [ASIZE-1:0]   s_axi_araddr,
    input               s_axi_arvalid,
    output              s_axi_arready,
    output [DSIZE-1:0]  s_axi_rdata,
    output [1:0]        s_axi_rresp,
    output              s_axi_rvalid,
    input               s_axi_rready,
    axi_lite_inf.master lite
);

assign lite.axi_awaddr      = s_axi_awaddr;
assign lite.axi_awvalid     = s_axi_awvalid;
assign lite.axi_wdata       = s_axi_wdata;
// assign lite.axi_wstrb       = s_axi_wstrb;
assign lite.axi_wvalid      = s_axi_wvalid;
assign lite.axi_bready      = s_axi_bready;
assign lite.axi_araddr      = s_axi_araddr;
assign lite.axi_arvalid     = s_axi_arvalid;
assign lite.axi_rready      = s_axi_rready;

// always@(*)begin
//     lite.axi_awaddr      = s_axi_awaddr;
//     lite.axi_awvalid     = s_axi_awvalid;
//     lite.axi_wdata       = s_axi_wdata;
//     lite.axi_wvalid      = s_axi_wvalid;
//     lite.axi_bready      = s_axi_bready;
//     lite.axi_araddr      = s_axi_araddr;
//     lite.axi_arvalid     = s_axi_arvalid;
//     lite.axi_rready      = s_axi_rready;
// end


assign s_axi_wready         = lite.axi_wready;
assign s_axi_bresp          = lite.axi_bresp;
assign s_axi_bvalid         = lite.axi_bvalid;
assign s_axi_awready        = lite.axi_awready;
assign s_axi_arready        = lite.axi_arready;
assign s_axi_rdata          = lite.axi_rdata;
assign s_axi_rresp          = '0;
assign s_axi_rvalid         = lite.axi_rvalid;

endmodule

module xilinx_axi_to_lite_inf2 #(
    parameter ASIZE     = 32,
    parameter DSIZE     = 32
)(
    input                   s_axi_aclk,
    input                   s_axi_aresetn,
    input [ASIZE-1:0]       s_axi_awaddr,
    input                   s_axi_awvalid,
    output                  s_axi_awready,
    input [DSIZE-1:0]       s_axi_wdata,
    input [DSIZE/8-1:0]     s_axi_wstrb,
    input                   s_axi_wvalid,
    output                  s_axi_wready,
    output [1:0]            s_axi_bresp,
    output                  s_axi_bvalid,
    input                   s_axi_bready,
    input [ASIZE-1:0]       s_axi_araddr,
    input                   s_axi_arvalid,
    output                  s_axi_arready,
    output [DSIZE-1:0]      s_axi_rdata,
    output [1:0]            s_axi_rresp,
    output                  s_axi_rvalid,
    input                   s_axi_rready,
    axi_lite_inf2.master    lite
);

assign lite.axi_awaddr      = s_axi_awaddr;
assign lite.axi_awvalid     = s_axi_awvalid;
assign lite.axi_wdata       = s_axi_wdata;
// assign lite.axi_wstrb       = s_axi_wstrb;
assign lite.axi_wvalid      = s_axi_wvalid;
assign lite.axi_bready      = s_axi_bready;
assign lite.axi_araddr      = s_axi_araddr;
assign lite.axi_arvalid     = s_axi_arvalid;
assign lite.axi_rready      = s_axi_rready;

// always@(*)begin
//     lite.axi_awaddr      = s_axi_awaddr;
//     lite.axi_awvalid     = s_axi_awvalid;
//     lite.axi_wdata       = s_axi_wdata;
//     lite.axi_wvalid      = s_axi_wvalid;
//     lite.axi_bready      = s_axi_bready;
//     lite.axi_araddr      = s_axi_araddr;
//     lite.axi_arvalid     = s_axi_arvalid;
//     lite.axi_rready      = s_axi_rready;
// end


assign s_axi_wready         = lite.axi_wready;
assign s_axi_bresp          = lite.axi_bresp;
assign s_axi_bvalid         = lite.axi_bvalid;
assign s_axi_awready        = lite.axi_awready;
assign s_axi_arready        = lite.axi_arready;
assign s_axi_rdata          = lite.axi_rdata;
assign s_axi_rresp          = '0;
assign s_axi_rvalid         = lite.axi_rvalid;

endmodule
