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
module axi4_rd_packet_fifo #(
    parameter   PIPE    = "OFF",
    parameter   DEPTH   = 4
)(
    axi_inf.slaver_rd slaver,
    axi_inf.master_rd master
);

logic   stream_fifo_full;
//--->> AUXILIARY <<------------------
logic   auxiliary_fifo_empty;
logic   auxiliary_fifo_full;
logic   auxiliary_fifo_rd_en;
logic   auxiliary_fifo_wr_en;

independent_clock_fifo #(           //fifo can stack DEPTH+1 "DATA"
    .DEPTH      (DEPTH-1      ),
    .DSIZE      (slaver.ASIZE+slaver.LSIZE+slaver.IDSIZE)
)auxiliary_independent_clock_fifo_inst(
/*    input                     */  .wr_clk         (slaver.axi_aclk        ),
/*    input                     */  .wr_rst_n       (slaver.axi_aresetn      ),
/*    input                     */  .rd_clk         (master.axi_aclk       ),
/*    input                     */  .rd_rst_n       (master.axi_aresetn     ),
/*    input [DSIZE-1:0]         */  .wdata          ({slaver.axi_araddr,slaver.axi_arlen,slaver.axi_arid}),
/*    input                     */  .wr_en          (auxiliary_fifo_wr_en   ),
/*    output logic[DSIZE-1:0]   */  .rdata          ({master.axi_araddr,master.axi_arlen,master.axi_arid}),
/*    input                     */  .rd_en          (auxiliary_fifo_rd_en   ),
/*    output logic              */  .empty          (auxiliary_fifo_empty   ),
/*    output logic              */  .full           (auxiliary_fifo_full    )
);

// assign master.axi_arvalid  = !auxiliary_fifo_empty && !stream_fifo_full;
// assign auxiliary_fifo_rd_en = master.axi_arready && !stream_fifo_full;

// assign master.axi_arvalid  = !auxiliary_fifo_empty;
// assign auxiliary_fifo_rd_en = master.axi_arready ;
//--->> SLAVER SIDE <<-------------------------------------
logic   sctrl_fifo_empty;
logic   sctrl_fifo_full;
logic   sctrl_fifo_rd_en;
logic   sctrl_fifo_wr_en;

(* dont_touch="true" *)
logic [slaver.IDSIZE-1:0]   sctrl_fifo_id;

independent_clock_fifo #(
    .DEPTH      (DEPTH-1      ),
    .DSIZE      (slaver.IDSIZE)
)slaver_last_independent_clock_fifo_inst(
/*    input                     */  .wr_clk         (slaver.axi_aclk        ),
/*    input                     */  .wr_rst_n       (slaver.axi_aresetn && master.axi_aresetn     ),
/*    input                     */  .rd_clk         (slaver.axi_aclk        ),
/*    input                     */  .rd_rst_n       (slaver.axi_aresetn && master.axi_aresetn     ),
/*    input [DSIZE-1:0]         */  .wdata          (slaver.axi_arid        ),
/*    input                     */  .wr_en          (sctrl_fifo_wr_en       ),
/*    output logic[DSIZE-1:0]   */  .rdata          (sctrl_fifo_id      ),
/*    input                     */  .rd_en          (sctrl_fifo_rd_en   ),
/*    output logic              */  .empty          (sctrl_fifo_empty   ),
/*    output logic              */  .full           (sctrl_fifo_full    )
);

assign sctrl_fifo_wr_en = slaver.axi_arvalid && slaver.axi_arready;
assign sctrl_fifo_rd_en = (slaver.axi_rvalid && slaver.axi_rready && slaver.axi_rlast);
//---<< SLAVER SIDE >>-------------------------------------
//--->> MASTER SIDE <<---------------------------------
logic   mctrl_fifo_empty;
logic   mctrl_fifo_full;
logic   mctrl_fifo_rd_en;
logic   mctrl_fifo_wr_en;

(* dont_touch="true" *)
logic [master.IDSIZE-1:0]   mctrl_fifo_id;

