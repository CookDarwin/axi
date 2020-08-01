/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.1.0 2017/5/23 
    add priority
    add ex awid
creaded: 2017/2/27 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_wr_interconnect_M2S_A1 #(
    parameter NUM = 8
)(
    axi_inf.slaver_wr slaver [NUM-1:0],
    axi_inf.master_wr master
);

localparam NSIZE =  $clog2(NUM);
logic[NSIZE-1:0]    waddr;
logic               waddr_vld;
logic[NSIZE-1:0]    curr_waddr;

import SystemPkg::*;

initial begin
    assert(slaver[0].IDSIZE+NSIZE == master.IDSIZE)
    else begin
        $error("SLAVER AXIS IDSIZE + NSIZE != MASTER AXIS IDSIZE");
        $stop;
    end
end


//--->> STREAM CLOCK AND RESET <<-------------------
wire        clock,rst_n;
assign      clock   = master.axi_aclk;
assign      rst_n   = master.axi_aresetn;
//---<< STREAM CLOCK AND RESET >>-------------------
genvar KK;
//--->> ADDR STATUS <<---------------------

logic               wlock_addr;
logic [NUM-1:0]     wstart_s;
logic [NUM-1:0]     wrelex;
logic [NUM-1:0]     prio;


generate
for(KK=0;KK<NUM;KK++)begin
    assign wstart_s[KK]     = slaver[KK].axi_awvalid ;
    // assign wrelex[KK]       = (slaver[KK].axi_bvalid && slaver[KK].axi_bready);
    assign wrelex[KK]       = (slaver[KK].axi_wvalid && slaver[KK].axi_wready && slaver[KK].axi_wlast);
end
endgenerate

int II;

