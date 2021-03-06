/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018/11/26 
madified:
***********************************************/
`timescale 1ns / 1ps
module ddr_axi4_to_axis (
    axi_inf.slaver              axi4_inf,
    axi_stream_inf.master       axis_inf,       // DSIZE + ASIZE + 3
    axi_stream_inf.slaver       axis_rd_inf     //DSIZE
);

axi_stream_inf #(axis_inf.DSIZE)    sub_axis_inf [1:0]  (axis_inf.aclk,axis_inf.aresetn,axis_inf.aclken);
//--->> CheckClock <<----------------
logic cc_done;
logic cc_same;
CheckPClock CheckPClock_inst(
/*  input         */      .aclk     (axis_inf.aclk    ),
/*  input         */      .bclk     (axis_rd_inf.aclk    ),
/*  output logic  */      .done     (cc_done        ),
/*  output logic  */      .same     (cc_same        )
);

initial begin
    wait(cc_done);
    assert(cc_same)
    else begin
        $error("`ddr_axi4_t_axis` clock is not same");
        $stop;
    end
end

logic cc_done1;
logic cc_same1;
CheckPClock CheckPClock_inst1(
/*  input         */      .aclk     (axi4_inf.axi_aclk    ),
/*  input         */      .bclk     (axis_rd_inf.aclk    ),
/*  output logic  */      .done     (cc_done1        ),
/*  output logic  */      .same     (cc_same1        )
);

initial begin
    wait(cc_done1);
    assert(cc_same1)
    else begin
        $error("`ddr_axi4_to_axis` clock is not same");
        $stop;
    end
end
//---<< CheckClock >>----------------

initial begin
    assert(axi4_inf.ASIZE+axi4_inf.DSIZE + 3 == axis_inf.DSIZE)
    else begin
        $error("AXI4.DSIZE#%0d + AXI4.ASIZE#%0d + 3 != AXIS.DSIZE#%0d",axi4_inf.DSIZE,axi4_inf.ASIZE,axis_inf.DSIZE);
        $stop;
    end
    assert(axi4_inf.DSIZE == axis_rd_inf.DSIZE)
    else begin
        $error("AXI4.DSIZE#%0d != axis_rd_inf.DSIZE#%0d",axi4_inf.DSIZE,axis_rd_inf.DSIZE);
        $stop;
    end
end


//--- WRITE
axi_stream_inf #(axi4_inf.DSIZE + axi4_inf.ASIZE)       axis_inf_l0  (axi4_inf.axi_aclk,axi4_inf.axi_aresetn,1'b1);

// axi_inf #(
//     .IDSIZE    (axi4_inf.IDSIZE),
//     .ASIZE     (axi4_inf.ASIZE ),
//     .LSIZE     (axi4_inf.LSIZE ),
//     .DSIZE     (axi4_inf.DSIZE ),
//     .MODE      (axi4_inf.MODE  ),        //BOTH:0,ONLY_WRITE:1,ONLY_READ:2
//     .ADDR_STEP (axi4_inf.ADDR_STEP),            // 1024 : 0
//     .FreqM     (axi4_inf.FreqM   )
// )axi4_inf_vcs_cpt(
// /*  input bit */ .axi_aclk      (axi4_inf.axi_aclk      ),
// /*  input bit */ .axi_aresetn   (axi4_inf.axi_aresetn   )
// );

// vcs_axi4_comptable #(
//     .ORIGIN     ("slaver"),
//     .TO         ("slaver_wr")
// )vcs_axi4_comptable_inst(
// /*  axi_inf   */   .origin      (axi4_inf   ),
// /*  axi_inf   */   .to          (axi4_inf_vcs_cpt)
// );

`include "define_macro.sv"
`VCS_AXI4_CPT(axi4_inf,slaver,slaver_wr,)

axi4_wr_aux_bind_data axi4_wr_aux_bind_data_inst(
/*  axi_inf.slaver_wr      */     .caxi4_inf    (`axi4_inf_vcs_cpt       ),
/*  axi_stream_inf.master  */     .axis_inf     (axis_inf_l0    )
);

