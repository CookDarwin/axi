`timescale 1ns/1ps
`include "define_macro.sv"
interface axi_inf #(
    parameter IDSIZE    = 1,
    parameter ASIZE     = 32,
    parameter LSIZE     = 1,
    parameter DSIZE     = 32,
    `parameter_string MODE      = "BOTH",        //BOTH:0,ONLY_WRITE:1,ONLY_READ:2
    parameter ADDR_STEP = 32'hFFFF_FFFF,            // 1024 : 0
    parameter real FreqM    = 1
)(
    input bit axi_aclk      ,
    input bit axi_aresetn
);

initial begin
    if(MODE == "BOTH" || MODE == "ONLY_READ" || MODE == "ONLY_WRITE")
        #(1ps);
    else begin
        $error("$t,AXI INFTERFACE MODE PARAMETER ERROR >>%s<<",MODE);
        $finish;
    end
end

logic           timeout;

localparam STSIZE = DSIZE/8+(DSIZE%8 != 0);
//--->> addr write <<-------
logic[IDSIZE-1:0] axi_awid      ;
logic[ASIZE-1:0]  axi_awaddr    ;
logic[LSIZE-1:0]  axi_awlen     ;
logic[2:0]        axi_awsize    ;
logic[1:0]        axi_awburst   ;
logic[0:0]        axi_awlock    ;
logic[3:0]        axi_awcache   ;
logic[2:0]        axi_awprot    ;
logic[3:0]        axi_awqos     ;
logic             axi_awvalid   ;
logic             axi_awready   ;
//---<< addr write >>-------
//--->> addr read <<--------
logic[IDSIZE-1:0] axi_arid        ;
logic[ASIZE-1:0]  axi_araddr      ;
logic[LSIZE-1:0]  axi_arlen       ;
logic[2:0]        axi_arsize      ;
logic[1:0]        axi_arburst     ;
logic[0:0]        axi_arlock      ;
logic[3:0]        axi_arcache     ;
logic[2:0]        axi_arprot      ;
logic[3:0]        axi_arqos       ;
logic             axi_arvalid     ;
logic             axi_arready     ;
//---<< addr read >>--------
//--->> Response <<---------
logic             axi_bready    ;
logic[IDSIZE-1:0] axi_bid       ;
logic[1:0]        axi_bresp     ;
logic             axi_bvalid    ;
//---<< Response >>---------
//--->> data write <<-------
logic[DSIZE-1:0]  axi_wdata     ;
logic[STSIZE-1:0] axi_wstrb     ;
logic             axi_wlast     ;
logic             axi_wvalid    ;
logic             axi_wready    ;
//---<< data write >>-------
//--->> data read >>--------
logic             axi_rready    ;
logic[IDSIZE-1:0] axi_rid       ;
logic[DSIZE-1:0]  axi_rdata     ;
logic[1:0]        axi_rresp     ;
logic             axi_rlast     ;
logic             axi_rvalid    ;
//---<< data read >>--------
//--->> error flag <<-------
// logic             axi_wevld      ;
// logic[3:0]        axi_weresp     ;
// logic             axi_revld      ;
// logic[3:0]        axi_reresp     ;
//---<< error flag >>-------

//--->> TIME CTRL <<---------------
always@(posedge axi_aclk,negedge axi_aresetn)begin:TIME_BLOCK
logic   cen;
logic   crst;
logic [23:0]    tcnt;
    if(~axi_aresetn)begin
        tcnt    <= 24'd0;
        cen     <= 1'b0;
        crst    <= 1'b0;
    end else begin
        //-->> COUNT ENABLE
        if(axi_awready && axi_awvalid)
                cen     <= 1'b1;
        else if(axi_arready && axi_arvalid)
                cen     <= 1'b1;
        else if(axi_bready && axi_bvalid)
                cen     <= 1'b0;
        else if(axi_rvalid && axi_rready)
                cen     <= 1'b0;
        else    cen     <= cen;
        //-->> COUNT RST
        if(axi_awready && axi_awvalid)
                crst    <= 1'b1;
        else if(axi_arready && axi_arvalid)
                crst    <= 1'b1;
        else if(axi_wready && axi_wvalid)
                crst    <= 1'b1;
        else if(axi_rready && axi_rvalid)
                crst    <= 1'b1;
        else    crst    <= 1'b0;
        //-->> COUNT
        if(crst)
                tcnt    <= 24'd0;
        else if(cen)
                tcnt    <= tcnt + 1'b1;
        else    tcnt    <= tcnt;
        //-->> RESULT
        timeout <= &tcnt;
    end
end
//---<< TIME CTRL >>---------------
//--->> AW_CNT  <<-----------------
logic [LSIZE-1:0]   axi_wcnt;

always@(posedge axi_aclk,negedge axi_aresetn)begin:WRITE_CNT
    if(~axi_aresetn) axi_wcnt    <= '0;
    else begin
        if(axi_wvalid && axi_wready && axi_wlast)
                axi_wcnt    <= '0;
        else if(axi_wvalid && axi_wready)
                axi_wcnt    <= axi_wcnt + 1'b1;
        else    axi_wcnt    <= axi_wcnt;
    end
end
//---<< AW_CNT  >>-----------------
//--->> AR_CNT  <<-----------------
logic [LSIZE-1:0]   axi_rcnt;

always@(posedge axi_aclk,negedge axi_aresetn)begin:READ_CNT
    if(~axi_aresetn) axi_rcnt    <= '0;
    else begin
        if(axi_rvalid && axi_rready && axi_rlast)
                axi_rcnt    <= '0;
        else if(axi_rvalid && axi_rready)
                axi_rcnt    <= axi_rcnt + 1'b1;
        else    axi_rcnt    <= axi_rcnt;
    end
end
//---<< AR_CNT  >>-----------------
//--->> MODE CTRL <<---------------
`ifdef VIVADO_ENV
generate
if(MODE=="ONLY_READ")begin
assign     axi_awid     = '0;
assign     axi_awaddr   = '0;
assign     axi_awlen    = '0;
assign     axi_awsize   = '0;
assign     axi_awburst  = '0;
assign     axi_awlock   = '0;
assign     axi_awcache  = '0;
assign     axi_awprot   = '0;
assign     axi_awqos    = '0;
assign     axi_awvalid  = '0;
assign     axi_wdata    = '0;
assign     axi_wstrb    = '0;
assign     axi_wlast    = '0;
assign     axi_wvalid   = '0;
assign     axi_bready   = '0;
end
endgenerate

