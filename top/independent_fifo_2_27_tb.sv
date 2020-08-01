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
module independent_fifo_2_27_tb;

import BaseFuncPkg::*;

logic   wr_clk;
logic   rd_clk;
logic   wr_rst_n,rd_rst_n;

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(150     	)
)clock_rst_wr(
	.clock			(wr_clk   	),
	.rst_x			(wr_rst_n  	)
);

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(100     	)
)clock_rst_rd(
	.clock			(rd_clk   	),
	.rst_x			(rd_rst_n  	)
);

logic [7:0]     wdata;
logic           wr_en;
logic           rd_en;
logic           full;

independent_clock_fifo #(
    .DEPTH      (4      ),
    .DSIZE      (8      )
)common_fifo_inst(
/*    input                     */  .wr_clk     (wr_clk     ),
/*    input                     */  .rd_clk     (rd_clk     ),
/*    input                     */  .wr_rst_n   (wr_rst_n   ),
/*    input                     */  .rd_rst_n   (rd_rst_n   ),
/*    input [DSIZE-1:0]         */  .wdata      (wdata      ),
/*    input                     */  .wr_en      (wr_en      ),
/*    output logic[DSIZE-1:0]   */  .rdata      (           ),
/*    input                     */  .rd_en      (rd_en     ),
/*    output logic              */  .empty      (       ),
/*    output logic              */  .full       (full       )
);

always@(posedge wr_clk,negedge wr_rst_n)
    if(~wr_rst_n) wdata   <= '0;
    else begin
        if(wr_en && !full)
                wdata   <= wdata + 1'b1;
        else    wdata   <= wdata;
    end

initial begin
    wr_en   = 0;
    rd_en   = 0;
    wait(rd_rst_n)
    wait(wr_rst_n)
    // wr_full_to_rd_empty();
    fork
        random_signal(wr_clk,100,50,wr_en);
        random_signal(rd_clk,100,50,rd_en);
    join_none
end

task wr_full_to_rd_empty();
    wr_en   = 1;
    repeat(6)   @(posedge wr_clk);
    wr_en   = 0;
    rd_en   = 1;
    repeat(6)   @(posedge rd_clk);
    rd_en   = 0;
endtask:wr_full_to_rd_empty

endmodule
