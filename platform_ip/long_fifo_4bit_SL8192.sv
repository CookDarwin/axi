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
module long_fifo_4bit_SL8192 #(
    parameter LENGTH = 8192*2
)(
    input               clk,
    input               rst,
    input [3:0]         din   ,
    input               wr_en ,
    input               rd_en ,
    output [3:0]        dout  ,
    output              full  ,
    output              empty
);


initial begin
    if(LENGTH < 8192)begin
        $error("%s,%d,long_fifo_4bit_SL8192 Long FIFO <LENGHT> larger than 8192",`__FILE__,`__LINE__);
        $finish;
    end
end


localparam K36NUM = LENGTH/8192;

logic [2:0]     wcnt;
logic [2:0]     rcnt;

always@(posedge clk,posedge rst)
    if(rst) wcnt    <= '0;
    else  begin
        if(wcnt != 3'b111)
                wcnt    <= wcnt + 1'b1;
        else    wcnt    <= wcnt;
    end

always@(posedge clk,posedge rst)
    if(rst) rcnt    <= '0;
    else  begin
        if(rcnt != 3'b111)
                rcnt    <= rcnt + 1'b1;
        else    rcnt    <= rcnt;
    end

logic   en_wr_en,en_rd_en;

always@(posedge clk,posedge rst)
    if(rst) en_wr_en    <= 1'b0;
    else begin
        if(wcnt == 3'b111)
                en_wr_en    <= 1'b1;
        else    en_wr_en    <= en_wr_en;
    end

always@(posedge clk,posedge rst)
    if(rst) en_rd_en    <= 1'b0;
    else begin
        if(rcnt == 3'b111)
                en_rd_en    <= 1'b1;
        else    en_rd_en    <= en_rd_en;
    end

logic  RST;

assign RST = rst || rst;

logic [K36NUM-1:0]  fifo_wr_en;
logic [K36NUM-1:0]  fifo_rd_en;
logic [3:0]  fifo_wr_data [K36NUM-1:0];
logic [3:0]  fifo_rd_data [K36NUM-1:0];

logic [K36NUM-1:0]  fifo_full;
logic [K36NUM-1:0]  fifo_empty;


genvar KK;
generate
for(KK=0;KK<K36NUM;KK++)begin
FIFO_DUALCLOCK_MACRO  #(
    .ALMOST_EMPTY_OFFSET      (9'h010), // Sets the almost empty threshold
    .ALMOST_FULL_OFFSET       (9'h010),  // Sets almost full threshold
    .DATA_WIDTH               (4     ),   // Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
    .DEVICE                   ("7SERIES"),  // Target device: "7SERIES"
    .FIFO_SIZE                ("36Kb"), // Target BRAM: "18Kb" or "36Kb"
    .FIRST_WORD_FALL_THROUGH  ("TRUE") // Sets the FIFO FWFT to "TRUE" or "FALSE"
) FIFO_DUALCLOCK_MACRO_inst (
    .ALMOSTEMPTY    (),     // 1-bit output almost empty
    .ALMOSTFULL     (),     // 1-bit output almost full
    .DO             (fifo_rd_data[KK]   ),                   // Output data, width defined by DATA_WIDTH parameter
    .EMPTY          (fifo_empty[KK]  ),    // 1-bit output empty
    .FULL           (fifo_full[KK]   ),     // 1-bit output full
    .RDCOUNT        (),         // Output read count, width determined by FIFO depth
    .RDERR          (),         // 1-bit output read error
    .WRCOUNT        (),         // Output write count, width determined by FIFO depth
    .WRERR          (),         // 1-bit output write error
    .DI             (fifo_wr_data[KK]    ),                 // Input data, width defined by DATA_WIDTH parameter
    .RDCLK          (clk   ),                                             // 1-bit input read clock
    .RDEN           (fifo_rd_en[KK] && en_rd_en    ),                 // 1-bit input read enable
    .RST            (RST),                                                          // 1-bit input reset
    .WRCLK          (clk   ),                                             // 1-bit input write clock
    .WREN           (fifo_wr_en[KK] && en_wr_en    )                  // 1-bit input write enable
);
end
endgenerate

assign fifo_wr_en[0]    = wr_en;
assign fifo_wr_data[0]  = din;

generate
for(KK=1;KK<K36NUM;KK++)begin
    assign fifo_wr_en[KK]    = !fifo_empty[KK-1] && !fifo_full[KK];
    assign fifo_wr_data[KK]  = fifo_rd_data[KK-1];
    assign fifo_rd_en[KK-1]  = fifo_wr_en[KK];
end
endgenerate

assign fifo_rd_en[K36NUM-1] = rd_en;
assign full    = fifo_full[0];
assign empty   = fifo_empty[K36NUM-1];
assign dout    = fifo_rd_data[K36NUM-1];


endmodule
