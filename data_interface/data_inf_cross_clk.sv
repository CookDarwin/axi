
/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/16 
madified:
***********************************************/
`timescale 1ns/1ps
module data_inf_cross_clk (
    data_inf_c.slaver         slaver,
    data_inf_c.master         master
);

logic   fifo_empty   ;
logic   fifo_full    ;

independent_clock_fifo #(           //fifo can stack DEPTH+1 "DATA"
    .DEPTH      (4     ),
    .DSIZE      (slaver.DSIZE)
)independent_clock_fifo_inst(
/*    input                     */  .wr_clk         (slaver.clock        ),
/*    input                     */  .wr_rst_n       (slaver.rst_n        ),
/*    input                     */  .rd_clk         (master.clock        ),
/*    input                     */  .rd_rst_n       (master.rst_n        ),
/*    input [DSIZE-1:0]         */  .wdata          (slaver.data         ),
/*    input                     */  .wr_en          (slaver.valid        ),
/*    output logic[DSIZE-1:0]   */  .rdata          (master.data         ),
/*    input                     */  .rd_en          (master.ready        ),
/*    output logic              */  .empty          (fifo_empty          ),
/*    output logic              */  .full           (fifo_full           )
);

assign slaver.ready = !fifo_full;
assign master.valid = !fifo_empty;

endmodule
