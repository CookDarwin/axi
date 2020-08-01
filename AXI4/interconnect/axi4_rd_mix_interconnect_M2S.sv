/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    The slaver dont need to wait current burst finished,when get next burst
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/27 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_rd_mix_interconnect_M2S #(
    parameter NUM = 8
)(
    axi_inf.slaver_rd slaver [NUM-1:0],
    axi_inf.master_rd master
);
localparam NSIZE =  $clog2(NUM);

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

//--->> AUXILIARY <<----------------
logic[NSIZE-1:0]    raddr;

logic               rlock_addr;
logic [NUM-1:0]     rstart_s;
logic [NUM-1:0]     rrelex;

genvar KK;

generate
for(KK=0;KK<NUM;KK++)begin
    assign rstart_s[KK]     = slaver[KK].axi_arvalid;
    assign rrelex[KK]       = (slaver[KK].axi_rvalid && slaver[KK].axi_rready && slaver[KK].axi_rlast) ;
end
endgenerate

int II;

always@(posedge master.axi_aclk)begin
    if(~master.axi_aresetn)    rlock_addr   <= 1'b0;
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


always@(posedge master.axi_aclk)begin
    if(~master.axi_aresetn)    raddr    <= {NSIZE{1'b0}};
    else begin
        if(!rlock_addr)
                raddr    <= raddr_t;
        else    raddr    <= raddr;
    end
end

// always@(posedge master.axi_aclk)begin
//     if(~master.axi_aresetn)    raddr_vld    <= 1'b0;
//     else begin
//         if(rlock_addr)
//                 raddr_vld    <= raddr ==  curr_raddr;
//         else    raddr_vld    <= 1'b0;
//     end
// end
//---<< ADDR STATUS >>---------------------
//--->> RD ID <<---------------------------
logic [NSIZE-1:0]   port_id [NUM-1:0];
generate
for(KK=0;KK<NUM;KK++)begin:ID_BLOCK
assign port_id[KK]   = KK;
end
endgenerate
//---<< RD ID >>---------------------------
//--->> AXI4 RADDR <<-----------------------
data_inf #(.DSIZE(master.ASIZE+master.LSIZE+master.IDSIZE) ) s00_raddr_inf [NUM-1:0] ();
data_inf #(.DSIZE(master.ASIZE+master.LSIZE+master.IDSIZE) ) m00_raddr_inf ();


generate
for(KK=0;KK<NUM;KK++)begin
assign s00_raddr_inf[KK].valid                           = slaver[KK].axi_arvalid;
assign s00_raddr_inf[KK].data                            = {{slaver[KK].axi_arid,port_id[KK]},slaver[KK].axi_araddr,slaver[KK].axi_arlen};
assign slaver[KK].axi_arready                            = s00_raddr_inf[KK].ready;
end
endgenerate


data_pipe_interconnect_M2S_verb #(
    .DSIZE      (master.ASIZE+master.LSIZE+ master.IDSIZE   ),
    .NUM        (NUM       )
)raddr_inst(
/*    input                 */    .clock            (master.axi_aclk   ),
/*    input                 */    .rst_n            (master.axi_aresetn ),
/*    input                 */    .clk_en           (1'b1           ),
// /*    input                  */   .vld_sw           (raddr_vld      ),
// /*    input [NSIZE-1:0]      */   .sw               (raddr          ),
// /*    output logic[NSIZE-1:0]*/   .curr_path        (curr_raddr     ),
/*    input [NSIZE-1:0]      */   .addr             (raddr          ),
/*    data_inf.slaver       */    .s00              (s00_raddr_inf  ),
/*    data_inf.master       */    .m00              (m00_raddr_inf  )
);

assign master.axi_araddr            = m00_raddr_inf.data[master.ASIZE+master.LSIZE-1-:master.ASIZE];
assign master.axi_arlen             = m00_raddr_inf.data[master.LSIZE-1:0];
assign master.axi_arid              = m00_raddr_inf.data[master.ASIZE+master.LSIZE+master.IDSIZE -1-:master.IDSIZE ];
assign master.axi_arvalid           = m00_raddr_inf.valid;
assign m00_raddr_inf.ready       = master.axi_arready;

//---<< AUXILIARY >>----------------
//--->> AXI4 RDATA <<-----------------------
data_inf #(.DSIZE(master.DSIZE+1) ) s00_rdata_inf ();
data_inf #(.DSIZE(master.DSIZE+1) ) m00_rdata_inf [NUM-1:0] ();

logic [slaver[0].IDSIZE-1:0]    s00_rid [NUM-1:0];
logic [master.IDSIZE-1:0]       m00_rid ;

assign s00_rdata_inf.valid                           = master.axi_rvalid;
assign s00_rdata_inf.data                            = {master.axi_rlast,master.axi_rdata};
assign master.axi_rready                             = s00_rdata_inf.ready;


// data_pipe_interconnect_S2M #(
//     .DSIZE      (master.DSIZE+1+slaver[0].IDSIZE   ),
//     .NUM        (NUM       )
// )rdata_inst(
// /*    input                 */    .clock            (master.axi_aclk   ),
// /*    input                 */    .rst_n            (master.axi_aresetn ),
// /*    input                 */    .clk_en           (1'b1           ),
// /*    input [NSIZE-1:0]     */    .addr             (master.axi_rid[NSIZE-1:0]  ),       // sync to slaver.valid
//     // output logic[2:0]   curr_path,
// /*    data_inf.master       */    .m00              (m00_rdata_inf  ),      //[NUM-1:0],
// /*    data_inf.slaver       */    .s00              (s00_rdata_inf  )
// );

data_pipe_interconnect_S2M_A1 #(
    .DSIZE      (master.DSIZE+1     ),
    .NUM        (NUM                ),
    .LAZISE     (slaver[0].IDSIZE   )
)rdata_inst(
/*  input               */  .clock            (master.axi_aclk   ),
/*  input               */  .rst_n            (master.axi_aresetn ),
/*  input               */  .clk_en           (1'b1           ),
/*  input [NSIZE-1:0]   */  .addr             (master.axi_rid[NSIZE-1:0]  ),       // sync to slaver.valid
/*  // output logic[2:0]*/    // curr_path,
/*  output [LAZISE-1:0] */  .m00_lazy_data    (s00_rid        ),//[NUM-1:0],
/*  input [LAZISE-1:0]  */  .s00_lazy_data    (m00_rid        ),//,
/*  data_inf.master     */  .m00              (m00_rdata_inf  ),      //[NUM-1:0],
/*  data_inf.slaver     */  .s00              (s00_rdata_inf  )
);

assign m00_rid  = master.axi_rid[master.IDSIZE-1:NSIZE];

generate
for(KK=0;KK<NUM;KK++)begin
assign slaver[KK].axi_rid               = s00_rid[KK];
assign slaver[KK].axi_rdata             = m00_rdata_inf[KK].data[master.DSIZE-1:0];
assign slaver[KK].axi_rlast             = m00_rdata_inf[KK].data[master.DSIZE];
assign slaver[KK].axi_rvalid            = m00_rdata_inf[KK].valid;
assign m00_rdata_inf[KK].ready          = slaver[KK].axi_rready;
end
endgenerate
//---<< AXI4 RDATA >>-----------------------
//--->> TRACK <<----------------
(* dont_touch= "true" *)
logic [master.IDSIZE-1:0]   track_arid;
(* dont_touch= "true" *)
logic [master.IDSIZE-1:0]   track_rid;

(* dont_touch= "true" *)
logic [slaver[0].IDSIZE-1:0]   slaver0_track_arid;
(* dont_touch= "true" *)
logic [slaver[0].IDSIZE-1:0]   slaver0_track_rid;

(* dont_touch= "true" *)
logic [slaver[1].IDSIZE-1:0]   slaver1_track_arid;
(* dont_touch= "true" *)
logic [slaver[1].IDSIZE-1:0]   slaver1_track_rid;

always_ff@(posedge master.axi_aclk,negedge master.axi_aresetn)
    if(!master.axi_aresetn)  track_arid  <= '0;
    else begin
        if(master.axi_arvalid && master.axi_arready)
                track_arid  <= master.axi_arid;
        else    track_arid  <= track_arid;
    end

always_ff@(posedge master.axi_aclk,negedge master.axi_aresetn)
    if(!master.axi_aresetn)  track_rid  <= '0;
    else begin
        if(master.axi_rvalid && master.axi_rready)
                track_rid  <= master.axi_rid;
        else    track_rid  <= track_rid;
    end

always_ff@(posedge master.axi_aclk,negedge master.axi_aresetn)
    if(!master.axi_aresetn)  slaver0_track_arid  <= '0;
    else begin
        if(slaver[0].axi_arvalid && slaver[0].axi_arready)
                slaver0_track_arid  <= slaver[0].axi_arid;
        else    slaver0_track_arid  <= slaver0_track_arid;
    end

always_ff@(posedge master.axi_aclk,negedge master.axi_aresetn)
    if(!master.axi_aresetn)  slaver0_track_rid  <= '0;
    else begin
        if(slaver[0].axi_rvalid && slaver[0].axi_rready)
                slaver0_track_rid  <= slaver[0].axi_rid;
        else    slaver0_track_rid  <= slaver0_track_rid;
    end

always_ff@(posedge master.axi_aclk,negedge master.axi_aresetn)
    if(!master.axi_aresetn)  slaver1_track_arid  <= '0;
    else begin
        if(slaver[1].axi_arvalid && slaver[1].axi_arready)
                slaver1_track_arid  <= slaver[1].axi_arid;
        else    slaver1_track_arid  <= slaver1_track_arid;
    end

always_ff@(posedge master.axi_aclk,negedge master.axi_aresetn)
    if(!master.axi_aresetn)  slaver1_track_rid  <= '0;
    else begin
        if(slaver[1].axi_rvalid && slaver[1].axi_rready)
                slaver1_track_rid  <= slaver[1].axi_rid;
        else    slaver1_track_rid  <= slaver1_track_rid;
    end
//---<< TRACK >>----------------

endmodule
