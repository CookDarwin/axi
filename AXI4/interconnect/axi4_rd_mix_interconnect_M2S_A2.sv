/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    The slaver dont need to wait current burst finished,when get next burst
author : Cook.Darwin
Version: VERA.2.0
    use data_inf_c
Version: VERA.2.1 
    use data_c_pipe_intc_M2S_robin_with_id
creaded: 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_rd_mix_interconnect_M2S_A2 #(
    parameter NUM = 8
)(
    axi_inf.slaver_rd slaver [NUM-1:0],
    axi_inf.master_rd master
);
localparam NSIZE =  $clog2(NUM);

import SystemPkg::*;

// localparam LAZISE = slaver[0].IDSIZE;
localparam LAZISE = master.IDSIZE - NSIZE;

initial begin
    // assert(slaver[0].IDSIZE+NSIZE == master.IDSIZE)
    assert(LAZISE+NSIZE == master.IDSIZE)
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
// logic[NSIZE-1:0]    raddr;
//
// logic               rlock_addr;
// logic [NUM-1:0]     rstart_s;
// logic [NUM-1:0]     rrelex;
//
// genvar KK;
//
// generate
// for(KK=0;KK<NUM;KK++)begin
//     assign rstart_s[KK]     = slaver[KK].axi_arvalid;
//     assign rrelex[KK]       = (slaver[KK].axi_rvalid && slaver[KK].axi_rready && slaver[KK].axi_rlast) ;
// end
// endgenerate
//
// int II;
//
// always@(posedge master.axi_aclk)begin
//     if(~master.axi_aresetn)    rlock_addr   <= 1'b0;
//     else begin
//         if(|rrelex)
//                 rlock_addr   <= 1'b0;
//         else if(|rstart_s)
//                 rlock_addr   <= 1'b1;
//         else    rlock_addr   <= rlock_addr;
//     end
// end
//
// logic [NSIZE-1:0]   raddr_t = {NSIZE{1'b0}};
//
// always@(*)begin
//     for(II=0;II<NUM;II++)begin
//         raddr_t  = rstart_s[II]? II : raddr_t;
//     end
// end
//
//
// always@(posedge master.axi_aclk)begin
//     if(~master.axi_aresetn)    raddr    <= {NSIZE{1'b0}};
//     else begin
//         if(!rlock_addr)
//                 raddr    <= raddr_t;
//         else    raddr    <= raddr;
//     end
// end

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
// logic [NSIZE-1:0]   port_id [NUM-1:0];
// generate
// for(KK=0;KK<NUM;KK++)begin:ID_BLOCK
// assign port_id[KK]   = KK;
// end
// endgenerate
//---<< RD ID >>---------------------------
//--->> RD ID <<---------------------------
genvar KK;
logic [NSIZE-1:0]                   port_arid [NUM-1:0];
// logic [slaver[0].IDSIZE+NSIZE-1:0]  arid [NUM-1:0];
bit [LAZISE+NSIZE-1:0]  arid [NUM-1:0];
generate
for(KK=0;KK<NUM;KK++)begin:ARID_BLOCK
assign port_arid[KK]   = KK;
assign arid[KK]        = {slaver[KK].axi_arid,port_arid[KK]};
end
endgenerate
//---<< RD ID >>---------------------------
//--->> AXI4 RADDR <<-----------------------
data_inf_c #(.DSIZE(master.ASIZE+master.LSIZE) ) s00_raddr_inf [NUM-1:0] (clock,rst_n);
data_inf_c #(.DSIZE(master.ASIZE+master.LSIZE) ) m00_raddr_inf (clock,rst_n);


generate
for(KK=0;KK<NUM;KK++)begin
assign s00_raddr_inf[KK].valid                           = slaver[KK].axi_arvalid;
assign s00_raddr_inf[KK].data                            = {slaver[KK].axi_araddr,slaver[KK].axi_arlen};
assign slaver[KK].axi_arready                            = s00_raddr_inf[KK].ready;
end
endgenerate


// data_pipe_interconnect_M2S_verb #(
//     .DSIZE      (master.ASIZE+master.LSIZE+ master.IDSIZE   ),
//     .NUM        (NUM       )
// )raddr_inst(
// /*    input                 */    .clock            (master.axi_aclk   ),
// /*    input                 */    .rst_n            (master.axi_aresetn ),
// /*    input                 */    .clk_en           (1'b1           ),
// // /*    input                  */   .vld_sw           (raddr_vld      ),
// // /*    input [NSIZE-1:0]      */   .sw               (raddr          ),
// // /*    output logic[NSIZE-1:0]*/   .curr_path        (curr_raddr     ),
// /*    input [NSIZE-1:0]      */   .addr             (raddr          ),
// /*    data_inf.slaver       */    .s00              (s00_raddr_inf  ),
// /*    data_inf.master       */    .m00              (m00_raddr_inf  )
// );

// data_inf_interconnect_M2S_with_id_noaddr #(
//     .NUM        (NUM            ),
//     .IDSIZE     (master.IDSIZE  )
// )raddr_inst(
// /*  input              */ .clock        (master.axi_aclk   ),
// /*  input              */ .rst_n        (master.axi_aresetn ),
// /*  input [IDSIZE-1:0] */ .sid          (arid              ),//[NUM-1:0],
// /*  output[IDSIZE-1:0] */ .mid          (master.axi_arid   ),//,
// /*  data_inf.slaver    */ .s00          (s00_raddr_inf     ),//[NUM-1:0],
// /*  data_inf.master    */ .m00          (m00_raddr_inf     )
// );

