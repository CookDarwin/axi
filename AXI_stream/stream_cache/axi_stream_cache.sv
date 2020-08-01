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
//`include "E:/work/AXI/macro/system_macro.sv"
(* axi_stream = "true" *)
module axi_stream_cache (
    (* up_stream = "true" *)
    axi_stream_inf.slaver      axis_in,
    (* down_stream = "true" *)
    axi_stream_inf.master      axis_out
);

logic   empty;
logic   full;

independent_clock_fifo #(
    .DEPTH      (4  ),
    .DSIZE      (axis_in.DSIZE+1+axis_in.KSIZE  )
)independent_clock_fifo_inst(
/*  input                    */   .wr_clk       (axis_in.aclk       ),
/*  input                    */   .wr_rst_n     (axis_in.aresetn    ),
/*  input                    */   .rd_clk       (axis_out.aclk      ),
/*  input                    */   .rd_rst_n     (axis_out.aresetn   ),
/*  input [DSIZE-1:0]        */   .wdata        ({axis_in.axis_tlast,axis_in.axis_tdata,axis_in.axis_tkeep}    ),
/*  input                    */   .wr_en        ((axis_in.axis_tvalid && !full)             ),
/*  output logic[DSIZE-1:0]  */   .rdata        ({axis_out.axis_tlast,axis_out.axis_tdata,axis_out.axis_tkeep}  ),
/*  input                    */   .rd_en        ((axis_out.axis_tready && !empty)           ),
/*  output logic             */   .empty        (empty              ),
/*  output logic             */   .full         (full               )
);

assign  axis_in.axis_tready     = !full;
assign  axis_out.axis_tvalid    = !empty;

assign axis_out.axis_tuser      = '0;
// assign axis_out.axis_tkeep      = '1;

endmodule
