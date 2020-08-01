interface axi_wr_aux_inf();

logic[2:0]        axi_awsize    ;
logic[1:0]        axi_awburst   ;
logic[0:0]        axi_awlock    ;
logic[3:0]        axi_awcache   ;
logic[2:0]        axi_awprot    ;
logic[3:0]        axi_awqos     ;

modport master (
output    axi_awsize   ,
output    axi_awburst  ,
output    axi_awlock   ,
output    axi_awcache  ,
output    axi_awprot   ,
output    axi_awqos
);

modport slaver (
input     axi_awsize   ,
input     axi_awburst  ,
input     axi_awlock   ,
input     axi_awcache  ,
input     axi_awprot   ,
input     axi_awqos
);

endinterface : axi_wr_aux_inf

interface axi_rd_aux_inf();

logic[2:0]        axi_arsize    ;
logic[1:0]        axi_arburst   ;
logic[0:0]        axi_arlock    ;
logic[3:0]        axi_arcache   ;
logic[2:0]        axi_arprot    ;
logic[3:0]        axi_arqos     ;

modport master (
output    axi_arsize   ,
output    axi_arburst  ,
output    axi_arlock   ,
output    axi_arcache  ,
output    axi_arprot   ,
output    axi_arqos
);

modport slaver (
input     axi_arsize   ,
input     axi_arburst  ,
input     axi_arlock   ,
input     axi_arcache  ,
input     axi_arprot   ,
input     axi_arqos
);

endinterface : axi_rd_aux_inf

interface axi_aw_inf #(
    parameter IDSIZE    = 1,
    parameter ASIZE     = 32,
    parameter LSIZE     = 1
)();

logic[IDSIZE-1:0] axi_awid      ;
logic[ASIZE-1:0]  axi_awaddr    ;
logic[LSIZE-1:0]  axi_awlen     ;
logic             axi_awvalid   ;
logic             axi_awready   ;

modport master (
output    axi_awid   ,
output    axi_awaddr ,
output    axi_awlen  ,
output    axi_awvalid,
input     axi_awready
);

modport slaver (
input    axi_awid   ,
input    axi_awaddr ,
input    axi_awlen  ,
input    axi_awvalid,
output   axi_awready
);

endinterface : axi_aw_inf

interface axi_ar_inf #(
    parameter IDSIZE    = 1,
    parameter ASIZE     = 32,
    parameter LSIZE     = 1
)();

logic[IDSIZE-1:0] axi_arid      ;
logic[ASIZE-1:0]  axi_araddr    ;
logic[LSIZE-1:0]  axi_arlen     ;
logic             axi_arvalid   ;
logic             axi_arready   ;

modport master (
output    axi_arid   ,
output    axi_araddr ,
output    axi_arlen  ,
output    axi_arvalid,
input     axi_arready
);

modport slaver (
input    axi_arid   ,
input    axi_araddr ,
input    axi_arlen  ,
input    axi_arvalid,
output   axi_arready
);

endinterface : axi_ar_inf

interface axi_wdata_inf #(
    parameter DSIZE = 32
)();

localparam STSIZE = DSIZE/8+(DSIZE%8 != 0);

logic[DSIZE-1:0]  axi_wdata     ;
logic[STSIZE-1:0] axi_wstrb     ;
logic             axi_wlast     ;
logic             axi_wvalid    ;
logic             axi_wready    ;

modport master (
output axi_wdata     ,
output axi_wstrb     ,
output axi_wlast     ,
output axi_wvalid    ,
input  axi_wready
);

modport slaver (
input  axi_wdata     ,
input  axi_wstrb     ,
input  axi_wlast     ,
input  axi_wvalid    ,
output axi_wready
);

endinterface : axi_wdata_inf

interface axi_rdata_inf #(
    parameter DSIZE     = 32,
    parameter IDSIZE    = 1
)();


logic[IDSIZE-1:0] axi_rid       ;
logic[DSIZE-1:0]  axi_rdata     ;
logic[1:0]        axi_rresp     ;
logic             axi_rlast     ;
logic             axi_rvalid    ;
logic             axi_rready    ;

modport master (
input    axi_rid       ,
input    axi_rdata     ,
input    axi_rresp     ,
input    axi_rlast     ,
input    axi_rvalid    ,
output   axi_rready
);

modport slaver (
output   axi_rid       ,
output   axi_rdata     ,
output   axi_rresp     ,
output   axi_rlast     ,
output   axi_rvalid    ,
input    axi_rready
);


endinterface : axi_rdata_inf

interface axi_resp_inf #(
    parameter IDSIZE = 1
)();

logic             axi_bready    ;
logic[IDSIZE-1:0] axi_bid       ;
logic[1:0]        axi_bresp     ;
logic             axi_bvalid    ;

modport master (
output axi_bready    ,
input  axi_bid       ,
input  axi_bresp     ,
input  axi_bvalid
);

modport slaver (
input  axi_bready    ,
output axi_bid       ,
output axi_bresp     ,
output axi_bvalid
);

endinterface : axi_resp_inf
