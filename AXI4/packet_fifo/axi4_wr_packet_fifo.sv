/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/28 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_wr_packet_fifo #(
    parameter PIPE      = "OFF",
    parameter DEPTH     = 4
)(
    axi_inf.slaver_wr axi_in,
    axi_inf.master_wr axi_out
);

//--->> AUXILIARY <<------------------
logic   auxiliary_fifo_empty;
logic   auxiliary_fifo_full;
logic   auxiliary_fifo_wr_en;
logic   auxiliary_fifo_rd_en;
logic [axi_in.ASIZE+axi_in.LSIZE+axi_in.IDSIZE-1:0]    auxiliary_fifo_rd_data;

independent_clock_fifo #(
    .DEPTH      (DEPTH      ),
    .DSIZE      (axi_in.ASIZE+axi_in.LSIZE+axi_in.IDSIZE)
)auxiliary_independent_clock_fifo_inst(
/*    input                     */  .wr_clk         (axi_in.axi_aclk        ),
/*    input                     */  .wr_rst_n       (axi_in.axi_aresetn      ),
/*    input                     */  .rd_clk         (axi_out.axi_aclk       ),
/*    input                     */  .rd_rst_n       (axi_out.axi_aresetn     ),
/*    input [DSIZE-1:0]         */  .wdata          ({axi_in.axi_awid,axi_in.axi_awaddr,axi_in.axi_awlen}),
/*    input                     */  .wr_en          (axi_in.axi_awvalid     ),
/*    output logic[DSIZE-1:0]   */  .rdata          (auxiliary_fifo_rd_data ),
/*    input                     */  .rd_en          ((auxiliary_fifo_rd_en && !auxiliary_fifo_empty)   ),
/*    output logic              */  .empty          (auxiliary_fifo_empty   ),
/*    output logic              */  .full           (auxiliary_fifo_full    )
);

assign axi_in.axi_awready   = !auxiliary_fifo_full;
// assign axi_out.axi_awvalid  = !auxiliary_fifo_empty && axi_out.axi_wvalid;
// assign auxiliary_fifo_rd_en = axi_out.axi_awready && axi_out.axi_awvalid;

logic   stream_fifo_empty;

axi_stream_inf #(.DSIZE(axi_in.ASIZE+axi_in.LSIZE+axi_in.IDSIZE)) id_add_len_in(.aclk(axi_in.axi_aclk),.aresetn(axi_in.axi_aresetn),.aclken(1'b1));

assign id_add_len_in.axis_tdata     = auxiliary_fifo_rd_data;
assign id_add_len_in.axis_tvalid    = !auxiliary_fifo_empty && !stream_fifo_empty;
assign id_add_len_in.axis_tlast     = 1'b1;
assign auxiliary_fifo_rd_en         = id_add_len_in.axis_tready && !stream_fifo_empty;

logic axi_stream_en;

axi4_wr_auxiliary_gen_without_resp axi4_wr_auxiliary_gen_without_resp_inst(
/*    axi_stream_inf.slaver          */     .id_add_len_in      (id_add_len_in  ),      //tlast is not necessary
/*    axi_inf.master_wr_aux_no_resp  */     .axi_wr_aux         (axi_out        ),
/*    output logic                   */     .stream_en          (axi_stream_en  )
);
//---<< AUXILIARY >>------------------
//--->> BRESP<<------------------
logic   resp_fifo_empty;
logic   resp_fifo_full;

independent_clock_fifo #(
    .DEPTH      (DEPTH      ),
    .DSIZE      (2+axi_in.IDSIZE)
)bresp_independent_clock_fifo_inst(
/*    input                     */  .wr_clk         (axi_out.axi_aclk      ),
/*    input                     */  .wr_rst_n       (axi_out.axi_aresetn    ),
/*    input                     */  .rd_clk         (axi_in.axi_aclk       ),
/*    input                     */  .rd_rst_n       (axi_in.axi_aresetn     ),
/*    input [DSIZE-1:0]         */  .wdata          ({axi_out.axi_bresp,axi_out.axi_bid}     ),
/*    input                     */  .wr_en          (axi_out.axi_bvalid    ),
/*    output logic[DSIZE-1:0]   */  .rdata          ({axi_in.axi_bresp,axi_in.axi_bid}      ),
/*    input                     */  .rd_en          (axi_in.axi_bready     ),
/*    output logic              */  .empty          (resp_fifo_empty       ),
/*    output logic              */  .full           (resp_fifo_full        )
);