generate
if(MODE=="ONLY_WRITE")begin
assign     axi_arid     = '0;
assign     axi_araddr   = '0;
assign     axi_arlen    = '0;
assign     axi_arsize   = '0;
assign     axi_arburst  = '0;
assign     axi_arlock   = '0;
assign     axi_arcache  = '0;
assign     axi_arprot   = '0;
assign     axi_arqos    = '0;
assign     axi_arvalid  = '0;
assign     axi_rready   = '0;
end
endgenerate
`endif

//---<< MODE CTRL >>---------------
modport slaver (
input    axi_aclk     ,
input    axi_aresetn   ,
input    axi_awid     ,
input    axi_awaddr   ,
input    axi_awlen    ,
input    axi_awsize   ,
input    axi_awburst  ,
input    axi_awlock   ,
input    axi_awcache  ,
input    axi_awprot   ,
input    axi_awqos    ,
input    axi_awvalid  ,
output   axi_awready  ,
input    axi_wdata    ,
input    axi_wstrb    ,
input    axi_wlast    ,
input    axi_wvalid   ,
output   axi_wready   ,
input    axi_bready   ,
output   axi_bid      ,
output   axi_bresp    ,
output   axi_bvalid   ,
input    axi_arid     ,
input    axi_araddr   ,
input    axi_arlen    ,
input    axi_arsize   ,
input    axi_arburst  ,
input    axi_arlock   ,
input    axi_arcache  ,
input    axi_arprot   ,
input    axi_arqos    ,
input    axi_arvalid  ,
output   axi_arready  ,
input    axi_rready   ,
output   axi_rid      ,
output   axi_rdata    ,
output   axi_rresp    ,
output   axi_rlast    ,
output   axi_rvalid   ,

input   axi_wcnt,
input   axi_rcnt,
// input    axi_wevld    ,
// input    axi_weresp   ,
// input    axi_revld    ,
// input    axi_reresp   ,
input    timeout
);

modport master (
input     axi_aclk     ,
input     axi_aresetn   ,
output    axi_awid     ,
output    axi_awaddr   ,
output    axi_awlen    ,
output    axi_awsize   ,
output    axi_awburst  ,
output    axi_awlock   ,
output    axi_awcache  ,
output    axi_awprot   ,
output    axi_awqos    ,
output    axi_awvalid  ,
input     axi_awready  ,
output    axi_wdata    ,
output    axi_wstrb    ,
output    axi_wlast    ,
output    axi_wvalid   ,
input     axi_wready   ,
output    axi_bready   ,
input     axi_bid      ,
input     axi_bresp    ,
input     axi_bvalid   ,
output    axi_arid     ,
output    axi_araddr   ,
output    axi_arlen    ,
output    axi_arsize   ,
output    axi_arburst  ,
output    axi_arlock   ,
output    axi_arcache  ,
output    axi_arprot   ,
output    axi_arqos    ,
output    axi_arvalid  ,
input     axi_arready  ,
output    axi_rready   ,
input     axi_rid      ,
input     axi_rdata    ,
input     axi_rresp    ,
input     axi_rlast    ,
input     axi_rvalid   ,
input     axi_wcnt,
input     axi_rcnt,
// input     axi_wevld    ,
// input     axi_weresp   ,
// input     axi_revld    ,
// input     axi_reresp   ,
input     timeout
);

modport master_wr (
input     axi_aclk     ,
input     axi_aresetn   ,
output    axi_awid     ,
output    axi_awaddr   ,
output    axi_awlen    ,
output    axi_awsize   ,
output    axi_awburst  ,
output    axi_awlock   ,
output    axi_awcache  ,
output    axi_awprot   ,
output    axi_awqos    ,
output    axi_awvalid  ,
input     axi_awready  ,
output    axi_wdata    ,
output    axi_wstrb    ,
output    axi_wlast    ,
output    axi_wvalid   ,
input     axi_wready   ,
output    axi_bready   ,
input     axi_bid      ,
input     axi_bresp    ,
input     axi_bvalid   ,
input     axi_wcnt,
// input     axi_rcnt,
input     timeout
);

modport master_rd (
input     axi_aclk     ,
input     axi_aresetn   ,
output    axi_arid     ,
output    axi_araddr   ,
output    axi_arlen    ,
output    axi_arsize   ,
output    axi_arburst  ,
output    axi_arlock   ,
output    axi_arcache  ,
output    axi_arprot   ,
output    axi_arqos    ,
output    axi_arvalid  ,
input     axi_arready  ,
output    axi_rready   ,
input     axi_rid      ,
input     axi_rdata    ,
input     axi_rresp    ,
input     axi_rlast    ,
input     axi_rvalid   ,
// input     axi_wcnt,
input     axi_rcnt,
input     timeout
);

modport slaver_wr (
input    axi_aclk     ,
input    axi_aresetn   ,
input    axi_awid     ,
input    axi_awaddr   ,
input    axi_awlen    ,
input    axi_awsize   ,
input    axi_awburst  ,
input    axi_awlock   ,
input    axi_awcache  ,
input    axi_awprot   ,
input    axi_awqos    ,
input    axi_awvalid  ,
output   axi_awready  ,
input    axi_wdata    ,
input    axi_wstrb    ,
input    axi_wlast    ,
input    axi_wvalid   ,
output   axi_wready   ,
input    axi_bready   ,
output   axi_bid      ,
output   axi_bresp    ,
output   axi_bvalid   ,
input    axi_wcnt,
// input    axi_rcnt,
input    timeout
);

modport slaver_rd (
input    axi_aclk     ,
input    axi_aresetn   ,
input    axi_arid     ,
input    axi_araddr   ,
input    axi_arlen    ,
input    axi_arsize   ,
input    axi_arburst  ,
input    axi_arlock   ,
input    axi_arcache  ,
input    axi_arprot   ,
input    axi_arqos    ,
input    axi_arvalid  ,
output   axi_arready  ,
input    axi_rready   ,
output   axi_rid      ,
output   axi_rdata    ,
output   axi_rresp    ,
output   axi_rlast    ,
output   axi_rvalid   ,
// input    axi_wcnt,
input    axi_rcnt,
input    timeout
);

modport master_wr_aux (
input     axi_aclk     ,
input     axi_aresetn   ,
output    axi_awid     ,
output    axi_awaddr   ,
output    axi_awlen    ,
output    axi_awsize   ,
output    axi_awburst  ,
output    axi_awlock   ,
output    axi_awcache  ,
output    axi_awprot   ,
output    axi_awqos    ,
output    axi_awvalid  ,
input     axi_awready  ,
// output    axi_wdata    ,
// output    axi_wstrb    ,
input     axi_wlast    ,
input     axi_wvalid   ,
input     axi_wready   ,
output    axi_bready   ,
input     axi_bid      ,
input     axi_bresp    ,
input     axi_bvalid   ,
input     axi_wcnt,
input     axi_rcnt,
input     timeout
);

modport master_wr_aux_no_resp (
input     axi_aclk     ,
input     axi_aresetn   ,
output    axi_awid     ,
output    axi_awaddr   ,
output    axi_awlen    ,
output    axi_awsize   ,
output    axi_awburst  ,
output    axi_awlock   ,
output    axi_awcache  ,
output    axi_awprot   ,
output    axi_awqos    ,
output    axi_awvalid  ,
input     axi_awready  ,
// output    axi_wdata    ,
// output    axi_wstrb    ,
input     axi_wlast    ,
input     axi_wvalid   ,
input     axi_wready   ,
// input     axi_bready   ,
// input     axi_bid      ,
// input     axi_bresp    ,
// input     axi_bvalid   ,
input     axi_wcnt,
// input     axi_rcnt,
input     timeout
);

modport master_rd_aux (
input     axi_aclk     ,
input     axi_aresetn   ,
output    axi_arid     ,
output    axi_araddr   ,
output    axi_arlen    ,
output    axi_arsize   ,
output    axi_arburst  ,
output    axi_arlock   ,
output    axi_arcache  ,
output    axi_arprot   ,
output    axi_arqos    ,
output    axi_arvalid  ,
input     axi_arready  ,
input     axi_rready   ,
input     axi_rid      ,
// input     axi_rdata    ,
input     axi_rresp    ,
input     axi_rlast    ,
input     axi_rvalid   ,
// input     axi_wcnt,
input     axi_rcnt,
input     timeout
);

modport mirror (
input   axi_aclk     ,
input   axi_aresetn   ,
input   axi_awid     ,
input   axi_awaddr   ,
input   axi_awlen    ,
input   axi_awsize   ,
input   axi_awburst  ,
input   axi_awlock   ,
input   axi_awcache  ,
input   axi_awprot   ,
input   axi_awqos    ,
input   axi_awvalid  ,
input   axi_awready  ,
input   axi_wdata    ,
input   axi_wstrb    ,
input   axi_wlast    ,
input   axi_wvalid   ,
input   axi_wready   ,
input   axi_bready   ,
input   axi_bid      ,
input   axi_bresp    ,
input   axi_bvalid   ,
input   axi_arid     ,
input   axi_araddr   ,
input   axi_arlen    ,
input   axi_arsize   ,
input   axi_arburst  ,
input   axi_arlock   ,
input   axi_arcache  ,
input   axi_arprot   ,
input   axi_arqos    ,
input   axi_arvalid  ,
input   axi_arready  ,
input   axi_rready   ,
input   axi_rid      ,
input   axi_rdata    ,
input   axi_rresp    ,
input   axi_rlast    ,
input   axi_rvalid   ,
input   axi_wcnt,
input   axi_rcnt,
// output  axi_wevld    ,
// output  axi_weresp   ,
// output  axi_revld    ,
// output  axi_reresp   ,
input    timeout
);

modport mirror_wr (
input   axi_aclk     ,
input   axi_aresetn   ,
input   axi_awid     ,
input   axi_awaddr   ,
input   axi_awlen    ,
input   axi_awsize   ,
input   axi_awburst  ,
input   axi_awlock   ,
input   axi_awcache  ,
input   axi_awprot   ,
input   axi_awqos    ,
input   axi_awvalid  ,
input   axi_awready  ,
input   axi_wdata    ,
input   axi_wstrb    ,
input   axi_wlast    ,
input   axi_wvalid   ,
input   axi_wready   ,
input   axi_bready   ,
input   axi_bid      ,
input   axi_bresp    ,
input   axi_bvalid   ,
input   axi_wcnt,
// output  axi_wevld    ,
// output  axi_weresp   ,
// output  axi_revld    ,
// output  axi_reresp   ,
input    timeout
);

modport mirror_rd (
input   axi_aclk     ,
input   axi_aresetn   ,
input   axi_arid     ,
input   axi_araddr   ,
input   axi_arlen    ,
input   axi_arsize   ,
input   axi_arburst  ,
input   axi_arlock   ,
input   axi_arcache  ,
input   axi_arprot   ,
input   axi_arqos    ,
input   axi_arvalid  ,
input   axi_arready  ,
input   axi_rready   ,
input   axi_rid      ,
input   axi_rdata    ,
input   axi_rresp    ,
input   axi_rlast    ,
input   axi_rvalid   ,
input   axi_rcnt,
// output  axi_wevld    ,
// output  axi_weresp   ,
// output  axi_revld    ,
// output  axi_reresp   ,
input    timeout
);

modport lite_master(
input                axi_aclk       ,
input                axi_aresetn     ,
output               axi_awvalid    ,
input                axi_awready    ,
output               axi_awaddr     ,
output               axi_wvalid     ,
input                axi_wready     ,
output               axi_wdata      ,
input                axi_bresp      ,
input                axi_bvalid     ,
output               axi_bready     ,
output               axi_arvalid    ,
input                axi_arready    ,
output               axi_araddr     ,
input                axi_rvalid     ,
output               axi_rready     ,
input                axi_rdata      ,
// input                axi_rresp      ,
input                timeout
);

modport lite_slaver(
input                axi_aclk       ,
input                axi_aresetn     ,
input               axi_awvalid    ,
output              axi_awready    ,
input               axi_awaddr     ,
input               axi_wvalid     ,
output              axi_wready     ,
input               axi_wdata      ,
output              axi_bresp      ,
output              axi_bvalid     ,
input               axi_bready     ,
input               axi_arvalid    ,
output              axi_arready    ,
input               axi_araddr     ,
output              axi_rvalid     ,
input               axi_rready     ,
output              axi_rdata      ,
// output              axi_rresp
input               timeout
);

endinterface:axi_inf

interface axi_inf2 #(
    parameter IDSIZE    = 1,
    parameter ASIZE     = 32,
    parameter LSIZE     = 1,
    parameter DSIZE     = 32,
    `parameter_string MODE      = "BOTH",        //BOTH:0,ONLY_WRITE:1,ONLY_READ:2
    parameter ADDR_STEP = 32'hFFFF_FFFF            // 1024 : 0
)(
    input bit axi_aclk      ,
    input bit axi_aresetn
);

