/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018/1/11 
madified:
***********************************************/
`timescale 1ns/1ps
module fifo_36kb_long #(
    parameter DSIZE = 32,
    parameter DEPTH = 8000
)(
    input               wr_clk,
    input               wr_rst,
    input               rd_clk,
    input               rd_rst,
    input [DSIZE-1:0]   din   ,
    input               wr_en ,
    input               rd_en ,
    output [DSIZE-1:0]  dout  ,
    output              full  ,
    output              empty
);

logic   RST;
logic   en_rd_en;
logic   en_wr_en;

fifo_wr_rd_mark fifo_wr_rd_mark_inst(
/*  input        */   .rd_clk       (rd_clk ),
/*  input        */   .wr_clk       (wr_clk ),
/*  input        */   .rd_rst       (rd_rst ),
/*  input        */   .wr_rst       (wr_rst ),
/*  output logic */   .en_rd_en     (en_rd_en   ),
/*  output logic */   .en_wr_en     (en_wr_en   ),
/*  output logic */   .fifo_rst     (RST        )
);

// initial begin
//     assert(DSIZE>=19 && DSIZE <=36)
//     else begin
//         $error("FIFO'DSIZE[%d] MUST >=19 && <=36",DSIZE);
//         $stop;
//     end
// end

localparam DIV =    ((DSIZE>=37) && (DSIZE<=72)) ? 512 :
                    ((DSIZE>=19) && (DSIZE<=36)) ? 1024 :
                    ((DSIZE>=10) && (DSIZE<=18)) ? 2048 :
                    ((DSIZE>=5 ) && (DSIZE<=9 )) ? 4096 :
                    ((DSIZE>=1 ) && (DSIZE<=4 )) ? 8192 : 8192;

localparam KNUM = DEPTH/DIV;

// FIFO_DUALCLOCK_MACRO: Dual Clock First-In, First-Out (FIFO) RAM Buffer
//                       Artix-7
// Xilinx HDL Language Template, version 2016.3

/////////////////////////////////////////////////////////////////
// DATA_WIDTH | FIFO_SIZE | FIFO Depth | RDCOUNT/WRCOUNT Width //
// ===========|===========|============|=======================//
//   37-72    |  "36Kb"   |     512    |         9-bit         //
//   19-36    |  "36Kb"   |    1024    |        10-bit         //
//   19-36    |  "18Kb"   |     512    |         9-bit         //
//   10-18    |  "36Kb"   |    2048    |        11-bit         //
//   10-18    |  "18Kb"   |    1024    |        10-bit         //
//    5-9     |  "36Kb"   |    4096    |        12-bit         //
//    5-9     |  "18Kb"   |    2048    |        11-bit         //
//    1-4     |  "36Kb"   |    8192    |        13-bit         //
//    1-4     |  "18Kb"   |    4096    |        12-bit         //
/////////////////////////////////////////////////////////////////

// logic  EMPTY,FULL;

// assign RST = wr_rst || rd_rst;

logic[DSIZE-1:0]        mfifo_dout   [KNUM-1:0];
logic[DSIZE-1:0]        mfifo_din    [KNUM-1:0];
logic                   mfifo_empty  [KNUM-1:0];
logic                   mfifo_full   [KNUM-1:0];

logic                   mfifo_rd_en  [KNUM-1:0];
logic                   mfifo_wr_en  [KNUM-1:0];

logic                   mfifo_rd_clk  [KNUM-1:0];
logic                   mfifo_wr_clk  [KNUM-1:0];

genvar KK;
generate
for(KK=0;KK<KNUM;KK++)begin
FIFO_DUALCLOCK_MACRO  #(
    .ALMOST_EMPTY_OFFSET      (9'h010), // Sets the almost empty threshold
    .ALMOST_FULL_OFFSET       (9'h010),  // Sets almost full threshold
    .DATA_WIDTH               (DSIZE ),   // Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
    .DEVICE                   ("7SERIES"),  // Target device: "7SERIES"
    .FIFO_SIZE                ("36Kb"), // Target BRAM: "18Kb" or "36Kb"
    .FIRST_WORD_FALL_THROUGH  ("TRUE") // Sets the FIFO FWFT to "TRUE" or "FALSE"
) FIFO_DUALCLOCK_MACRO_inst (
    .ALMOSTEMPTY    (),     // 1-bit output almost empty
    .ALMOSTFULL     (),     // 1-bit output almost full
    .DO             (mfifo_dout [KK]  ),                   // Output data, width defined by DATA_WIDTH parameter
    .EMPTY          (mfifo_empty[KK]  ),    // 1-bit output empty
    .FULL           (mfifo_full [KK]  ),     // 1-bit output full
    .RDCOUNT        (),         // Output read count, width determined by FIFO depth
    .RDERR          (),         // 1-bit output read error
    .WRCOUNT        (),         // Output write count, width determined by FIFO depth
    .WRERR          (),         // 1-bit output write error
    .DI             (mfifo_din[KK]    ),                 // Input data, width defined by DATA_WIDTH parameter
    .RDCLK          (mfifo_rd_clk[KK] ),                                             // 1-bit input read clock
    .RDEN           (mfifo_rd_en[KK] && en_rd_en ),                 // 1-bit input read enable
    .RST            (RST),                                                          // 1-bit input reset
    .WRCLK          (mfifo_wr_clk[KK] ),                                             // 1-bit input write clock
    .WREN           (mfifo_wr_en[KK] && en_wr_en )                  // 1-bit input write enable
);

if(KK==0)begin
    assign mfifo_wr_en[KK]  = wr_en;
    assign mfifo_din[KK]    = din;
    assign full             = mfifo_full[KK];
end else begin
    assign mfifo_wr_en[KK]  = !mfifo_empty[KK-1];
    assign mfifo_din[KK]    = mfifo_dout[KK-1];
end

if(KK==KNUM-1)begin
    assign dout             = mfifo_dout[KK];
    assign empty            = mfifo_empty[KK];
    assign mfifo_rd_en[KK]  = rd_en;
    assign mfifo_rd_clk[KK] = rd_clk;
end else begin
    assign mfifo_rd_en[KK]  = !mfifo_full[KK+1];
    assign mfifo_rd_clk[KK] = wr_clk;
end

assign mfifo_wr_clk[KK]     = wr_clk;

end
endgenerate

// End of FIFO_DUALCLOCK_MACRO_inst instantiation

endmodule