// data_c_pipe_intc_M2S_verc_with_id #(
//     .PRIO       ("ROBIN"   ),   //BEST_ROBIN BEST_LAST ROBIN LAST WAIT_IDLE
//     // .PRIO       ("WAIT_IDLE"   ),   //BEST_ROBIN BEST_LAST ROBIN LAST WAIT_IDLE
//     .NUM        (NUM            ),
//     .IDSIZE     (master.IDSIZE  )
// )raddr_inst(
// /*  input [NUM-1:0]        */   .last       ('1                 ),             //ctrl prio
// /*  input [IDSIZE-1:0]     */   .sid        (arid               ),//[NUM-1:0],
// /*  output[IDSIZE-1:0]     */   .mid        (master.axi_arid    ),
// /*  data_inf_c.slaver      */   .s00        (s00_raddr_inf      ),//[NUM-1:0],
// /*  data_inf_c.master      */   .m00        (m00_raddr_inf      )
// );

data_c_pipe_intc_M2S_robin_with_id #(
    .NUM        (NUM            ),
    .IDSIZE     (master.IDSIZE  )
)raddr_inst(
/*  input [IDSIZE-1:0]     */   .sid        (arid               ),//[NUM-1:0],
/*  output[IDSIZE-1:0]     */   .mid        (master.axi_arid    ),
/*  data_inf_c.slaver      */   .s00        (s00_raddr_inf      ),//[NUM-1:0],
/*  data_inf_c.master      */   .m00        (m00_raddr_inf      )
);

assign master.axi_araddr            = m00_raddr_inf.data[master.ASIZE+master.LSIZE-1-:master.ASIZE];
assign master.axi_arlen             = m00_raddr_inf.data[master.LSIZE-1:0];
// assign master.axi_arid              = m00_raddr_inf.data[master.ASIZE+master.LSIZE+master.IDSIZE -1-:master.IDSIZE ];
assign master.axi_arvalid           = m00_raddr_inf.valid;
assign m00_raddr_inf.ready       = master.axi_arready;

//---<< AUXILIARY >>----------------
//--->> AXI4 RDATA <<-----------------------
data_inf_c #(.DSIZE(master.DSIZE+1) ) s00_rdata_inf (clock,rst_n);
data_inf_c #(.DSIZE(master.DSIZE+1) ) m00_rdata_inf [NUM-1:0] (clock,rst_n);

// logic [slaver[0].IDSIZE-1:0]    s00_rid [NUM-1:0];
logic [LAZISE-1:0]    s00_rid [NUM-1:0];
// logic [master.IDSIZE-1:0]       m00_rid ;
logic [LAZISE-1:0]       m00_rid ;

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

// data_pipe_interconnect_S2M_A1 #(
//     .DSIZE      (master.DSIZE+1     ),
//     .NUM        (NUM                ),
//     .LAZISE     (LAZISE             )
// )rdata_inst(
// /*  input               */  .clock            (master.axi_aclk   ),
// /*  input               */  .rst_n            (master.axi_aresetn ),
// /*  input               */  .clk_en           (1'b1           ),
// /*  input [NSIZE-1:0]   */  .addr             (master.axi_rid[NSIZE-1:0]  ),       // sync to slaver.valid
// /*  // output logic[2:0]*/    // curr_path,
// /*  output [LAZISE-1:0] */  .m00_lazy_data    (s00_rid        ),//[NUM-1:0],
// /*  input [LAZISE-1:0]  */  .s00_lazy_data    (m00_rid        ),//,
// /*  data_inf.master     */  .m00              (m00_rdata_inf  ),      //[NUM-1:0],
// /*  data_inf.slaver     */  .s00              (s00_rdata_inf  )
// );

data_inf_c_intc_S2M_with_lazy #(
    .NUM        (NUM        ),
    .LAZISE     (LAZISE     )
)rdata_inst(
/*  input [NSIZE-1:0]     */  .addr             (master.axi_rid[NSIZE-1:0]  ),       // sync to s00.valid
/*  output[LAZISE-1:0]    */  .m00_lazy_data    (s00_rid                    ),//[NUM-1:0],
/*  input [LAZISE-1:0]    */  .s00_lazy_data    (m00_rid                    ),
/*  data_inf_c.master     */  .m00              (m00_rdata_inf              ),//[NUM-1:0],
/*  data_inf_c.slaver     */  .s00              (s00_rdata_inf              )
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
(* dont_touch="true" *)
logic [3:0]     rd_record [NUM-1:0];
genvar             II;
generate
for(II=0;II<NUM;II++)begin 
always_ff@(posedge clock,negedge rst_n)begin 
    if(~rst_n ) 
        rd_record[II]   <= '0;
    else begin
        if(slaver[II].axi_arready && slaver[II].axi_arvalid && slaver[II].axi_rready && slaver[II].axi_rvalid && slaver[II].axi_rlast)
            rd_record[II]   <= rd_record[II];
        else if(slaver[II].axi_arready && slaver[II].axi_arvalid)
            rd_record[II]   <= rd_record[II] + 1;
        else if(slaver[II].axi_rready && slaver[II].axi_rvalid && slaver[II].axi_rlast)
            rd_record[II]   <= rd_record[II] - 1;
        else 
            rd_record[II]   <= rd_record[II];
    end 
end 
end
endgenerate
//---<< TRACK >>----------------

endmodule