initial begin
    if(MODE == "BOTH" || MODE == "ONLY_READ" || MODE == "ONLY_WRITE")
        #(1ps);
    else begin
        $error("$t,AXI INFTERFACE MODE PARAMETER ERROR >>%s<<",MODE);
        $finish;
    end
end

logic           timeout;

localparam STSIZE = DSIZE/8+(DSIZE%8 != 0);
//--->> addr write <<-------
wire[IDSIZE-1:0] axi_awid      ;
wire[ASIZE-1:0]  axi_awaddr    ;
wire[LSIZE-1:0]  axi_awlen     ;
wire[2:0]        axi_awsize    ;
wire[1:0]        axi_awburst   ;
wire[0:0]        axi_awlock    ;
wire[3:0]        axi_awcache   ;
wire[2:0]        axi_awprot    ;
wire[3:0]        axi_awqos     ;
wire             axi_awvalid   ;
wire             axi_awready   ;
//---<< addr write >>-------
//--->> addr read <<--------
wire[IDSIZE-1:0] axi_arid        ;
wire[ASIZE-1:0]  axi_araddr      ;
wire[LSIZE-1:0]  axi_arlen       ;
wire[2:0]        axi_arsize      ;
wire[1:0]        axi_arburst     ;
wire[0:0]        axi_arlock      ;
wire[3:0]        axi_arcache     ;
wire[2:0]        axi_arprot      ;
wire[3:0]        axi_arqos       ;
wire             axi_arvalid     ;
wire             axi_arready     ;
//---<< addr read >>--------
//--->> Response <<---------
wire             axi_bready    ;
wire[IDSIZE-1:0] axi_bid       ;
wire[1:0]        axi_bresp     ;
wire             axi_bvalid    ;
//---<< Response >>---------
//--->> data write <<-------
wire[DSIZE-1:0]  axi_wdata     ;
wire[STSIZE-1:0] axi_wstrb     ;
wire             axi_wlast     ;
wire             axi_wvalid    ;
wire             axi_wready    ;
//---<< data write >>-------
//--->> data read >>--------
wire             axi_rready    ;
wire[IDSIZE-1:0] axi_rid       ;
wire[DSIZE-1:0]  axi_rdata     ;
wire[1:0]        axi_rresp     ;
wire             axi_rlast     ;
wire             axi_rvalid    ;
//---<< data read >>--------
//--->> error flag <<-------
// logic             axi_wevld      ;
// logic[3:0]        axi_weresp     ;
// logic             axi_revld      ;
// logic[3:0]        axi_reresp     ;
//---<< error flag >>-------