assign axi_out.axi_bready   = !resp_fifo_full;
assign axi_in.axi_bvalid    = !resp_fifo_empty;
//---<< BRESP >>------------------
//--->> DATA <<-----------------------
axi_stream_inf #(
   .DSIZE(axi_in.DSIZE)
)axis_in(
   .aclk        (axi_in.axi_aclk    ),
   .aresetn     (axi_in.axi_aresetn  ),
   .aclken      (1'b1               )
);

axi_stream_inf #(
   .DSIZE(axi_out.DSIZE)
)axis_valve_slaver(
   .aclk        (axi_out.axi_aclk   ),
   .aresetn     (axi_out.axi_aresetn ),
   .aclken      (1'b1               )
);

axi_stream_inf #(
   .DSIZE(axi_out.DSIZE)
)axis_out(
   .aclk        (axi_out.axi_aclk   ),
   .aresetn     (axi_out.axi_aresetn ),
   .aclken      (1'b1               )
);

data_inf_c #(axi_out.DSIZE+1)  axis_out_master_inf (axi_out.axi_aclk,axi_out.axi_aresetn);
data_inf_c #(axi_out.DSIZE+1)  axis_out_slaver_inf (axi_out.axi_aclk,axi_out.axi_aresetn);

axi_stream_inf #(
   .DSIZE(axi_out.DSIZE)
)pre_axis_out(
   .aclk        (axi_out.axi_aclk   ),
   .aresetn     (axi_out.axi_aresetn ),
   .aclken      (1'b1               )
);

axi_stream_packet_fifo #(
    .DEPTH      (DEPTH)   //2-4
)axi_stream_packet_fifo_inst(
/*    axi_stream_inf.slaver  */    .axis_in     (axis_in    ),
/*    axi_stream_inf.master  */    .axis_out    (axis_valve_slaver   )
);

assign stream_fifo_empty    = !axis_valve_slaver.axis_tvalid;

generate
if(PIPE == "ON")begin
axis_valve_with_pipe axis_valve_inst(
// axis_valve axis_valve_inst(
/*    input                   */   .button      (axi_stream_en          ),          //[1] OPEN ; [0] CLOSE
/*    axi_stream_inf.slaver   */   .axis_in     (axis_valve_slaver      ),
/*    axi_stream_inf.master   */   .axis_out    (pre_axis_out               )
);

assign axis_out_slaver_inf.valid    = pre_axis_out.axis_tvalid;
assign axis_out_slaver_inf.data     = {pre_axis_out.axis_tdata,pre_axis_out.axis_tlast};
assign pre_axis_out.axis_tready     = axis_out_slaver_inf.ready;

data_c_pipe_force_vld data_c_pipe_force_vld_inst(
/*  data_inf_c.slaver  */   .slaver     (axis_out_slaver_inf ),
/*  data_inf_c.master  */   .master     (axis_out_master_inf )
);

assign axis_out.axis_tvalid     = axis_out_master_inf.valid;
assign {axis_out.axis_tdata,axis_out.axis_tlast}    = axis_out_master_inf.data;
assign axis_out_master_inf.ready = axis_out.axis_tready;

end else
axis_valve axis_valve_inst(
/*    input                   */   .button      (axi_stream_en          ),          //[1] OPEN ; [0] CLOSE
/*    axi_stream_inf.slaver   */   .axis_in     (axis_valve_slaver      ),
/*    axi_stream_inf.master   */   .axis_out    (axis_out               )
);
endgenerate

assign  axis_in.axis_tvalid = axi_in.axi_wvalid;
assign  axis_in.axis_tdata  = axi_in.axi_wdata;
assign  axis_in.axis_tlast  = axi_in.axi_wlast;
assign  axis_in.axis_tkeep  = '1;
assign  axis_in.axis_tuser  = '0;
assign  axi_in.axi_wready   = axis_in.axis_tready;

assign  axi_out.axi_wvalid  = axis_out.axis_tvalid;
assign  axi_out.axi_wdata   = axis_out.axis_tdata;
assign  axi_out.axi_wlast   = axis_out.axis_tlast;
assign  axis_out.axis_tready= axi_out.axi_wready;
//---<< DATA >>-----------------------

// axi4_wr_burst_track #(
//     .MAX_LEN    (16     ),
//     .MAX_CYCLE  (1000   )
// )axi4_wr_burst_track_inst(
// /*    axi_inf.mirror_wr */ .axi4_mirror (axi_in )
// );
endmodule