assign  sub_axis_inf[0].axis_tdata     = {3'b000,axis_inf_l0.axis_tdata};
assign  sub_axis_inf[0].axis_tvalid    = axis_inf_l0.axis_tvalid;
assign  sub_axis_inf[0].axis_tlast     = axis_inf_l0.axis_tlast;
assign  axis_inf_l0.axis_tready        = sub_axis_inf[0].axis_tready;
assign  sub_axis_inf[0].axis_tkeep     = '1;
assign  sub_axis_inf[0].axis_tuser     = '0;

//--- READ
axi_stream_inf #(axi4_inf.ASIZE + axi4_inf.LSIZE)       axi4_rd_ps_inf  (axi4_inf.axi_aclk,axi4_inf.axi_aresetn,1'b1);
axi_stream_inf #(axi4_inf.ASIZE)                        axis_rd_a_inf  (axi4_inf.axi_aclk,axi4_inf.axi_aresetn,1'b1);
axi_stream_inf #(axi4_inf.ASIZE)                        axis_rd_a_inf_post  (axi4_inf.axi_aclk,axi4_inf.axi_aresetn,1'b1);

assign axi4_rd_ps_inf.axis_tdata    = {axi4_inf.axi_araddr,axi4_inf.axi_arlen};
assign axi4_rd_ps_inf.axis_tvalid   =  axi4_inf.axi_arvalid;
assign axi4_rd_ps_inf.axis_tlast    = 1'b1;
assign axi4_inf.axi_arready         = axi4_rd_ps_inf.axis_tready;
assign axi4_rd_ps_inf.axis_tkeep     = '1;
assign axi4_rd_ps_inf.axis_tuser     = '0;


axis_uncompress_A1 #(
    .ASIZE      (axi4_inf.ASIZE      ),          //ASIZE + LSIZE = AXIS DATA WIDTH
    .LSIZE      (axi4_inf.LSIZE      ),
    .STEP       (axi4_inf.ADDR_STEP/1024  )
)axis_uncompress_A1_inst(
/*  axi_stream_inf.slaver  */ .axis_zip     (axi4_rd_ps_inf ),          //ASIZE+LSIZE
/*  axi_stream_inf.master  */ .axis_unzip   (axis_rd_a_inf  )  //ASIZE
);

axis_connect_pipe axis_connect_pipe_inst(
/*  axi_stream_inf.slaver  */  .axis_in     (axis_rd_a_inf      ),
/*  axi_stream_inf.master  */  .axis_out    (axis_rd_a_inf_post )
);

assign  sub_axis_inf[1].axis_tdata     = {3'b001,axis_rd_a_inf_post.axis_tdata,{axi4_inf.DSIZE{1'b1}}};
assign  sub_axis_inf[1].axis_tvalid    = axis_rd_a_inf_post.axis_tvalid;
assign  sub_axis_inf[1].axis_tlast     = axis_rd_a_inf_post.axis_tlast;
assign  axis_rd_a_inf_post.axis_tready = sub_axis_inf[1].axis_tready;
assign  sub_axis_inf[1].axis_tkeep     = '1;
assign  sub_axis_inf[1].axis_tuser     = '0;

//--- M2S

axi_stream_interconnect_M2S_A1 #(
    .NUM    (2)
)axi_stream_interconnect_M2S_A1_isnt(
/*  axi_stream_inf.slaver */ .s00       (sub_axis_inf   ),//[NUM-1:0],
/*  axi_stream_inf.master */ .m00       (axis_inf       )
);

//--- rd to axi4

assign  axi4_inf.axi_rdata   = axis_rd_inf.axis_tdata[axi4_inf.DSIZE-1:0];
assign  axi4_inf.axi_rvalid  = axis_rd_inf.axis_tvalid;
assign  axi4_inf.axi_rlast   = axis_rd_inf.axis_tlast;
assign  axis_rd_inf.axis_tready     = axi4_inf.axi_rready;

logic   rid_fifo_empty;
logic   rid_fifo_full;
logic   rid_fifo_wr_en;
logic   rid_fifo_rd_en;
logic [axi4_inf.IDSIZE -1:0]  rid_fifo_wdata,rid_fifo_rdata;

common_fifo #(
    .DEPTH      ( 8                 ),
    .DSIZE      ( axi4_inf.IDSIZE   )
)common_fifo_rd_id_inst(
/*  input                   */    .clock        (axi4_inf.axi_aclk          ),
/*  input                   */    .rst_n        (axi4_inf.axi_aresetn       ),
/*  input [DSIZE-1:0]       */    .wdata        (rid_fifo_wdata ),
/*  input                   */    .wr_en        (rid_fifo_wr_en ),
/*  output logic[DSIZE-1:0] */    .rdata        (rid_fifo_rdata ),
/*  input                   */    .rd_en        (rid_fifo_rd_en ),
/*  output logic[CSIZE-1:0] */    .count        (),
/*  output logic            */    .empty        (rid_fifo_empty ),
/*  output logic            */    .full         (rid_fifo_full  )
);

assign  rid_fifo_wr_en  = axi4_inf.axi_arvalid && axi4_inf.axi_arready;
assign  rid_fifo_wdata  = axi4_inf.axi_arid;

assign  axi4_inf.axi_rid    = rid_fifo_rdata;
assign  rid_fifo_rd_en      = axi4_inf.axi_rvalid && axi4_inf.axi_rready && axi4_inf.axi_rlast;


endmodule