//--->> TIME CTRL <<---------------
always@(posedge axi_aclk,negedge axi_aresetn)begin:TIME_BLOCK
logic   cen;
logic   crst;
logic [23:0]    tcnt;
    if(~axi_aresetn)begin
        tcnt    <= 24'd0;
        cen     <= 1'b0;
        crst    <= 1'b0;
    end else begin
        //-->> COUNT ENABLE
        if(axi_awready && axi_awvalid)
                cen     <= 1'b1;
        else if(axi_arready && axi_arvalid)
                cen     <= 1'b1;
        else if(axi_bready && axi_bvalid)
                cen     <= 1'b0;
        else if(axi_rvalid && axi_rready)
                cen     <= 1'b0;
        else    cen     <= cen;
        //-->> COUNT RST
        if(axi_awready && axi_awvalid)
                crst    <= 1'b1;
        else if(axi_arready && axi_arvalid)
                crst    <= 1'b1;
        else if(axi_wready && axi_wvalid)
                crst    <= 1'b1;
        else if(axi_rready && axi_rvalid)
                crst    <= 1'b1;
        else    crst    <= 1'b0;
        //-->> COUNT
        if(crst)
                tcnt    <= 24'd0;
        else if(cen)
                tcnt    <= tcnt + 1'b1;
        else    tcnt    <= tcnt;
        //-->> RESULT
        timeout <= &tcnt;
    end
