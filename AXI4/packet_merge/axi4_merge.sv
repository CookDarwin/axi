/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    out of last
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/30 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_merge #(
    parameter MAX = 8
)(
    axi_inf.slaver slaver,
    axi_inf.master master
);

axi4_merge_rd #(
   .MAX         (MAX    )                 //MUST LARGER THAN 2
)axi4_merge_rd_inst(
/* axi_inf.slaver_rd */ .slaver     (slaver ),           //Out of Last
/* axi_inf.master_rd */ .master     (master )            //Out of Last
);

//--->> WRITE CAN'T MERGE ,Because AXI4 WR don't support O-o-D
// axi4_merge_wr #(
//    .MAX         (MAX    )                 //MUST LARGER THAN 2
// )axi4_merge_wr_inst(
// /* axi_inf.slaver_wr */ .slaver     (slaver ),           //Out of Last
// /* axi_inf.master_wr */ .master     (master )            //Out of Last
// );

assign master.axi_awid      = slaver.axi_awid   ;
assign master.axi_awaddr    = slaver.axi_awaddr ;
assign master.axi_awlen     = slaver.axi_awlen  ;
assign master.axi_awsize    = slaver.axi_awsize ;
assign master.axi_awburst   = slaver.axi_awburst;
assign master.axi_awlock    = slaver.axi_awlock ;
assign master.axi_awcache   = slaver.axi_awcache;
assign master.axi_awprot    = slaver.axi_awprot ;
assign master.axi_awqos     = slaver.axi_awqos  ;
assign master.axi_awvalid   = slaver.axi_awvalid;
assign slaver.axi_awready   = master.axi_awready;

assign master.axi_bready    = slaver.axi_bready;
assign slaver.axi_bid       = master.axi_bid   ;
assign slaver.axi_bresp     = master.axi_bresp ;
assign slaver.axi_bvalid    = master.axi_bvalid;

assign master.axi_wdata     = slaver.axi_wdata   ;
assign master.axi_wstrb     = slaver.axi_wstrb   ;
assign master.axi_wlast     = slaver.axi_wlast   ;
assign master.axi_wvalid    = slaver.axi_wvalid  ;
assign slaver.axi_wready    = master.axi_wready  ;



endmodule
