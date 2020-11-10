/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2019/1/8 上午11:42:26
madified:
***********************************************/
`timescale 1ns/1ps
module axis_intc_S2M_with_addr_inf #(
    parameter   NUM             = 8,
    parameter   USE_PIPE        = "OFF"
)(
    data_inf_c.slaver       addr_inf,       //inf.DSIZE = $clog2(NUM)
    axi_stream_inf.slaver   s00,
    axi_stream_inf.master   m00[NUM-1:0]
);

logic [$clog2(NUM)-1:0]     wdata;
logic                       wr_en;
logic [$clog2(NUM)-1:0]     rdata;
logic                       rd_en;
logic                       empty;
logic                       full;

assign  wr_en           = addr_inf.valid && addr_inf.ready;
assign  addr_inf.ready  = !full;
assign  wdata           = addr_inf.data;

axi_stream_inf #(s00.DSIZE,s00.FreqM)   post_s00    (s00.aclk,s00.aresetn,s00.aclken);

independent_clock_fifo #(
    .DEPTH      (4  ),
    .DSIZE      ($clog2(NUM)  )
)independent_clock_fifo_inst(
/*  input                    */   .wr_clk       (addr_inf.clock     ),
/*  input                    */   .wr_rst_n     (addr_inf.rst_n     ),
/*  input                    */   .rd_clk       (s00.aclk           ),
/*  input                    */   .rd_rst_n     (s00.aresetn        ),
/*  input [DSIZE-1:0]        */   .wdata        (wdata              ),
/*  input                    */   .wr_en        (wr_en              ),
/*  output logic[DSIZE-1:0]  */   .rdata        (rdata              ),
/*  input                    */   .rd_en        (rd_en              ),
/*  output logic             */   .empty        (empty              ),
/*  output logic             */   .full         (full               )
);

generate
if(USE_PIPE == "ON" || USE_PIPE == "TRUE")begin
axis_valve_with_pipe #(
    .MODE       ("OUT")
)axis_valve_with_pipe_inst(
/*  input                  */  .button      (!empty         ),          //[1] OPEN ; [0] CLOSE
/*  axi_stream_inf.slaver  */  .axis_in     (s00            ),
/*  axi_stream_inf.master  */  .axis_out    (post_s00       )
);
end else begin
// axis_direct axis_direct_inst(
// /*  axi_stream_inf.slaver  */ .slaver       (s00            ),
// /*  axi_stream_inf.master  */ .master       (post_s00       )
// );
axis_valve axis_valve_inst(
/*  input                  */  .button          (!empty         ),          //[1] OPEN ; [0] CLOSE
/*  axi_stream_inf.slaver  */  .axis_in         (s00            ),
/*  axi_stream_inf.master  */  .axis_out        (post_s00       )
);
end
endgenerate

assign  rd_en   = post_s00.axis_tvalid && post_s00.axis_tready && post_s00.axis_tlast;



axi_stream_interconnect_S2M #(
    .NUM        (NUM    )
)axi_stream_interconnect_S2M_inst(
/*   input [NSIZE-1:0]     */ .addr         (rdata      ),
/*   axi_stream_inf.slaver */ .s00          (post_s00   ),
/*   axi_stream_inf.master */ .m00          (m00        )//[NUM-1:0]
);


endmodule
