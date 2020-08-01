/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/7/31 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream_inf = "true" *)
module axis_interconnect_S2M_pipe #(
    parameter   NUM   = 8,
    parameter   DEPTH = 4,
    parameter   NSIZE = $clog2(NUM) //(* show = "false" *)
)(
    input                  addr_vld,
    output                 addr_rdy,
    input [NSIZE-1:0]      addr,
    axi_stream_inf.slaver  s00,
    axi_stream_inf.master  m00  [NUM-1:0]
);

axi_stream_inf #(.DSIZE(s00.DSIZE))  post_pkg_fifo(.aclk(s00.aclk),.aresetn(s00.aresetn),.aclken(s00.aclken));
axi_stream_inf #(.DSIZE(s00.DSIZE))  post_valve(.aclk(s00.aclk),.aresetn(s00.aresetn),.aclken(s00.aclken));

logic [NSIZE-1:0]   route;
logic               fifo_full;
// (* dont_touch = "true" *)
logic               fifo_empty;
// (* dont_touch = "true" *)
logic [$clog2(DEPTH):0]     count;

common_fifo #(
    .DEPTH      (DEPTH  ),
    .DSIZE      (NSIZE  )
)common_fifo_inst(
/*  input                    */   .clock    (s00.aclk      ),
/*  input                    */   .rst_n    (s00.aresetn   ),
/*  input [DSIZE-1:0]        */   .wdata    (addr          ),
// /*  input                    */   .wr_en    ((cut_ip_frame_in.axis_tvalid && cut_ip_frame_in.axis_tready && cut_ip_frame_in.axis_tlast)),
/*  input                    */   .wr_en    (addr_vld && addr_rdy ),
/*  output logic[DSIZE-1:0]  */   .rdata    (route      ),
/*  input                    */   .rd_en    ((post_pkg_fifo.axis_tvalid && post_pkg_fifo.axis_tready && post_pkg_fifo.axis_tlast)),
/*  output logic[CSIZE-1:0]  */   .count    (count      ),
/*  output logic             */   .empty    (fifo_empty ),
/*  output logic             */   .full     (fifo_full  )
);

assign addr_rdy = !fifo_full;


axi_stream_packet_fifo #(
    .DEPTH  (DEPTH)   //2-4
)axi_stream_packet_fifo_inst_rx_udp(
/*  axi_stream_inf.slaver */     .axis_in       (s00                    ),
/*  axi_stream_inf.master */     .axis_out      (post_pkg_fifo          )
);

axis_valve axis_valve_inst(
/*  input                  */   .button         (!fifo_empty    ),          //[1] OPEN ; [0] CLOSE
/*  axi_stream_inf.slaver  */   .axis_in        (post_pkg_fifo  ),
/*  axi_stream_inf.master  */   .axis_out       (post_valve     )
);

axi_stream_interconnect_S2M #(
    .NUM        (NUM    )
)axi_stream_interconnect_S2M_inst(
/*   input [NSIZE-1:0]     */ .addr         (route      ),
/*   axi_stream_inf.slaver */ .s00          (post_valve ),
/*   axi_stream_inf.master */ .m00          (m00        )//[NUM-1:0]
);

endmodule
