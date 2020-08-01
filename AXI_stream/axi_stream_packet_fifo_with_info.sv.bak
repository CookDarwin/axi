/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/4/27 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axi_stream_packet_fifo_with_info #(
    parameter DEPTH   = 2,   //2-4
    parameter ESIZE   = 8
)(
    input [ESIZE-1:0]               info_in,
    output[ESIZE-1:0]               info_out,
    (* up_stream = "true" *)
    axi_stream_inf.slaver      axis_in,
    (* down_stream = "true" *)
    axi_stream_inf.master      axis_out
);


axi_stream_packet_fifo #(
    .DEPTH      (DEPTH)
)axi_stream_packet_fifo_inst(
/*  axi_stream_inf.slaver  */  .axis_in     (axis_in     ),
/*  axi_stream_inf.master  */  .axis_out    (axis_out    )
);

independent_clock_fifo #(
    .DEPTH      (DEPTH  ),
    .DSIZE      (ESIZE  )
)independent_clock_fifo_inst(
/*  input                    */  .wr_clk        (axis_in.aclk       ),
/*  input                    */  .wr_rst_n      (axis_in.aresetn    ),
/*  input                    */  .rd_clk        (axis_out.aclk      ),
/*  input                    */  .rd_rst_n      (axis_out.aresetn   ),
/*  input [DSIZE-1:0]        */  .wdata         (info_in            ),
/*  input                    */  .wr_en         ((axis_in.axis_tvalid && axis_in.axis_tready && axis_in.axis_tlast)),
/*  output logic[DSIZE-1:0]  */  .rdata         (info_out           ),
/*  input                    */  .rd_en         ((axis_out.axis_tvalid && axis_out.axis_tready && axis_out.axis_tlast)),
/*  output logic             */  .empty         (),
/*  output logic             */  .full          ()
);

endmodule
