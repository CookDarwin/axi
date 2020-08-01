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
module xilinx_axi4_to_axi4 (
    input   [31:0]   MBZ_AXI_araddr,
    input   [1:0]    MBZ_AXI_arburst,
    input   [3:0]    MBZ_AXI_arcache,
    input   [7:0]    MBZ_AXI_arlen,
    input   [0:0]    MBZ_AXI_arlock,
    input   [2:0]    MBZ_AXI_arprot,
    input   [3:0]    MBZ_AXI_arqos,
    output           MBZ_AXI_arready,
    input   [3:0]    MBZ_AXI_arregion,
    input   [2:0]    MBZ_AXI_arsize,
    input            MBZ_AXI_arvalid,
    input   [31:0]   MBZ_AXI_awaddr,
    input   [1:0]    MBZ_AXI_awburst,
    input   [3:0]    MBZ_AXI_awcache,
    input   [7:0]    MBZ_AXI_awlen,
    input   [0:0]    MBZ_AXI_awlock,
    input   [2:0]    MBZ_AXI_awprot,
    input   [3:0]    MBZ_AXI_awqos,
    output           MBZ_AXI_awready,
    input   [3:0]    MBZ_AXI_awregion,
    input   [2:0]    MBZ_AXI_awsize,
    input            MBZ_AXI_awvalid,
    input            MBZ_AXI_bready,
    output [1:0]     MBZ_AXI_bresp,
    output           MBZ_AXI_bvalid,
    output [31:0]    MBZ_AXI_rdata,
    output           MBZ_AXI_rlast,
    input            MBZ_AXI_rready,
    output [1:0]     MBZ_AXI_rresp,
    output           MBZ_AXI_rvalid,
    input   [31:0]   MBZ_AXI_wdata,
    input            MBZ_AXI_wlast,
    output           MBZ_AXI_wready,
    input   [3:0]    MBZ_AXI_wstrb,
    input            MBZ_AXI_wvalid,
    axi_inf.master   axi4
);

assign   axi4.axi_araddr  = MBZ_AXI_araddr;
assign   axi4.axi_arburst = MBZ_AXI_arburst;
assign   axi4.axi_arcache = MBZ_AXI_arcache;
assign   axi4.axi_arlen   = MBZ_AXI_arlen;
assign   axi4.axi_arlock  = MBZ_AXI_arlock;
assign   axi4.axi_arprot  = MBZ_AXI_arprot;
assign   axi4.axi_arqos   = MBZ_AXI_arqos;
assign   MBZ_AXI_arready  = axi4.axi_arready;
// input   [3:0]    MBZ_AXI_arregion,
assign   axi4.axi_arsize  =  MBZ_AXI_arsize;
assign   axi4.axi_arvalid =  MBZ_AXI_arvalid;
assign   axi4.axi_awaddr  =  MBZ_AXI_awaddr;
assign   axi4.axi_awburst =  MBZ_AXI_awburst;
assign   axi4.axi_awcache =  MBZ_AXI_awcache;
assign   axi4.axi_awlen   =  MBZ_AXI_awlen;
assign   axi4.axi_awlock  =  MBZ_AXI_awlock;
assign   axi4.axi_awprot  =  MBZ_AXI_awprot;
assign   axi4.axi_awqos   =  MBZ_AXI_awqos;
assign   MBZ_AXI_awready  = axi4.axi_awready;
// input   [3:0]    MBZ_AXI_awregion,
assign   axi4.axi_awsize  =  MBZ_AXI_awsize;
assign   axi4.axi_awvalid =  MBZ_AXI_awvalid;
assign   axi4.axi_bready  =  MBZ_AXI_bready;
assign   MBZ_AXI_bresp    = axi4.axi_bresp;
assign   MBZ_AXI_bvalid   = axi4.axi_bvalid;
assign   MBZ_AXI_rdata    = axi4.axi_rdata;
assign   MBZ_AXI_rlast    = axi4.axi_rlast;
assign   axi4.axi_rready  = MBZ_AXI_rready;
assign   MBZ_AXI_rresp    = '0;
assign   MBZ_AXI_rvalid   = axi4.axi_rvalid;
assign   axi4.axi_wdata   = MBZ_AXI_wdata;
assign   axi4.axi_wlast   = MBZ_AXI_wlast;
assign   MBZ_AXI_wready   = axi4.axi_wready;
assign   axi4.axi_wstrb   = MBZ_AXI_wstrb;
assign   axi4.axi_wvalid  = MBZ_AXI_wvalid;

endmodule