always@(posedge master.axi_aclk)begin:LOCK_BLOCK
    if(~master.axi_aresetn)    wlock_addr   <= 1'b0;
    else begin
        if(|wrelex)
                wlock_addr   <= 1'b0;
        else if(|(wstart_s & prio) == 1'b1)
                wlock_addr   <= 1'b1;
        else    wlock_addr   <= wlock_addr;
    end
end

//--->> LOOP CHK <<-------------------------
int JJ;
logic [NSIZE-1:0]   waddr_t [NUM-1:0]   = '{NUM{0}};

always@(*)begin
    for(JJ=0;JJ<NUM;JJ++)begin
        waddr_t[JJ] = 0;
        for(II=0;II<NUM;II++)begin
            waddr_t[JJ]  = (wstart_s[II] && prio[II])? II : waddr_t[JJ];
        end
        waddr_t[JJ]  = (wstart_s[JJ] && prio[JJ])? JJ : waddr_t[JJ];   //recheck top prio
    end
end
//---<< LOOP CHK >>-------------------------

logic lock_raising;
logic lock_falling;

edge_generator lock_edge_generator_inst(
/*  input       */  .clk        (master.axi_aclk      ),
/*  input       */  .rst_n      (master.axi_aresetn    ),
/*  input       */  .in         (wlock_addr           ),
/*  output      */  .raising    (lock_raising         ),
/*  output      */  .falling    (lock_falling         )
);

logic [4:0]     t_sw;
always@(posedge master.axi_aclk)begin
    if(~master.axi_aresetn)    t_sw    <= '0;
    else begin
        if(lock_raising)begin
            if(t_sw < NUM-1)
                    t_sw    <= t_sw + 1'b1;
            else    t_sw    <= '0;
        end else    t_sw    <= t_sw;
    end
end

always@(posedge master.axi_aclk)begin
    if(~master.axi_aresetn)    waddr    <= {NSIZE{1'b0}};
    else begin
        if(!wlock_addr)
                waddr    <= waddr_t[t_sw];
        else    waddr    <= waddr;
    end
end


always@(posedge master.axi_aclk)begin
    if(~master.axi_aresetn)    waddr_vld    <= 1'b0;
    else begin
        if(wlock_addr)
                waddr_vld    <= waddr ==  curr_waddr;
        else    waddr_vld    <= 1'b0;
    end
end

//--->> priority control <<---------------
always@(posedge master.axi_aclk)begin
    if(~master.axi_aresetn)    prio    <= '1;
    else begin
        if(waddr_vld)begin
            foreach(prio[i])
                prio[i] <= waddr != i;
        end else if( ! ( |(wstart_s & prio) ) ) begin
            prio    <= '1;
        end else begin
            prio    <= prio;
        end
    end
end
//---<< priority control >>---------------
//---<< ADDR STATUS >>---------------------
//--->> AXI4 WADDR <<-----------------------
data_inf #(.DSIZE(master.ASIZE+master.LSIZE+master.IDSIZE) ) s00_waddr_inf [NUM-1:0] ();
data_inf #(.DSIZE(master.ASIZE+master.LSIZE+master.IDSIZE) ) m00_waddr_inf ();

logic [NSIZE-1:0]   port_awid [NUM-1:0];

generate
for(KK=0;KK<NUM;KK++)begin
assign port_awid[KK]                                     = KK;
assign s00_waddr_inf[KK].valid                           = slaver[KK].axi_awvalid;
assign s00_waddr_inf[KK].data                            = {{slaver[KK].axi_awid,port_awid[KK]},slaver[KK].axi_awaddr,slaver[KK].axi_awlen};
assign slaver[KK].axi_awready                            = s00_waddr_inf[KK].ready;
end
endgenerate


data_pipe_interconnect_M2S_A1 #(
    .DSIZE      (master.ASIZE+master.LSIZE+master.IDSIZE    ),
    .NUM        (NUM       )
)waddr_inst(
/*    input                 */    .clock            (master.axi_aclk   ),
/*    input                 */    .rst_n            (master.axi_aresetn ),
/*    input                 */    .clk_en           (1'b1           ),
/*    input                  */   .vld_sw           (waddr_vld      ),
/*    input [NSIZE-1:0]      */   .sw               (waddr          ),
/*    output logic[NSIZE-1:0]*/   .curr_path        (curr_waddr     ),
// /*    input [NSIZE-1:0]      */   .addr             (waddr          ),
/*    input [NUM-1:0]       */    .prio             (prio           ),
/*    data_inf.slaver       */    .s00              (s00_waddr_inf  ),
/*    data_inf.master       */    .m00              (m00_waddr_inf  )
);

assign master.axi_awid           = m00_waddr_inf.data[master.ASIZE+master.LSIZE+master.IDSIZE-1-:master.IDSIZE];
assign master.axi_awaddr         = m00_waddr_inf.data[master.ASIZE+master.LSIZE-1-:master.ASIZE];
assign master.axi_awlen          = m00_waddr_inf.data[master.LSIZE-1:0];
assign master.axi_awvalid        = m00_waddr_inf.valid;
assign m00_waddr_inf.ready       = master.axi_awready;
//---<< AXI4 WADDR >>-----------------------
// //--->> AXI4 AWID <<-----------------------
// data_inf #(.DSIZE(master.IDSIZE) ) s00_awid_inf [NUM-1:0] ();
// data_inf #(.DSIZE(master.IDSIZE) ) m00_awid_inf ();
//
//
// generate
// for(KK=0;KK<NUM;KK++)begin
// assign s00_awid_inf[KK].valid                           = slaver[KK].axi_awvalid;
// assign s00_awid_inf[KK].data                            = {slaver[KK].axi_awaddr,slaver[KK].axi_awlen};
// assign slaver[KK].axi_awready                               = s00_waddr_inf[KK].ready;
// end
// endgenerate
//
//
// data_pipe_interconnect_M2S #(
//     .DSIZE      (master.IDSIZE    ),
//     .NUM        (NUM       )
// )awid_inst(
// /*    input                 */    .clock            (master.axi_aclk   ),
// /*    input                 */    .rst_n            (master.axi_aresetn ),
// /*    input                 */    .clk_en           (1'b1           ),
// /*    input                  */   .vld_sw           (waddr_vld      ),
// /*    input [NSIZE-1:0]      */   .sw               (waddr          ),
// /*    output logic[NSIZE-1:0]*/   .curr_path        (curr_waddr     ),
// // /*    input [NSIZE-1:0]      */   .addr             (waddr          ),
// /*    data_inf.slaver       */    .s00              (s00_waddr_inf  ),
// /*    data_inf.master       */    .m00              (m00_waddr_inf  )
// );
//
// assign master.axi_awaddr            = m00_waddr_inf.data[master.ASIZE+master.LSIZE-1-:master.ASIZE];
// assign master.axi_awlen             = m00_waddr_inf.data[master.LSIZE-1:0];
// assign master.axi_awvalid           = m00_waddr_inf.valid;
// assign m00_waddr_inf.ready       = master.axi_awready;
// //---<< AXI4 AWID >>-----------------------
//--->> AXI4 WDATA <<-----------------------e

data_inf #(.DSIZE(master.DSIZE+1) ) s00_wdata_inf [NUM-1:0] ();
data_inf #(.DSIZE(master.DSIZE+1) ) m00_wdata_inf ();


generate
for(KK=0;KK<NUM;KK++)begin
assign s00_wdata_inf[KK].valid           = slaver[KK].axi_wvalid;
assign s00_wdata_inf[KK].data            = {slaver[KK].axi_wlast,slaver[KK].axi_wdata};
assign slaver[KK].axi_wready             = s00_wdata_inf[KK].ready;
end
endgenerate


data_pipe_interconnect_M2S_verb #(
    .DSIZE      (master.DSIZE+1   ),
    .NUM        (NUM       )
)wdata_inst(
/*    input                 */    .clock            (master.axi_aclk   ),
/*    input                 */    .rst_n            (master.axi_aresetn ),
/*    input                 */    .clk_en           (1'b1           ),
// /*    input                  */   .vld_sw           (waddr_vld      ),
// /*    input [NSIZE-1:0]      */   .sw               (waddr          ),
// /*    output logic[NSIZE-1:0]*/   .curr_path        (               ),
/*    input [NSIZE-1:0]      */   .addr             (waddr          ),
/*    data_inf.slaver       */    .s00              (s00_wdata_inf  ),
/*    data_inf.master       */    .m00              (m00_wdata_inf  )
);

assign master.axi_wdata             = m00_wdata_inf.data[master.DSIZE-1:0];
assign master.axi_wlast             = m00_wdata_inf.data[master.DSIZE];
assign master.axi_wvalid            = m00_wdata_inf.valid;
assign m00_wdata_inf.ready       = master.axi_wready;
//---<< AXI4 WDATA >>-----------------------
//--->> AXI4 BDATA <<-----------------------
data_inf #(.DSIZE(2+slaver[0].IDSIZE) ) s00_bdata_inf ();
data_inf #(.DSIZE(2+slaver[0].IDSIZE) ) m00_bdata_inf [NUM-1:0] ();

assign s00_bdata_inf.valid                           = master.axi_bvalid;
assign s00_bdata_inf.data                            = {master.axi_bid[master.IDSIZE-1:NSIZE],master.axi_bresp};
assign master.axi_bready                             = s00_bdata_inf.ready;


data_pipe_interconnect_S2M_verb #(
    .NUM        (NUM       )
)bdata_inst(
/*    input                 */    .clock            (master.axi_aclk   ),
/*    input                 */    .rst_n            (master.axi_aresetn ),
/*    input                 */    .clk_en           (1'b1              ),
/*    input [NSIZE-1:0]     */    .addr             (master.axi_bid[NSIZE-1:0]          ),       // sync to slaver.valid
    // output logic[2:0]   curr_path,
/*    data_inf.master       */    .m00              (m00_bdata_inf  ),      //[NUM-1:0],
/*    data_inf.slaver       */    .s00              (s00_bdata_inf  )
);

generate
for(KK=0;KK<NUM;KK++)begin
assign slaver[KK].axi_bid               = m00_bdata_inf[KK].data[2+:slaver[KK].IDSIZE];
assign slaver[KK].axi_bresp             = m00_bdata_inf[KK].data[1:0];
assign slaver[KK].axi_bvalid            = m00_bdata_inf[KK].valid;
assign m00_bdata_inf[KK].ready          = slaver[KK].axi_bready;
end
endgenerate
//---<< AXI4 BDATA >>-----------------------

endmodule