independent_clock_fifo #(
    .DEPTH      (DEPTH-1      ),
    .DSIZE      (master.IDSIZE)
    // .DSIZE      (1)
)master_last_independent_clock_fifo_inst(
/*    input                     */  .wr_clk         (master.axi_aclk        ),
/*    input                     */  .wr_rst_n       (master.axi_aresetn && slaver.axi_aresetn     ),
/*    input                     */  .rd_clk         (master.axi_aclk        ),
/*    input                     */  .rd_rst_n       (master.axi_aresetn && slaver.axi_aresetn     ),
/*    input [DSIZE-1:0]         */  .wdata          (master.axi_arid        ),
/*    input                     */  .wr_en          (mctrl_fifo_wr_en       ),
/*    output logic[DSIZE-1:0]   */  .rdata          (mctrl_fifo_id      ),
/*    input                     */  .rd_en          (mctrl_fifo_rd_en   ),
/*    output logic              */  .empty          (mctrl_fifo_empty   ),
/*    output logic              */  .full           (mctrl_fifo_full    )
);

assign mctrl_fifo_wr_en =  master.axi_arvalid && master.axi_arready;
assign mctrl_fifo_rd_en = (master.axi_rvalid  && master.axi_rready && master.axi_rlast);

//---<< MASTER SIDE >>---------------------------------
//--->> VLD RDY PAIR slaver
assign slaver.axi_arready   = !sctrl_fifo_full;
assign auxiliary_fifo_wr_en = slaver.axi_arvalid && !sctrl_fifo_full;
//=====================
//--->> VLD RDY PAIR master
assign auxiliary_fifo_rd_en =  master.axi_arready && !mctrl_fifo_full;
assign master.axi_arvalid   = !auxiliary_fifo_empty && !mctrl_fifo_full;
//=====================
//---<< AUXILIARY >>------------------
//--->> DEPTH CTRL <<-----------------
//---<< DEPTH CTRL >>-----------------
//--->> DATA <<-----------------------
axi_stream_inf #(
   .DSIZE(slaver.DSIZE)
)axis_out(
   .aclk        (slaver.axi_aclk    ),
   .aresetn     (slaver.axi_aresetn  ),
   .aclken      (1'b1               )
);

axi_stream_inf #(
   .DSIZE(slaver.DSIZE)
)post_axis_in(
   .aclk        (master.axi_aclk   ),
   .aresetn     (master.axi_aresetn ),
   .aclken      (1'b1               )
);

axi_stream_inf #(
   .DSIZE(master.DSIZE)
)axis_in(
   .aclk        (master.axi_aclk   ),
   .aresetn     (master.axi_aresetn ),
   .aclken      (1'b1               )
);

logic [15:0]    empty_size;


`ifdef VCS_ENV
localparam CSIZE = $bits(slaver.axi_rid);
`else 
localparam CSIZE = slaver.IDSIZE;
`endif

axi_stream_packet_fifo_B1E #(
    .DEPTH      (DEPTH),   //2-4
    .CSIZE      (CSIZE  ),
    .DSIZE      (slaver.DSIZE   )
)axi_stream_packet_fifo_inst(
// /*    input               */  .slaver_aclk          (axis_in.aclk          ),
// /*    input               */  .slaver_aresetn       (axis_in.aresetn       ),
// /*    input               */  .master_aclk          (axis_out.aclk         ),
// /*    input               */  .master_aresetn       (axis_out.aresetn      ),
/*    input [CSIZE-1:0]   */  .in_cdata             (master.axi_rid        ),
/*    output[CSIZE-1:0]   */  .out_cdata            (slaver.axi_rid        ),
/*    output logic[15:0]  */  .empty_size           (empty_size            ),
// /*    input[DSIZE-1:0]    */  .slaver_axis_tdata    (axis_in.axis_tdata    ),
// /*    input               */  .slaver_axis_tvalid   (axis_in.axis_tvalid   ),
// /*    output              */  .slaver_axis_tready   (axis_in.axis_tready   ),
// /*    input               */  .slaver_axis_tuser    (axis_in.axis_tuser    ),
// /*    input               */  .slaver_axis_tlast    (axis_in.axis_tlast    ),
// /*    input[KSIZE-1:0]    */  .slaver_axis_tkeep    (axis_in.axis_tkeep    ),
/*    axi_stream_inf.slaver  */  .slaver               (post_axis_in),
// /*    input[SCSIZE-1:0]   */  .slaver_axis_tcnt     (axis_in.axis_tcnt     ),
// /*    output[DSIZE-1:0]   */  .master_axis_tdata    (axis_out.axis_tdata   ),
// /*    output              */  .master_axis_tvalid   (axis_out.axis_tvalid  ),
// /*    input               */  .master_axis_tready   (axis_out.axis_tready  ),
// /*    output              */  .master_axis_tuser    (axis_out.axis_tuser   ),
// /*    output              */  .master_axis_tlast    (axis_out.axis_tlast   ),
// /*    output[KSIZE-1:0]   */  .master_axis_tkeep    (axis_out.axis_tkeep   )
// // /*    output[SCSIZE-1:0]  */  .master_axis_tcnt     (axis_out.axis_tcnt    )
/*    axi_stream_inf.slaver  */  .master               (axis_out            )
);

generate
if(PIPE == "ON")
axis_connect_pipe in_axis_connect_pipe_inst(
/* axi_stream_inf.slaver   */   .axis_in        (axis_in            ),
/* axi_stream_inf.master   */   .axis_out       (post_axis_in       )
);
else
axis_direct axis_direct_inst(
/*  axi_stream_inf.slaver */  .slaver   (axis_in    ),
/*  axi_stream_inf.master */  .master   (post_axis_in   )
);
endgenerate

//--->> AXIS FIFO SPACE CHK <<--------------
//---<< AXIS FIFO SPACE CHK >>--------------

assign  axis_in.axis_tvalid = master.axi_rvalid;
assign  axis_in.axis_tdata  = master.axi_rdata;
assign  axis_in.axis_tlast  = master.axi_rlast;
assign  axis_in.axis_tkeep  = '1;
assign  axis_in.axis_tuser  = '0;
assign  master.axi_rready   = axis_in.axis_tready;

assign  slaver.axi_rvalid  = axis_out.axis_tvalid;
assign  slaver.axi_rdata   = axis_out.axis_tdata;
assign  slaver.axi_rlast   = axis_out.axis_tlast;
assign  axis_out.axis_tready= slaver.axi_rready;

assign  stream_fifo_full    = !axis_in.axis_tready;
//---<< DATA >>-----------------------
//--->> ID TRACK <<-------------------
// (* dont_touch="true" *)
// logic   id_err;
// (* dont_touch="true" *)
// logic [slaver.IDSIZE-1:0]   slaver_post_id;
// always@(posedge slaver.axi_aclk,negedge slaver.axi_aresetn)begin:ID_ERR_BLOCK
//     if(~slaver.axi_aresetn) begin
//         id_err  <= 1'b0;
//         slaver_post_id <= '0;
//     end else begin
//         slaver_post_id <= (slaver.axi_rvalid && slaver.axi_rready)? slaver.axi_rid : slaver_post_id;
//         if(slaver.axi_rvalid && slaver.axi_rready)begin
//             if(slaver_post_id=='1)begin
//                 if(slaver.axi_rid != '0 && (slaver_post_id != slaver.axi_rid))
//                         id_err  <= 1'b1;
//                 else    id_err  <= id_err;
//             end else begin
//                 id_err  <= (slaver_post_id+1 != slaver.axi_rid) && (slaver_post_id != slaver.axi_rid);
//             end
//         end else slaver_post_id <= slaver_post_id;
//     end
// end
//
// initial begin
//     wait(id_err);
//     #(100us);
//     $stop;
// end
//
// (* dont_touch="true" *)
// logic   master_id_err;
// (* dont_touch="true" *)
// logic [slaver.IDSIZE-1:0]   master_post_id;
// always@(posedge master.axi_aclk,negedge master.axi_aresetn)begin:MASTER_ID_ERR_BLOCK
//     if(~master.axi_aresetn) begin
//         master_id_err  <= 1'b0;
//         master_id_err <= '0;
//     end else begin
//         master_post_id <= (master.axi_rvalid && master.axi_rready)? master.axi_rid : master_post_id;
//         if(master.axi_rvalid && master.axi_rready)begin
//             if(master_post_id=='1)begin
//                 if(master.axi_rid != '0 && (master_post_id != master.axi_rid))
//                         master_id_err  <= 1'b1;
//                 else    master_id_err  <= master_id_err;
//             end else begin
//                 master_id_err  <= (master_post_id+1 != master.axi_rid) && (master_post_id != master.axi_rid);
//             end
//         end else master_id_err  <= master_id_err;
//     end
// end
//
// initial begin
//     wait(master_id_err);
//     #(100us);
//     $stop;
// end
//---<< ID TRACK >>-------------------
`include "define_macro.sv"
`VCS_AXI4_CPT(master,master,mirror_rd,)
import SystemPkg::*;
generate
if(SIM=="ON" || SIM=="TRUE")begin
axi4_rd_burst_track #(
    .MAX_LEN    (16     ),
    .MAX_CYCLE  (1000   )
)axi4_rd_burst_track_inst(
/*    axi_inf.mirror_rd */ .axi4_mirror (`master_vcs_cpt )
);
end
endgenerate

endmodule
