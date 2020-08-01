/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/27 
madified:
***********************************************/
`timescale 1ns/1ps
module common_fifo_2_27_tb;

import BaseFuncPkg::*;

logic   pclk;
logic   prst_n;

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(148.5     	)
)clock_rst_pixel(
	.clock			(pclk   	),
	.rst_x			(prst_n  	)
);

logic [7:0]     wdata;
logic           wr_en;
logic           rd_en;
logic           full;

common_fifo #(
    .DEPTH      (4      ),
    .DSIZE      (8      )
)common_fifo_inst(
/*    input                     */  .clock      (pclk       ),
/*    input                     */  .rst_n      (prst_n     ),
/*    input [DSIZE-1:0]         */  .wdata      (wdata      ),
/*    input                     */  .wr_en      (wr_en      ),
/*    output logic[DSIZE-1:0]   */  .rdata      (       ),
/*    input                     */  .rd_en      (rd_en     ),
/*    output logic[PSIZE-1:0]   */  .count      (       ),
/*    output logic              */  .empty      (       ),
/*    output logic              */  .full       (full       )
);

always@(posedge pclk,negedge prst_n)
    if(~prst_n) wdata   <= '0;
    else begin
        if(wr_en && !full)
                wdata   <= wdata + 1'b1;
        else    wdata   <= wdata;
    end

initial begin
    wr_en   = 0;
    rd_en   = 0;
    wait(prst_n)
    // wr_full_to_rd_empty();
    fork
        random_signal(pclk,100,50,wr_en);
        random_signal(pclk,100,50,rd_en);
    join_none
end

task wr_full_to_rd_empty();
    wr_en   = 1;
    repeat(6)   @(posedge pclk);
    wr_en   = 0;
    rd_en   = 1;
    repeat(6)   @(posedge pclk);
    rd_en   = 0;
endtask:wr_full_to_rd_empty

endmodule
