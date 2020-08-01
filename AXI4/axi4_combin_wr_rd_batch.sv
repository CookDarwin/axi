/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/10/26 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi4 = "true" *)
module axi4_combin_wr_rd_batch (
    axi_inf.slaver_wr      wr_slaver,
    axi_inf.slaver_rd      rd_slaver,
    axi_inf.master         master
);


assign    master.axi_awid    = wr_slaver.axi_awid    ;
assign    master.axi_awaddr  = wr_slaver.axi_awaddr  ;
assign    master.axi_awlen   = wr_slaver.axi_awlen   ;
assign    master.axi_awsize  = wr_slaver.axi_awsize  ;
assign    master.axi_awburst = wr_slaver.axi_awburst ;
assign    master.axi_awlock  = wr_slaver.axi_awlock  ;
assign    master.axi_awcache = wr_slaver.axi_awcache ;
assign    master.axi_awprot  = wr_slaver.axi_awprot  ;
assign    master.axi_awqos   = wr_slaver.axi_awqos   ;
assign    master.axi_awvalid = wr_slaver.axi_awvalid ;
assign    wr_slaver.axi_awready = master.axi_awready;
assign    master.axi_wdata   = wr_slaver.axi_wdata  ;
assign    master.axi_wstrb   = wr_slaver.axi_wstrb  ;
assign    master.axi_wlast   = wr_slaver.axi_wlast  ;
assign    master.axi_wvalid  = wr_slaver.axi_wvalid ;
assign    wr_slaver.axi_wready = master.axi_wready;
assign    master.axi_bready  = wr_slaver.axi_bready  ;
assign    wr_slaver.axi_bid    = master.axi_bid   ;
assign    wr_slaver.axi_bresp  = master.axi_bresp ;
assign    wr_slaver.axi_bvalid = master.axi_bvalid;

assign    master.axi_arid     = rd_slaver.axi_arid   ;
assign    master.axi_araddr   = rd_slaver.axi_araddr ;
assign    master.axi_arlen    = rd_slaver.axi_arlen  ;
assign    master.axi_arsize   = rd_slaver.axi_arsize ;
assign    master.axi_arburst  = rd_slaver.axi_arburst;
assign    master.axi_arlock   = rd_slaver.axi_arlock ;
assign    master.axi_arcache  = rd_slaver.axi_arcache;
assign    master.axi_arprot   = rd_slaver.axi_arprot ;
assign    master.axi_arqos    = rd_slaver.axi_arqos  ;
assign    master.axi_arvalid  = rd_slaver.axi_arvalid;
assign    rd_slaver.axi_arready = master.axi_arready;
assign    master.axi_rready   = rd_slaver.axi_rready ;
assign    rd_slaver.axi_rid   = master.axi_rid   ;
assign    rd_slaver.axi_rdata = master.axi_rdata ;
assign    rd_slaver.axi_rresp = master.axi_rresp ;
assign    rd_slaver.axi_rlast = master.axi_rlast ;
assign    rd_slaver.axi_rvalid= master.axi_rvalid;

endmodule
