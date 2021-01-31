/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
created: xxxx.xx.xx
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_to_axi4_or_lite(
    axi_stream_inf.slaver   axis_in,
    axi_stream_inf.master   rd_rel_axis,
    axi_inf.master          axi4m,
    axi_lite_inf.master     lite
);

//==========================================================================
//-------- define ----------------------------------------------------------
logic [32-1:0]  axis_axi4_wr_inf_seq ;
logic axis_axi4_wr_inf_seq_vld;
logic [64-1:0]  axis_axi4_rd_inf_seq ;
logic axis_axi4_rd_inf_seq_vld;
axi_stream_inf #(.DSIZE(axis_in.DSIZE),.USIZE(1)) sub_rx_inf [3:0] (.aclk(axis_in.aclk),.aresetn(axis_in.aresetn),.aclken(1'b1)) ;
axi_stream_inf #(.DSIZE(axis_in.DSIZE),.USIZE(1)) axis_axi4_wr_inf (.aclk(axis_in.aclk),.aresetn(axis_in.aresetn),.aclken(1'b1)) ;
axi_stream_inf #(.DSIZE(axis_in.DSIZE),.USIZE(1)) seq_tail_stream (.aclk(axis_in.aclk),.aresetn(axis_in.aresetn),.aclken(1'b1)) ;
axi_inf #(.DSIZE(axi4m.DSIZE),.IDSIZE(axi4m.IDSIZE),.ASIZE(axi4m.ASIZE),.LSIZE(axi4m.LSIZE),.MODE(axi4m.MODE),.ADDR_STEP(axi4m.ADDR_STEP)) axi4m_vcs_cp_R1131 (.axi_aclk(axi4m.axi_aclk),.axi_aresetn(axi4m.axi_aresetn)) ;
axi_stream_inf #(.DSIZE(axis_in.DSIZE),.USIZE(1)) axis_axi4_rd_inf (.aclk(axis_in.aclk),.aresetn(axis_in.aresetn),.aclken(1'b1)) ;
axi_stream_inf #(.DSIZE(rd_rel_axis.DSIZE),.USIZE(1)) rd_rel_axis_inheritedR1496 (.aclk(rd_rel_axis.aclk),.aresetn(rd_rel_axis.aresetn),.aclken(1'b1)) ;
axi_inf #(.DSIZE(axi4m.DSIZE),.IDSIZE(axi4m.IDSIZE),.ASIZE(axi4m.ASIZE),.LSIZE(axi4m.LSIZE),.MODE(axi4m.MODE),.ADDR_STEP(axi4m.ADDR_STEP)) axi4m_vcs_cp_R1468 (.axi_aclk(axi4m.axi_aclk),.axi_aresetn(axi4m.axi_aresetn)) ;
axi_stream_inf #(.DSIZE(axis_in.DSIZE),.USIZE(1)) axis_lite_wr_inf (.aclk(axis_in.aclk),.aresetn(axis_in.aresetn),.aclken(1'b1)) ;
axi_stream_inf #(.DSIZE(axis_in.DSIZE),.USIZE(1)) axis_lite_rd_inf (.aclk(axis_in.aclk),.aresetn(axis_in.aresetn),.aclken(1'b1)) ;
axi_stream_inf #(.DSIZE(rd_rel_axis.DSIZE),.USIZE(1)) rd_rel_axis_inheritedR1149 (.aclk(rd_rel_axis.aclk),.aresetn(rd_rel_axis.aresetn),.aclken(1'b1)) ;
//==========================================================================
//-------- instance --------------------------------------------------------
axi_stream_interconnect_S2M_auto #(
    .HEAD_DUMMY (4 ),
    .NUM        (4 )
)axi_stream_interconnect_S2M_auto_inst(
/* axi_stream_inf.slaver */.slaver     (axis_in    ),
/* axi_stream_inf.master */.sub_tx_inf (sub_rx_inf )
);
axis_direct axis_direct_inst(
/* axi_stream_inf.slaver */.slaver (sub_rx_inf[0]    ),
/* axi_stream_inf.master */.master (axis_axi4_wr_inf )
);
parse_big_field_table_A1 #(
    .DSIZE      (8           ),
    .FIELD_LEN  (4           ),
    .FIELD_NAME ("Big Filed" ),
    .TRY_PARSE  ("OFF"       )
)parse_big_field_table_A1_inst(
/* input                 */.enable    (/*unused */              ),
/* output                */.value     (axis_axi4_wr_inf_seq     ),
/* output                */.out_valid (axis_axi4_wr_inf_seq_vld ),
/* axi_stream_inf.slaver */.cm_tb_s   (axis_axi4_wr_inf         ),
/* axi_stream_inf.master */.cm_tb_m   (seq_tail_stream          ),
/* axi_stream_inf.mirror */.cm_mirror (axis_axi4_wr_inf         )
);
axis_to_axi4_wr axis_to_axi4_wr_inst(
/* input                 */.addr       (axis_axi4_wr_inf_seq ),
/* input                 */.max_length (2048                 ),
/* axi_stream_inf.slaver */.axis_in    (seq_tail_stream      ),
/* axi_inf.master_wr     */.axi_wr     (axi4m_vcs_cp_R1131   )
);
vcs_axi4_comptable #(
    .ORIGIN ("master_wr" ),
    .TO     ("master"    )
)vcs_axi4_comptable_axi_wr_R808_axi4m_inst(
/* input  */.origin (axi4m_vcs_cp_R1131 ),
/* output */.to     (axi4m              )
);
axis_direct axis_direct_inst1(
/* axi_stream_inf.slaver */.slaver (sub_rx_inf[1]    ),
/* axi_stream_inf.master */.master (axis_axi4_rd_inf )
);
parse_big_field_table_A1 #(
    .DSIZE      (8           ),
    .FIELD_LEN  (8           ),
    .FIELD_NAME ("Big Filed" ),
    .TRY_PARSE  ("OFF"       )
)parse_big_field_table_A1_inst1(
/* input                 */.enable    (/*unused */              ),
/* output                */.value     (axis_axi4_rd_inf_seq     ),
/* output                */.out_valid (axis_axi4_rd_inf_seq_vld ),
/* axi_stream_inf.slaver */.cm_tb_s   (axis_axi4_rd_inf         ),
/* axi_stream_inf.master */.cm_tb_m   (seq_tail_stream          ),
/* axi_stream_inf.mirror */.cm_mirror (axis_axi4_rd_inf         )
);
odata_pool_axi4_A1 odata_pool_axi4_A1_inst(
/* input                 */.source_addr (axis_axi4_rd_inf_seq[63:32] ),
/* input                 */.size        (axis_axi4_rd_inf_seq[31:0]  ),
/* input                 */.valid       (axis_axi4_rd_inf_seq_vld    ),
/* output                */.ready       (/*unused */                 ),
/* axi_stream_inf.master */.out_axis    (rd_rel_axis_inheritedR1496  ),
/* axi_inf.master_rd     */.axi_master  (axi4m_vcs_cp_R1468          )
);
vcs_axi4_comptable #(
    .ORIGIN ("master_rd" ),
    .TO     ("master"    )
)vcs_axi4_comptable_axi_master_R1682_axi4m_inst(
/* input  */.origin (axi4m_vcs_cp_R1468 ),
/* output */.to     (axi4m              )
);
axis_direct axis_direct_inst2(
/* axi_stream_inf.slaver */.slaver (sub_rx_inf[2]    ),
/* axi_stream_inf.master */.master (axis_lite_wr_inf )
);
axis_to_lite_wr #(
    .DUMMY (8 )
)axi4_to_lite_wr_inst(
/* axi_stream_inf.slaver  */.axis_in (axis_lite_wr_inf ),
/* axi_lite_inf.master_wr */.lite    (lite             )
);
axis_direct axis_direct_inst3(
/* axi_stream_inf.slaver */.slaver (sub_rx_inf[3]    ),
/* axi_stream_inf.master */.master (axis_lite_rd_inf )
);
axis_to_lite_rd #(
    .DUMMY (4 )
)axis_to_lite_rd_inst(
/* axi_stream_inf.slaver  */.axis_in     (axis_lite_rd_inf           ),
/* axi_stream_inf.master  */.rd_rel_axis (rd_rel_axis_inheritedR1149 ),
/* axi_lite_inf.master_rd */.lite        (lite                       )
);
//==========================================================================
//-------- expression ------------------------------------------------------

axi_stream_inf #(.DSIZE(rd_rel_axis.DSIZE))  sub_rd_rel_axis[2-1:0](.aclk(rd_rel_axis.aclk),.aresetn(rd_rel_axis.aresetn),.aclken(1'b1));


axis_direct  axis_direct_rd_rel_axis_inst0 (
/*  axi_stream_inf.slaver*/ .slaver (rd_rel_axis_inheritedR1496),
/*  axi_stream_inf.master*/ .master (sub_rd_rel_axis[0])
);

axis_direct  axis_direct_rd_rel_axis_inst1 (
/*  axi_stream_inf.slaver*/ .slaver (rd_rel_axis_inheritedR1149),
/*  axi_stream_inf.master*/ .master (sub_rd_rel_axis[1])
);

axi_stream_interconnect_M2S_A1 #(
//axi_stream_interconnect_M2S_noaddr #(
    .NUM        (2)
 //   .DSIZE      (rd_rel_axis.DSIZE)
)rd_rel_axis_M2S_noaddr_inst(
/*  axi_stream_inf.slaver */ .s00      (sub_rd_rel_axis ), //[NUM-1:0],
/*  axi_stream_inf.master */ .m00      (rd_rel_axis) //
);

endmodule
