/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018/11/24 
madified:
***********************************************/
`timescale 1ns/1ps
module independent_stack #(
    parameter   DEPTH   = 1024
)(
    input                           wr_clk,
    input                           wr_rst_n,
    input                           rd_clk,
    input                           rd_rst_n,
    input                           push,
    input                           pop,
    output logic                    wr_side_empty,
    output logic[$clog2(DEPTH)-1:0] wr_side_addr,
    output logic                    rd_side_empty,
    output logic[$clog2(DEPTH)-1:0] rd_side_addr
);

logic   wr_fifo_empty,wr_fifo_full;

independent_clock_fifo #(
    .DEPTH      (4),
    .DSIZE      (1)
)independent_clock_fifo_wr_inst(
/*  input                    */  .wr_clk    (wr_clk     ),
/*  input                    */  .wr_rst_n  (wr_rst_n   ),
/*  input                    */  .rd_clk    (rd_clk     ),
/*  input                    */  .rd_rst_n  (rd_rst_n   ),
/*  input [DSIZE-1:0]        */  .wdata     (1'b0       ),
/*  input                    */  .wr_en     (push       ),
/*  output logic[DSIZE-1:0]  */  .rdata     (),
/*  input                    */  .rd_en     (!wr_fifo_empty ),
/*  output logic             */  .empty     (wr_fifo_empty  ),
/*  output logic             */  .full      (wr_fifo_full   )
);

logic   rd_fifo_empty,rd_fifo_full;

independent_clock_fifo #(
    .DEPTH      (4),
    .DSIZE      (1)
)independent_clock_fifo_rd_inst(
/*  input                    */  .wr_clk    (rd_clk     ),
/*  input                    */  .wr_rst_n  (rd_rst_n   ),
/*  input                    */  .rd_clk    (wr_clk     ),
/*  input                    */  .rd_rst_n  (wr_rst_n   ),
/*  input [DSIZE-1:0]        */  .wdata     (1'b0       ),
/*  input                    */  .wr_en     (pop        ),
/*  output logic[DSIZE-1:0]  */  .rdata     (),
/*  input                    */  .rd_en     (!rd_fifo_empty ),
/*  output logic             */  .empty     (rd_fifo_empty  ),
/*  output logic             */  .full      (rd_fifo_full   )
);

common_stack #(
    .DEPTH      (DEPTH  )
)common_stack_inst_wr(
/*  input                          */   .clock      (wr_clk ),
/*  input                          */   .rst_n      (wr_rst_n && rd_rst_n),
/*  input                          */   .push       (push           ),
/*  input                          */   .pop        (!rd_fifo_empty ),
/*  output logic                   */   .empty      (wr_side_empty  ),
/*  output logic[$clog2(DEPTH)-1:0]*/   .addr       (wr_side_addr   )
);

common_stack #(
    .DEPTH      (DEPTH  )
)common_stack_inst_rd(
/*  input                          */   .clock      (rd_clk ),
/*  input                          */   .rst_n      (wr_rst_n && rd_rst_n),
/*  input                          */   .push       (!wr_fifo_empty ),
/*  input                          */   .pop        (pop            ),
/*  output logic                   */   .empty      (rd_side_empty  ),
/*  output logic[$clog2(DEPTH)-1:0]*/   .addr       (rd_side_addr   )
);

endmodule