end
//---<< TIME CTRL >>---------------
//--->> AW_CNT  <<-----------------
logic [LSIZE-1:0]   axi_wcnt;

always@(posedge axi_aclk,negedge axi_aresetn)begin:WRITE_CNT
    if(~axi_aresetn) axi_wcnt    <= '0;
    else begin
        if(axi_wvalid && axi_wready && axi_wlast)
                axi_wcnt    <= '0;
        else if(axi_wvalid && axi_wready)
                axi_wcnt    <= axi_wcnt + 1'b1;
        else    axi_wcnt    <= axi_wcnt;
    end
end
//---<< AW_CNT  >>-----------------
//--->> AR_CNT  <<-----------------
logic [LSIZE-1:0]   axi_rcnt;

always@(posedge axi_aclk,negedge axi_aresetn)begin:READ_CNT
    if(~axi_aresetn) axi_rcnt    <= '0;
    else begin
        if(axi_rvalid && axi_rready && axi_rlast)
                axi_rcnt    <= '0;
        else if(axi_rvalid && axi_rready)
                axi_rcnt    <= axi_rcnt + 1'b1;
        else    axi_rcnt    <= axi_rcnt;
    end
end
//---<< AR_CNT  >>-----------------
//--->> MODE CTRL <<---------------
`ifdef VIVADO_ENV
generate
if(MODE=="ONLY_READ")begin
assign     axi_awid     = '0;
assign     axi_awaddr   = '0;
assign     axi_awlen    = '0;
assign     axi_awsize   = '0;
assign     axi_awburst  = '0;
assign     axi_awlock   = '0;
assign     axi_awcache  = '0;
assign     axi_awprot   = '0;
assign     axi_awqos    = '0;
assign     axi_awvalid  = '0;
assign     axi_wdata    = '0;
assign     axi_wstrb    = '0;
assign     axi_wlast    = '0;
assign     axi_wvalid   = '0;
assign     axi_bready   = '0;
end
endgenerate

generate
if(MODE=="ONLY_WRITE")begin
assign     axi_arid     = '0;
assign     axi_araddr   = '0;
assign     axi_arlen    = '0;
assign     axi_arsize   = '0;
assign     axi_arburst  = '0;
assign     axi_arlock   = '0;
assign     axi_arcache  = '0;
assign     axi_arprot   = '0;
assign     axi_arqos    = '0;
assign     axi_arvalid  = '0;
assign     axi_rready   = '0;
end
endgenerate
`endif

