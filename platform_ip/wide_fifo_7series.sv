/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018/2/28 
madified:
***********************************************/
`timescale 1ns/1ps
module wide_fifo_7series #(
    parameter DSIZE = 1024
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

initial begin
    assert(DSIZE>=64)
    else begin
        $error("\nWIDE FIFO DSIZE[%d] MUST LARGE THAN 64\n",DSIZE);
        $stop;
    end
end

localparam N36 = DSIZE/72 + (DSIZE<72);
localparam L36 = (DSIZE<72)? 0 : (DSIZE%72) ;
localparam SS = (L36>36)? "36Kb" : "18Kb";
genvar KK;
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

logic [8:0]     RDCOUNT [N36-1:0];
logic [8:0]     WRCOUNT [N36-1:0];
logic [N36-1:0] EMPTY;
logic [N36-1:0] FULL;

generate
for(KK=0;KK<N36;KK++)begin
FIFO_DUALCLOCK_MACRO  #(
    .ALMOST_EMPTY_OFFSET      (9'h010), // Sets the almost empty threshold
    .ALMOST_FULL_OFFSET       (9'h010),  // Sets almost full threshold
    .DATA_WIDTH               (72 ),   // Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
    .DEVICE                   ("7SERIES"),  // Target device: "7SERIES"
    .FIFO_SIZE                ("36Kb"), // Target BRAM: "18Kb" or "36Kb"
    .FIRST_WORD_FALL_THROUGH  ("TRUE") // Sets the FIFO FWFT to "TRUE" or "FALSE"
) FIFO_DUALCLOCK_MACRO_inst0 (
    .ALMOSTEMPTY    (),     // 1-bit output almost empty
    .ALMOSTFULL     (),     // 1-bit output almost full
    .DO             (dout[KK*72+:72]   ),                   // Output data, width defined by DATA_WIDTH parameter
    .EMPTY          (EMPTY[KK]  ),    // 1-bit output empty
    .FULL           (FULL[KK]   ),     // 1-bit output full
    .RDCOUNT        (RDCOUNT[KK]),         // Output read count, width determined by FIFO depth
    .RDERR          (),         // 1-bit output read error
    .WRCOUNT        (WRCOUNT[KK]),         // Output write count, width determined by FIFO depth
    .WRERR          (),         // 1-bit output write error
    .DI             (din[KK*72+:72]    ),                 // Input data, width defined by DATA_WIDTH parameter
    .RDCLK          (rd_clk   ),                                             // 1-bit input read clock
    .RDEN           (rd_en && en_rd_en),                 // 1-bit input read enable
    .RST            (RST),                                                          // 1-bit input reset
    .WRCLK          (wr_clk   ),                                             // 1-bit input write clock
    .WREN           (wr_en && en_wr_en )                  // 1-bit input write enable
);
end

if(L36 != 0 )begin
FIFO_DUALCLOCK_MACRO  #(
    .ALMOST_EMPTY_OFFSET      (9'h010), // Sets the almost empty threshold
    .ALMOST_FULL_OFFSET       (9'h010),  // Sets almost full threshold
    .DATA_WIDTH               (L36   ),   // Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
    .DEVICE                   ("7SERIES"),  // Target device: "7SERIES"
    .FIFO_SIZE                (SS ), // Target BRAM: "18Kb" or "36Kb"
    .FIRST_WORD_FALL_THROUGH  ("TRUE") // Sets the FIFO FWFT to "TRUE" or "FALSE"
) FIFO_DUALCLOCK_MACRO_72_inst0 (
    .ALMOSTEMPTY    (),     // 1-bit output almost empty
    .ALMOSTFULL     (),     // 1-bit output almost full
    .DO             (dout[DSIZE-1-:L36]   ),                   // Output data, width defined by DATA_WIDTH parameter
    .EMPTY          (  ),    // 1-bit output empty
    .FULL           (  ),     // 1-bit output full
    .RDCOUNT        (  ),         // Output read count, width determined by FIFO depth
    .RDERR          (  ),         // 1-bit output read error
    .WRCOUNT        (  ),         // Output write count, width determined by FIFO depth
    .WRERR          (),         // 1-bit output write error
    .DI             (din[DSIZE-1-:L36]    ),                 // Input data, width defined by DATA_WIDTH parameter
    .RDCLK          (rd_clk   ),                                             // 1-bit input read clock
    .RDEN           (rd_en && en_rd_en),                 // 1-bit input read enable
    .RST            (RST),                                                          // 1-bit input reset
    .WRCLK          (wr_clk   ),                                             // 1-bit input write clock
    .WREN           (wr_en && en_wr_en )                  // 1-bit input write enable
);
end
endgenerate

assign empty    = EMPTY[0];
assign full     = FULL[0];


endmodule
