/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/5/19 
madified:
***********************************************/
`timescale 1ns/1ps
module long_fifo_4bit_8192 #(
    parameter LENGTH = 8192
)(
    input               wr_clk,
    input               wr_rst,
    input               rd_clk,
    input               rd_rst,
    input [3:0]         din   ,
    input               wr_en ,
    input               rd_en ,
    output [3:0]        dout  ,
    output              full  ,
    output              empty
);

import SystemPkg::*;

initial begin
    if(LENGTH > 8192)begin
        $error("%s,%d,Long_8192 FIFO <LENGHT> smaller than 8192",`__FILE__,`__LINE__);
        $finish;
    end
end

localparam K18_EX = (LENGTH%8192 != 0) && (LENGTH%8192 < 8192/2);
localparam K36_EX = (LENGTH%8192 != 0) && (LENGTH%8192 > 8192/2);

logic [2:0]     wcnt;
logic [2:0]     rcnt;

always@(posedge wr_clk,posedge wr_rst)
    if(wr_rst) wcnt    <= '0;
    else  begin
        if(wcnt != 3'b111)
                wcnt    <= wcnt + 1'b1;
        else    wcnt    <= wcnt;
    end

always@(posedge rd_clk,posedge rd_rst)
    if(rd_rst) rcnt    <= '0;
    else  begin
        if(rcnt != 3'b111)
                rcnt    <= rcnt + 1'b1;
        else    rcnt    <= rcnt;
    end

logic   en_wr_en,en_rd_en;

// generate 
//     if(SIM == "FALSE" || SIM == "OFF") begin 
        always@(posedge wr_clk,posedge wr_rst)
            if(wr_rst) en_wr_en    <= 1'b0;
            else begin
                if(wcnt == 3'b111)
                        en_wr_en    <= 1'b1;
                else    en_wr_en    <= en_wr_en;
            end

        always@(posedge rd_clk,posedge rd_rst)
            if(rd_rst) en_rd_en    <= 1'b0;
            else begin
                if(rcnt == 3'b111)
                        en_rd_en    <= 1'b1;
                else    en_rd_en    <= en_rd_en;
            end
//     end else begin 
//         assign en_wr_en = 1'b1;
//         assign en_rd_en = 1'b1;
//     end 
// endgenerate

logic  RST;

assign RST = wr_rst || rd_rst;


localparam FIFO_SIZE = K36_EX? "36Kb" : "18Kb";

logic   ex_fifo_wr_en;
logic   ex_fifo_rd_en;
logic [3:0]  ex_fifo_wr_data;
logic [3:0]  ex_fifo_rd_data;

logic   ex_fifo_full;
logic   ex_fifo_empty;

FIFO_DUALCLOCK_MACRO  #(
    .ALMOST_EMPTY_OFFSET      (9'h010), // Sets the almost empty threshold
    .ALMOST_FULL_OFFSET       (9'h010),  // Sets almost full threshold
    .DATA_WIDTH               (4     ),   // Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
    .DEVICE                   ("7SERIES"),  // Target device: "7SERIES"
    .FIFO_SIZE                (FIFO_SIZE), // Target BRAM: "18Kb" or "36Kb"
    .FIRST_WORD_FALL_THROUGH  ("TRUE") // Sets the FIFO FWFT to "TRUE" or "FALSE"
) FIFO_DUALCLOCK_MACRO_inst (
    .ALMOSTEMPTY    (),     // 1-bit output almost empty
    .ALMOSTFULL     (),     // 1-bit output almost full
    .DO             (ex_fifo_rd_data   ),                   // Output data, width defined by DATA_WIDTH parameter
    .EMPTY          (ex_fifo_empty  ),    // 1-bit output empty
    .FULL           (ex_fifo_full   ),     // 1-bit output full
    .RDCOUNT        (),         // Output read count, width determined by FIFO depth
    .RDERR          (),         // 1-bit output read error
    .WRCOUNT        (),         // Output write count, width determined by FIFO depth
    .WRERR          (),         // 1-bit output write error
    .DI             (ex_fifo_wr_data    ),                 // Input data, width defined by DATA_WIDTH parameter
    .RDCLK          (rd_clk   ),                                             // 1-bit input read clock
    .RDEN           (ex_fifo_rd_en && en_rd_en && !ex_fifo_empty   ),                 // 1-bit input read enable
    .RST            (RST),                                                          // 1-bit input reset
    .WRCLK          (wr_clk   ),                                             // 1-bit input write clock
    .WREN           (ex_fifo_wr_en && en_wr_en && !ex_fifo_full   )                  // 1-bit input write enable
);

assign ex_fifo_wr_data  = din;
assign ex_fifo_wr_en    = wr_en;

assign dout             = ex_fifo_rd_data;
assign ex_fifo_rd_en    = rd_en;

assign full     = ex_fifo_full;
assign empty    = ex_fifo_empty;


endmodule