//---<< MODE CTRL >>---------------
modport slaver (
input    axi_aclk     ,
input    axi_aresetn   ,
input    axi_awid     ,
input    axi_awaddr   ,
input    axi_awlen    ,
input    axi_awsize   ,
input    axi_awburst  ,
input    axi_awlock   ,
input    axi_awcache  ,
input    axi_awprot   ,
input    axi_awqos    ,
input    axi_awvalid  ,
output   axi_awready  ,
input    axi_wdata    ,
input    axi_wstrb    ,
input    axi_wlast    ,
input    axi_wvalid   ,
output   axi_wready   ,
input    axi_bready   ,
output   axi_bid      ,
output   axi_bresp    ,
output   axi_bvalid   ,
input    axi_arid     ,
input    axi_araddr   ,
input    axi_arlen    ,
input    axi_arsize   ,
input    axi_arburst  ,
input    axi_arlock   ,
input    axi_arcache  ,
input    axi_arprot   ,
input    axi_arqos    ,
input    axi_arvalid  ,
output   axi_arready  ,
input    axi_rready   ,
output   axi_rid      ,
output   axi_rdata    ,
output   axi_rresp    ,
output   axi_rlast    ,
output   axi_rvalid   ,

input   axi_wcnt,
input   axi_rcnt,
// input    axi_wevld    ,
// input    axi_weresp   ,
// input    axi_revld    ,
// input    axi_reresp   ,
input    timeout
);

modport master (
input     axi_aclk     ,
input     axi_aresetn   ,
output    axi_awid     ,
output    axi_awaddr   ,
output    axi_awlen    ,
output    axi_awsize   ,
output    axi_awburst  ,
output    axi_awlock   ,
output    axi_awcache  ,
output    axi_awprot   ,
output    axi_awqos    ,
output    axi_awvalid  ,
input     axi_awready  ,
output    axi_wdata    ,
output    axi_wstrb    ,
output    axi_wlast    ,
output    axi_wvalid   ,
input     axi_wready   ,
output    axi_bready   ,
input     axi_bid      ,
input     axi_bresp    ,
input     axi_bvalid   ,
output    axi_arid     ,
output    axi_araddr   ,
output    axi_arlen    ,
output    axi_arsize   ,
output    axi_arburst  ,
output    axi_arlock   ,
output    axi_arcache  ,
output    axi_arprot   ,
output    axi_arqos    ,
output    axi_arvalid  ,
input     axi_arready  ,
output    axi_rready   ,
input     axi_rid      ,
input     axi_rdata    ,
input     axi_rresp    ,
input     axi_rlast    ,
input     axi_rvalid   ,
input     axi_wcnt,
input     axi_rcnt,
// input     axi_wevld    ,
// input     axi_weresp   ,
// input     axi_revld    ,
// input     axi_reresp   ,
input     timeout
);

