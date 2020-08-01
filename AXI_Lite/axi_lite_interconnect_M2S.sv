/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/1/10 
madified:
***********************************************/
`timescale 1ns/1ps
module axi_lite_interconnect_M2S #(
    parameter NUM   = 4
)(
     axi_lite_inf.slaver     s00 [NUM-1:0],
     axi_lite_inf.master     m00
);

localparam NSIZE =  NUM <= 2? 1 :
                    NUM <= 4? 2 :
                    NUM <= 8? 3 :
                    NUM <= 16?4 : 5;

logic[NSIZE-1:0]    waddr;
logic               waddr_vld;
logic[NSIZE-1:0]    curr_waddr;

logic[NSIZE-1:0]    raddr;
logic               raddr_vld;
logic[NSIZE-1:0]    curr_raddr;

//--->> STREAM CLOCK AND RESET <<-------------------
wire        clock,rst_n;
assign      clock   = m00.axi_aclk;
assign      rst_n   = m00.axi_aresetn;
//---<< STREAM CLOCK AND RESET >>-------------------
genvar KK;
//--->> IMPORT EXPORT GET ADDR FUNCTION <<------------
// generate
// for(KK=0;KK<NUM;KK++)begin
// lite_connect_addr lite_connect_addr_inst (s00[KK],m00);
// end
// endgenerate
//---<< IMPORT EXPORT GET ADDR FUNCTION >>------------
//--->> ADDR STATUS <<---------------------

logic               wlock_addr;
logic [NUM-1:0]     wstart_s;
logic [NUM-1:0]     wrelex;

logic               rlock_addr;
logic [NUM-1:0]     rstart_s;
logic [NUM-1:0]     rrelex;

logic [NUM-1:0]     awlock_relex;
logic [NUM-1:0]     arlock_relex;

generate
for(KK=0;KK<NUM;KK++)begin
    assign wstart_s[KK]     = s00[KK].axi_awvalid ;
    assign wrelex[KK]       = (s00[KK].axi_bvalid && s00[KK].axi_bready && !s00[KK].axi_awlock) || awlock_relex[KK];

    assign rstart_s[KK]     = s00[KK].axi_arvalid;
    assign rrelex[KK]       = (s00[KK].axi_rvalid && s00[KK].axi_rready && !s00[KK].axi_arlock) || arlock_relex[KK];
end
endgenerate

int II;

//--->> LOCK <<-----------------------------
logic   s00_wr_status [NUM-1:0];
logic   s00_rd_status [NUM-1:0];

generate
for(KK=0;KK<NUM;KK++)begin
//------------------------------------------------------------
always@(posedge m00.axi_aclk)begin:WR_STATUS_BLOCK
    if(~m00.axi_aresetn)
        s00_wr_status[KK]   <= '0;
    else begin
        if(s00[KK].axi_awvalid && s00[KK].axi_awready)
                s00_wr_status[KK]    <= 1'b1;
        else if(s00[KK].axi_bvalid && s00[KK].axi_bready)
                s00_wr_status[KK]    <= 1'b0;
        else    s00_wr_status[KK]    <= s00_wr_status[KK];
    end
end

always@(posedge m00.axi_aclk)begin:RD_STATUS_BLOCK
    if(~m00.axi_aresetn)
        s00_rd_status[KK]   <= '0;
    else begin
        if(s00[KK].axi_arvalid && s00[KK].axi_arready)
                s00_rd_status[KK]    <= 1'b1;
        else if(s00[KK].axi_rvalid && s00[KK].axi_rready)
                s00_rd_status[KK]    <= 1'b0;
        else    s00_rd_status[KK]    <= s00_rd_status[KK];
    end
end
end
//==================================================================
endgenerate

logic[NUM-1:0]       awlock_raising;
logic[NUM-1:0]       awlock_falling;

logic[NUM-1:0]       arlock_raising;
logic[NUM-1:0]       arlock_falling;

generate
for(KK=0;KK<NUM;KK++)begin:GEN_EDGE_BLOCK
edge_generator aw_edge_generator_inst(
/*  input   */  .clk        (m00.axi_aclk       ),
/*  input   */  .rst_n      (m00.axi_aresetn     ),
/*  input   */  .in         (s00[KK].axi_awlock ),
/*  output  */  .raising    (awlock_raising[KK]     ),
/*  output  */  .falling    (awlock_falling[KK]     )
);

edge_generator ar_edge_generator_inst(
/*  input   */  .clk        (m00.axi_aclk       ),
/*  input   */  .rst_n      (m00.axi_aresetn     ),
/*  input   */  .in         (s00[KK].axi_arlock ),
/*  output  */  .raising    (arlock_raising[KK]     ),
/*  output  */  .falling    (arlock_falling[KK]     )
);

always@(posedge m00.axi_aclk)begin
    if(~m00.axi_aresetn) awlock_relex[KK]    <= 1'b0;
    else begin
         awlock_relex[KK]   <=  awlock_falling[KK] && !s00_wr_status[KK];
    end
end

always@(posedge m00.axi_aclk)begin
    if(~m00.axi_aresetn) arlock_relex[KK]    <= 1'b0;
    else begin
         arlock_relex[KK]   <=  arlock_falling[KK] && !s00_rd_status[KK];
    end
end
end
endgenerate
//---<< LOCK >>-----------------------------


always@(posedge m00.axi_aclk)begin:LOCK_BLOCK
    if(~m00.axi_aresetn)    wlock_addr   <= 1'b0;
    else begin
        if(|wrelex)
                wlock_addr   <= 1'b0;
        else if(|wstart_s)
                wlock_addr   <= 1'b1;
        else    wlock_addr   <= wlock_addr;
    end
end

always@(posedge m00.axi_aclk)begin
    if(~m00.axi_aresetn)    rlock_addr   <= 1'b0;
    else begin
        if(|rrelex)
                rlock_addr   <= 1'b0;
        else if(|rstart_s)
                rlock_addr   <= 1'b1;
        else    rlock_addr   <= rlock_addr;
    end
end

logic [NSIZE-1:0]   waddr_t = {NSIZE{1'b0}};
logic [NSIZE-1:0]   raddr_t = {NSIZE{1'b0}};

always@(*)begin
    for(II=0;II<NUM;II++)begin
        waddr_t  = wstart_s[II]? II : waddr_t;
        raddr_t  = rstart_s[II]? II : raddr_t;
    end
end

always@(posedge m00.axi_aclk)begin
    if(~m00.axi_aresetn)    waddr    <= {NSIZE{1'b0}};
    else begin
        if(!wlock_addr)
                waddr    <= waddr_t;
        else    waddr    <= waddr;
    end
end

always@(posedge m00.axi_aclk)begin
    if(~m00.axi_aresetn)    raddr    <= {NSIZE{1'b0}};
    else begin
        if(!rlock_addr)
                raddr    <= raddr_t;
        else    raddr    <= raddr;
    end
end

always@(posedge m00.axi_aclk)begin
    if(~m00.axi_aresetn)    waddr_vld    <= 1'b0;
    else begin
        if(wlock_addr)
                waddr_vld    <= waddr ==  curr_waddr;
        else    waddr_vld    <= 1'b0;
    end
end

always@(posedge m00.axi_aclk)begin
    if(~m00.axi_aresetn)    raddr_vld    <= 1'b0;
    else begin
        if(rlock_addr)
                raddr_vld    <= raddr ==  curr_raddr;
        else    raddr_vld    <= 1'b0;
    end
end
//---<< ADDR STATUS >>---------------------
//--->> WRITE LOCK <<----------------------
data_inf #(.DSIZE(1) ) s00_wlock_inf [NUM-1:0] ();
data_inf #(.DSIZE(1) ) m00_wlock_inf ();

generate
for(KK=0;KK<NUM;KK++)begin:WLOCK_GEN
assign s00_wlock_inf[KK].valid                           = s00[KK].axi_awlock;
assign s00_wlock_inf[KK].data                            = s00[KK].axi_awlock;
// assign s00[KK].axi_awready                               = s00_wlock_inf[KK].ready;
end
endgenerate



data_pipe_interconnect_M2S_verb #(
// data_pipe_interconnect_M2S #(
    .DSIZE      (1    ),
    .NUM        (NUM       )
)wlock_inst(
/*    input                 */    .clock            (m00.axi_aclk   ),
/*    input                 */    .rst_n            (m00.axi_aresetn ),
/*    input                 */    .clk_en           (1'b1           ),
// /*    input                  */   .vld_sw           (waddr_vld      ),
// /*    input [NSIZE-1:0]      */   .sw               (waddr          ),
// /*    output logic[NSIZE-1:0]*/   .curr_path        (curr_waddr     ),
/*    input [NSIZE-1:0]      */   .addr             (waddr          ),
/*    data_inf.slaver       */    .s00              (s00_wlock_inf  ),
/*    data_inf.master       */    .m00              (m00_wlock_inf  )
);

assign m00.axi_awlock            = m00_wlock_inf.data && m00_wlock_inf.valid;
// assign m00.axi_awvalid           = m00_wlock_inf.valid;
assign m00_wlock_inf.ready       = m00.axi_awready || 1'b1;
//---<< WRITE LOCK >>----------------------
//--->> AXIL WADDR <<-----------------------
data_inf #(.DSIZE(m00.ASIZE) ) s00_waddr_inf [NUM-1:0] ();
data_inf #(.DSIZE(m00.ASIZE) ) m00_waddr_inf ();

generate
for(KK=0;KK<NUM;KK++)begin
assign s00_waddr_inf[KK].valid                           = s00[KK].axi_awvalid;
assign s00_waddr_inf[KK].data                            = s00[KK].axi_awaddr;
assign s00[KK].axi_awready                               = s00_waddr_inf[KK].ready;
end
endgenerate

localparam sub_ASIZE = m00.ASIZE;

data_pipe_interconnect_M2S_verb #(
// data_pipe_interconnect_M2S #(
    .DSIZE      (sub_ASIZE    ),
    .NUM        (NUM       )
)waddr_inst(
/*    input                 */    .clock            (m00.axi_aclk   ),
/*    input                 */    .rst_n            (m00.axi_aresetn ),
/*    input                 */    .clk_en           (1'b1           ),
// /*    input                  */   .vld_sw           (waddr_vld      ),
// /*    input [NSIZE-1:0]      */   .sw               (waddr          ),
// /*    output logic[NSIZE-1:0]*/   .curr_path        (curr_waddr     ),
/*    input [NSIZE-1:0]      */   .addr             (waddr          ),
/*    data_inf.slaver       */    .s00              (s00_waddr_inf  ),
/*    data_inf.master       */    .m00              (m00_waddr_inf  )
);

assign m00.axi_awaddr            = m00_waddr_inf.data;
assign m00.axi_awvalid           = m00_waddr_inf.valid;
assign m00_waddr_inf.ready       = m00.axi_awready;
//---<< AXIL WADDR >>-----------------------
//--->> READ LOCK <<----------------------
data_inf #(.DSIZE(1) ) s00_rlock_inf [NUM-1:0] ();
data_inf #(.DSIZE(1) ) m00_rlock_inf ();

generate
for(KK=0;KK<NUM;KK++)begin:RLOCK_GEN
assign s00_rlock_inf[KK].valid                           = s00[KK].axi_arlock;
assign s00_rlock_inf[KK].data                            = s00[KK].axi_arlock;
// assign s00[KK].axi_awready                               = s00_wlock_inf[KK].ready;
end
endgenerate



data_pipe_interconnect_M2S_verb #(
    .DSIZE      (1    ),
    .NUM        (NUM       )
)rlock_inst(
/*    input                 */    .clock            (m00.axi_aclk   ),
/*    input                 */    .rst_n            (m00.axi_aresetn ),
/*    input                 */    .clk_en           (1'b1           ),
/*    input [NSIZE-1:0]      */   .addr             (raddr          ),
/*    data_inf.slaver       */    .s00              (s00_rlock_inf  ),
/*    data_inf.master       */    .m00              (m00_rlock_inf  )
);

assign m00.axi_arlock            = m00_rlock_inf.data;
// assign m00.axi_arvalid           = m00_rlock_inf.valid;
assign m00_rlock_inf.ready       = m00.axi_arready || 1'b1;
//---<< READ LOCK >>----------------------
//--->> AXIL RADDR <<-----------------------
data_inf #(.DSIZE(m00.ASIZE) ) s00_raddr_inf [NUM-1:0] ();
data_inf #(.DSIZE(m00.ASIZE) ) m00_raddr_inf ();


generate
for(KK=0;KK<NUM;KK++)begin
assign s00_raddr_inf[KK].valid                           = s00[KK].axi_arvalid;
assign s00_raddr_inf[KK].data                            = s00[KK].axi_araddr;
assign s00[KK].axi_arready                               = s00_raddr_inf[KK].ready;
end
endgenerate


data_pipe_interconnect_M2S_verb #(
    .DSIZE      (sub_ASIZE    ),
    .NUM        (NUM       )
)raddr_inst(
/*    input                 */    .clock            (m00.axi_aclk   ),
/*    input                 */    .rst_n            (m00.axi_aresetn ),
/*    input                 */    .clk_en           (1'b1           ),
// /*    input                  */   .vld_sw           (raddr_vld      ),
// /*    input [NSIZE-1:0]      */   .sw               (raddr          ),
// /*    output logic[NSIZE-1:0]*/   .curr_path        (curr_raddr     ),
/*    input [NSIZE-1:0]      */   .addr             (raddr          ),
/*    data_inf.slaver       */    .s00              (s00_raddr_inf  ),
/*    data_inf.master       */    .m00              (m00_raddr_inf  )
);

assign m00.axi_araddr            = m00_raddr_inf.data;
assign m00.axi_arvalid           = m00_raddr_inf.valid;
assign m00_raddr_inf.ready       = m00.axi_arready;
//---<< AXIL RADDR >>-----------------------
//--->> AXIL WDATA <<-----------------------
data_inf #(.DSIZE(m00.DSIZE) ) s00_wdata_inf [NUM-1:0] ();
data_inf #(.DSIZE(m00.DSIZE) ) m00_wdata_inf ();


generate
for(KK=0;KK<NUM;KK++)begin
assign s00_wdata_inf[KK].valid                           = s00[KK].axi_wvalid;
assign s00_wdata_inf[KK].data                            = s00[KK].axi_wdata;
assign s00[KK].axi_wready                               = s00_wdata_inf[KK].ready;
end
endgenerate


data_pipe_interconnect_M2S_verb #(
    .DSIZE      (m00.DSIZE   ),
    .NUM        (NUM       )
)wdata_inst(
/*    input                 */    .clock            (m00.axi_aclk   ),
/*    input                 */    .rst_n            (m00.axi_aresetn ),
/*    input                 */    .clk_en           (1'b1           ),
// /*    input                  */   .vld_sw           (waddr_vld      ),
// /*    input [NSIZE-1:0]      */   .sw               (waddr          ),
// /*    output logic[NSIZE-1:0]*/   .curr_path        (               ),
/*    input [NSIZE-1:0]      */   .addr             (waddr          ),
/*    data_inf.slaver       */    .s00              (s00_wdata_inf  ),
/*    data_inf.master       */    .m00              (m00_wdata_inf  )
);

assign m00.axi_wdata             = m00_wdata_inf.data;
assign m00.axi_wvalid            = m00_wdata_inf.valid;
assign m00_wdata_inf.ready       = m00.axi_wready;
//---<< AXIL WDATA >>-----------------------
//--->> AXIL RDATA <<-----------------------
data_inf #(.DSIZE(m00.DSIZE) ) s00_rdata_inf ();
data_inf #(.DSIZE(m00.DSIZE) ) m00_rdata_inf [NUM-1:0] ();

assign s00_rdata_inf.valid                           = m00.axi_rvalid;
assign s00_rdata_inf.data                            = m00.axi_rdata;
assign m00.axi_rready                                = s00_rdata_inf.ready;


data_pipe_interconnect_S2M_verb #(
    .NUM        (NUM       )
)rdata_inst(
/*    input                 */    .clock            (m00.axi_aclk   ),
/*    input                 */    .rst_n            (m00.axi_aresetn ),
/*    input                 */    .clk_en           (1'b1           ),
/*    input [NSIZE-1:0]     */    .addr             (raddr          ),       // sync to s00.valid
    // output logic[2:0]   curr_path,
/*    data_inf.master       */    .m00              (m00_rdata_inf  ),      //[NUM-1:0],
/*    data_inf.slaver       */    .s00              (s00_rdata_inf  )
);

generate
for(KK=0;KK<NUM;KK++)begin
assign s00[KK].axi_rdata             = m00_rdata_inf[KK].data;
assign s00[KK].axi_rvalid            = m00_rdata_inf[KK].valid;
assign m00_rdata_inf[KK].ready       = s00[KK].axi_rready;
end
endgenerate
//---<< AXIL RDATA >>-----------------------
//--->> AXIL BDATA <<-----------------------
data_inf #(.DSIZE(2) ) s00_bdata_inf ();
data_inf #(.DSIZE(2) ) m00_bdata_inf [NUM-1:0] ();

assign s00_bdata_inf.valid                           = m00.axi_bvalid;
assign s00_bdata_inf.data                            = m00.axi_bresp;
assign m00.axi_bready                                = s00_bdata_inf.ready;


data_pipe_interconnect_S2M_verb #(
    .NUM        (NUM       )
)bdata_inst(
/*    input                 */    .clock            (m00.axi_aclk   ),
/*    input                 */    .rst_n            (m00.axi_aresetn ),
/*    input                 */    .clk_en           (1'b1           ),
/*    input [NSIZE-1:0]     */    .addr             (waddr          ),       // sync to s00.valid
    // output logic[2:0]   curr_path,
/*    data_inf.master       */    .m00              (m00_bdata_inf  ),      //[NUM-1:0],
/*    data_inf.slaver       */    .s00              (s00_bdata_inf  )
);

generate
for(KK=0;KK<NUM;KK++)begin
assign s00[KK].axi_bresp             = m00_bdata_inf[KK].data;
assign s00[KK].axi_bvalid            = m00_bdata_inf[KK].valid;
assign m00_bdata_inf[KK].ready       = s00[KK].axi_bready;
end
endgenerate
//---<< AXIL BDATA >>-----------------------

endmodule
