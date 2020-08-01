/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/27 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_rd_interconnect_M2S #(
    parameter NUM = 8
)(
    axi_inf.master_rd slaver [NUM-1:0],
    axi_inf.slaver_rd master
);

localparam NSIZE =  $clog2(NUM);
logic[NSIZE-1:0]    raddr;
logic               raddr_vld;
logic[NSIZE-1:0]    curr_raddr;

//--->> STREAM CLOCK AND RESET <<-------------------
wire        clock,rst_n;
assign      clock   = m00.axi_aclk;
assign      rst_n   = m00.axi_aresetn;
//---<< STREAM CLOCK AND RESET >>-------------------
genvar KK;
//--->> ADDR STATUS <<---------------------
logic               rlock_addr;
logic [NUM-1:0]     rstart_s;
logic [NUM-1:0]     rrelex;

generate
for(KK=0;KK<NUM;KK++)begin
    assign rstart_s[KK]     = s00[KK].axi_arvalid;
    assign rrelex[KK]       = (s00[KK].axi_rvalid && s00[KK].axi_rready && s00[KK].axi_rlast) ;
end
endgenerate

int II;

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

logic [NSIZE-1:0]   raddr_t = {NSIZE{1'b0}};

always@(*)begin
    for(II=0;II<NUM;II++)begin
        raddr_t  = rstart_s[II]? II : raddr_t;
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
    if(~m00.axi_aresetn)    raddr_vld    <= 1'b0;
    else begin
        if(rlock_addr)
                raddr_vld    <= raddr ==  curr_raddr;
        else    raddr_vld    <= 1'b0;
    end
end
//---<< ADDR STATUS >>---------------------
//--->> AXI4 RADDR <<-----------------------
data_inf #(.DSIZE(m00.ASIZE+m00.LSIZE) ) s00_raddr_inf [NUM-1:0] ();
data_inf #(.DSIZE(m00.ASIZE+m00.LSIZE) ) m00_raddr_inf ();


generate
for(KK=0;KK<NUM;KK++)begin
assign s00_raddr_inf[KK].valid                           = s00[KK].axi_arvalid;
assign s00_raddr_inf[KK].data                            = {s00[KK].axi_araddr,s00[KK].axi_arlen};
assign s00[KK].axi_arready                               = s00_raddr_inf[KK].ready;
end
endgenerate


data_pipe_interconnect_M2S #(
    // .DSIZE      (m00.ASIZE+m00.LSIZE    ),
    .NUM        (NUM       )
)raddr_inst(
/*    input                 */    .clock            (m00.axi_aclk   ),
/*    input                 */    .rst_n            (m00.axi_aresetn ),
/*    input                 */    .clk_en           (1'b1           ),
/*    input                  */   .vld_sw           (raddr_vld      ),
/*    input [NSIZE-1:0]      */   .sw               (raddr          ),
/*    output logic[NSIZE-1:0]*/   .curr_path        (curr_raddr     ),
// /*    input [NSIZE-1:0]      */   .addr             (raddr          ),
/*    data_inf.slaver       */    .s00              (s00_raddr_inf  ),
/*    data_inf.master       */    .m00              (m00_raddr_inf  )
);

assign m00.axi_araddr            = m00_raddr_inf.data[m00.ASIZE+m00.LSIZE-1-:m00.ASIZE];
assign m00.axi_arlen             = m00_raddr_inf.data[m00.LSIZE-1:0];
assign m00.axi_arvalid           = m00_raddr_inf.valid;
assign m00_raddr_inf.ready       = m00.axi_arready;
//---<< AXI4 RADDR >>-----------------------
//--->> AXI4 RDATA <<-----------------------
data_inf #(.DSIZE(m00.DSIZE+1) ) s00_rdata_inf ();
data_inf #(.DSIZE(m00.DSIZE+1) ) m00_rdata_inf [NUM-1:0] ();

assign s00_rdata_inf.valid                           = m00.axi_rvalid;
assign s00_rdata_inf.data                            = {m00.axi_rlast,m00.axi_rdata};
assign m00.axi_rready                                = s00_rdata_inf.ready;


data_pipe_interconnect_S2M_verb #(
    .DSIZE      (m00.DSIZE+1   ),
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
assign s00[KK].axi_rdata             = m00_rdata_inf[KK].data[m00.DSIZE-1:0];
assign s00[KK].axi_rlast             = m00_rdata_inf[KK].data[m00.DSIZE];
assign s00[KK].axi_rvalid            = m00_rdata_inf[KK].valid;
assign m00_rdata_inf[KK].ready       = s00[KK].axi_rready;
end
endgenerate
//---<< AXI4 RDATA >>-----------------------

endmodule