modport master_wr (
input     axi_aclk     ,
input     axi_aresetn   ,
output    axi_awid     ,
output    axi_awaddr   ,
output    axi_awlen    ,
output    axi_awsize   ,
output    axi_awburst  ,
output    axi_awlock   ,
output    axi_awcache  ,
output    axi_awprot   ,
output    axi_awqos    ,
output    axi_awvalid  ,
input     axi_awready  ,
output    axi_wdata    ,
output    axi_wstrb    ,
output    axi_wlast    ,
output    axi_wvalid   ,
input     axi_wready   ,
output    axi_bready   ,
input     axi_bid      ,
input     axi_bresp    ,
input     axi_bvalid   ,
input     axi_wcnt,
// input     axi_rcnt,
input     timeout
);

modport master_rd (
input     axi_aclk     ,
input     axi_aresetn   ,
output    axi_arid     ,
output    axi_araddr   ,
output    axi_arlen    ,
output    axi_arsize   ,
output    axi_arburst  ,
output    axi_arlock   ,
output    axi_arcache  ,
output    axi_arprot   ,
output    axi_arqos    ,
output    axi_arvalid  ,
input     axi_arready  ,
output    axi_rready   ,
input     axi_rid      ,
input     axi_rdata    ,
input     axi_rresp    ,
input     axi_rlast    ,
input     axi_rvalid   ,
// input     axi_wcnt,
input     axi_rcnt,
input     timeout
);

modport slaver_wr (
input    axi_aclk     ,
input    axi_aresetn   ,
input    axi_awid     ,
input    axi_awaddr   ,
input    axi_awlen    ,
input    axi_awsize   ,
input    axi_awburst  ,
input    axi_awlock   ,
input    axi_awcache  ,
input    axi_awprot   ,
input    axi_awqos    ,
input    axi_awvalid  ,
output   axi_awready  ,
input    axi_wdata    ,
input    axi_wstrb    ,
input    axi_wlast    ,
input    axi_wvalid   ,
output   axi_wready   ,
input    axi_bready   ,
output   axi_bid      ,
output   axi_bresp    ,
output   axi_bvalid   ,
input    axi_wcnt,
// input    axi_rcnt,
input    timeout
);

modport slaver_rd (
input    axi_aclk     ,
input    axi_aresetn   ,
input    axi_arid     ,
input    axi_araddr   ,
input    axi_arlen    ,
input    axi_arsize   ,
input    axi_arburst  ,
input    axi_arlock   ,
input    axi_arcache  ,
input    axi_arprot   ,
input    axi_arqos    ,
input    axi_arvalid  ,
output   axi_arready  ,
input    axi_rready   ,
output   axi_rid      ,
output   axi_rdata    ,
output   axi_rresp    ,
output   axi_rlast    ,
output   axi_rvalid   ,
// input    axi_wcnt,
input    axi_rcnt,
input    timeout
);

modport master_wr_aux (
input     axi_aclk     ,
input     axi_aresetn   ,
output    axi_awid     ,
output    axi_awaddr   ,
output    axi_awlen    ,
output    axi_awsize   ,
output    axi_awburst  ,
output    axi_awlock   ,
output    axi_awcache  ,
output    axi_awprot   ,
output    axi_awqos    ,
output    axi_awvalid  ,
input     axi_awready  ,
// output    axi_wdata    ,
// output    axi_wstrb    ,
input     axi_wlast    ,
input     axi_wvalid   ,
input     axi_wready   ,
output    axi_bready   ,
input     axi_bid      ,
input     axi_bresp    ,
input     axi_bvalid   ,
input     axi_wcnt,
input     axi_rcnt,
input     timeout
);

modport master_wr_aux_no_resp (
input     axi_aclk     ,
input     axi_aresetn   ,
output    axi_awid     ,
output    axi_awaddr   ,
output    axi_awlen    ,
output    axi_awsize   ,
output    axi_awburst  ,
output    axi_awlock   ,
output    axi_awcache  ,
output    axi_awprot   ,
output    axi_awqos    ,
output    axi_awvalid  ,
input     axi_awready  ,
// output    axi_wdata    ,
// output    axi_wstrb    ,
input     axi_wlast    ,
input     axi_wvalid   ,
input     axi_wready   ,
// input     axi_bready   ,
// input     axi_bid      ,
// input     axi_bresp    ,
// input     axi_bvalid   ,
input     axi_wcnt,
// input     axi_rcnt,
input     timeout
);

modport master_rd_aux (
input     axi_aclk     ,
input     axi_aresetn   ,
output    axi_arid     ,
output    axi_araddr   ,
output    axi_arlen    ,
output    axi_arsize   ,
output    axi_arburst  ,
output    axi_arlock   ,
output    axi_arcache  ,
output    axi_arprot   ,
output    axi_arqos    ,
output    axi_arvalid  ,
input     axi_arready  ,
input     axi_rready   ,
input     axi_rid      ,
// input     axi_rdata    ,
input     axi_rresp    ,
input     axi_rlast    ,
input     axi_rvalid   ,
// input     axi_wcnt,
input     axi_rcnt,
input     timeout
);

modport mirror (
input   axi_aclk     ,
input   axi_aresetn   ,
input   axi_awid     ,
input   axi_awaddr   ,
input   axi_awlen    ,
input   axi_awsize   ,
input   axi_awburst  ,
input   axi_awlock   ,
input   axi_awcache  ,
input   axi_awprot   ,
input   axi_awqos    ,
input   axi_awvalid  ,
input   axi_awready  ,
input   axi_wdata    ,
input   axi_wstrb    ,
input   axi_wlast    ,
input   axi_wvalid   ,
input   axi_wready   ,
input   axi_bready   ,
input   axi_bid      ,
input   axi_bresp    ,
input   axi_bvalid   ,
input   axi_arid     ,
input   axi_araddr   ,
input   axi_arlen    ,
input   axi_arsize   ,
input   axi_arburst  ,
input   axi_arlock   ,
input   axi_arcache  ,
input   axi_arprot   ,
input   axi_arqos    ,
input   axi_arvalid  ,
input   axi_arready  ,
input   axi_rready   ,
input   axi_rid      ,
input   axi_rdata    ,
input   axi_rresp    ,
input   axi_rlast    ,
input   axi_rvalid   ,
input   axi_wcnt,
input   axi_rcnt,
// output  axi_wevld    ,
// output  axi_weresp   ,
// output  axi_revld    ,
// output  axi_reresp   ,
input    timeout
);

modport mirror_wr (
input   axi_aclk     ,
input   axi_aresetn   ,
input   axi_awid     ,
input   axi_awaddr   ,
input   axi_awlen    ,
input   axi_awsize   ,
input   axi_awburst  ,
input   axi_awlock   ,
input   axi_awcache  ,
input   axi_awprot   ,
input   axi_awqos    ,
input   axi_awvalid  ,
input   axi_awready  ,
input   axi_wdata    ,
input   axi_wstrb    ,
input   axi_wlast    ,
input   axi_wvalid   ,
input   axi_wready   ,
input   axi_bready   ,
input   axi_bid      ,
input   axi_bresp    ,
input   axi_bvalid   ,
input   axi_wcnt,
// output  axi_wevld    ,
// output  axi_weresp   ,
// output  axi_revld    ,
// output  axi_reresp   ,
input    timeout
);

modport mirror_rd (
input   axi_aclk     ,
input   axi_aresetn   ,
input   axi_arid     ,
input   axi_araddr   ,
input   axi_arlen    ,
input   axi_arsize   ,
input   axi_arburst  ,
input   axi_arlock   ,
input   axi_arcache  ,
input   axi_arprot   ,
input   axi_arqos    ,
input   axi_arvalid  ,
input   axi_arready  ,
input   axi_rready   ,
input   axi_rid      ,
input   axi_rdata    ,
input   axi_rresp    ,
input   axi_rlast    ,
input   axi_rvalid   ,
input   axi_rcnt,
// output  axi_wevld    ,
// output  axi_weresp   ,
// output  axi_revld    ,
// output  axi_reresp   ,
input    timeout
);

modport lite_master(
input                axi_aclk       ,
input                axi_aresetn     ,
output               axi_awvalid    ,
input                axi_awready    ,
output               axi_awaddr     ,
output               axi_wvalid     ,
input                axi_wready     ,
output               axi_wdata      ,
input                axi_bresp      ,
input                axi_bvalid     ,
output               axi_bready     ,
output               axi_arvalid    ,
input                axi_arready    ,
output               axi_araddr     ,
input                axi_rvalid     ,
output               axi_rready     ,
input                axi_rdata      ,
// input                axi_rresp      ,
input                timeout
);

modport lite_slaver(
input                axi_aclk       ,
input                axi_aresetn     ,
input               axi_awvalid    ,
output              axi_awready    ,
input               axi_awaddr     ,
input               axi_wvalid     ,
output              axi_wready     ,
input               axi_wdata      ,
output              axi_bresp      ,
output              axi_bvalid     ,
input               axi_bready     ,
input               axi_arvalid    ,
output              axi_arready    ,
input               axi_araddr     ,
output              axi_rvalid     ,
input               axi_rready     ,
output              axi_rdata      ,
// output              axi_rresp
input               timeout
);

endinterface:axi_inf2
