/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/9/18 
madified:
***********************************************/
`timescale 1ns/1ps
module fifo_ku_36bit #(
    parameter DSIZE = 36
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
    output              empty ,
    output [14-1:0]     rdcount,
    output [14-1:0]     wrcount
);

initial begin
    assert(DSIZE<=64)
    else $error("FIFO DSIZE must smaller than 64");
end

// localparam   PDSIZE = DSIZE<4 ? 4 : DSIZE;

// localparam   PDSIZE =   DSIZE<=4 ? 4 :
//                         DSIZE<=9 ? 9 :
//                         DSIZE<=18? 18 :
//                         DSIZE<=36? 36 : 72 ;

localparam   PDSIZE =   DSIZE<=4 ? 4 :
                        DSIZE<=8 ? 9 :
                        DSIZE<=16? 18 :
                        DSIZE<=32? 36 : 72;

logic [64-1:0]          DOUT;
logic [64-1:0]          DIN;
logic                   RST;

assign DIN  = din;
assign dout = DOUT[DSIZE-1:0];

assign RST  = wr_rst || rd_rst;

//  FIFO36E2   : In order to incorporate this function into the design,
//   Verilog   : the following instance declaration needs to be placed
//  instance   : in the body of the design code.  The instance name
// declaration : (FIFO36E2_inst) and/or the port declarations within the
//    code     : parenthesis may be changed to properly reference and
//             : connect this function to the design.  All inputs
//             : and outputs must be connected.

//  <-----Cut code below this line---->

   // FIFO36E2: 36Kb FIFO (First-In-First-Out) Block RAM Memory
   //           Kintex UltraScale
   // Xilinx HDL Language Template, version 2017.1

   FIFO36E2 #(
      .CASCADE_ORDER        ("NONE"),            // FIRST, LAST, MIDDLE, NONE, PARALLEL
      .CLOCK_DOMAINS        ("INDEPENDENT"),     // COMMON, INDEPENDENT
      .EN_ECC_PIPE          ("FALSE"),             // ECC pipeline register, (FALSE, TRUE)
      .EN_ECC_READ          ("FALSE"),             // Enable ECC decoder, (FALSE, TRUE)
      .EN_ECC_WRITE         ("FALSE"),            // Enable ECC encoder, (FALSE, TRUE)
      .FIRST_WORD_FALL_THROUGH("TRUE"), // FALSE, TRUE
      .INIT                 (72'h000000000000000000),     // Initial values on output port
      .PROG_EMPTY_THRESH    (256),           // Programmable Empty Threshold
      .PROG_FULL_THRESH     (256),            // Programmable Full Threshold
      // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
      .IS_RDCLK_INVERTED    (1'b0),          // Optional inversion for RDCLK
      .IS_RDEN_INVERTED     (1'b0),           // Optional inversion for RDEN
      .IS_RSTREG_INVERTED   (1'b0),         // Optional inversion for RSTREG
      .IS_RST_INVERTED      (1'b0),            // Optional inversion for RST
      .IS_WRCLK_INVERTED    (1'b0),          // Optional inversion for WRCLK
      .IS_WREN_INVERTED     (1'b0),           // Optional inversion for WREN
      .RDCOUNT_TYPE         ("SIMPLE_DATACOUNT"),         // EXTENDED_DATACOUNT, RAW_PNTR, SIMPLE_DATACOUNT, SYNC_PNTR
      .READ_WIDTH           (PDSIZE),                    // 18-9
      .REGISTER_MODE        ("UNREGISTERED"),    // DO_PIPELINED, REGISTERED, UNREGISTERED
      .RSTREG_PRIORITY      ("RSTREG"),        // REGCE, RSTREG
      .SLEEP_ASYNC          ("FALSE"),             // FALSE, TRUE
      .SRVAL                (72'h000000000000000000),    // SET/reset value of the FIFO outputs
      .WRCOUNT_TYPE         ("SIMPLE_DATACOUNT"),         // EXTENDED_DATACOUNT, RAW_PNTR, SIMPLE_DATACOUNT, SYNC_PNTR
      .WRITE_WIDTH          (PDSIZE)                    // 18-9
   )
   FIFO36E2_inst (
      // Cascade Signals outputs: Multi-FIFO cascade signals
      .CASDOUT          (),             // 64-bit output: Data cascade output bus
      .CASDOUTP         (),           // 8-bit output: Parity data cascade output bus
      .CASNXTEMPTY      (),     // 1-bit output: Cascade next empty
      .CASPRVRDEN       (),       // 1-bit output: Cascade previous read enable
      // ECC Signals outputs: Error Correction Circuitry ports
      .DBITERR          (),             // 1-bit output: Double bit error status
      .ECCPARITY        (),         // 8-bit output: Generated error correction parity
      .SBITERR          (),             // 1-bit output: Single bit error status
      // Read Data outputs: Read output data
      .DOUT             (DOUT),                   // 64-bit output: FIFO data output bus
      .DOUTP            (),                 // 8-bit output: FIFO parity output bus.
      // Status outputs: Flags and other FIFO status outputs
      .EMPTY            (empty),                 // 1-bit output: Empty
      .FULL             (full),                   // 1-bit output: Full
      .PROGEMPTY        (),         // 1-bit output: Programmable empty
      .PROGFULL         (),           // 1-bit output: Programmable full
      .RDCOUNT          (rdcount),             // 14-bit output: Read count
      .RDERR            (),                 // 1-bit output: Read error
      .RDRSTBUSY        (),         // 1-bit output: Reset busy (sync to RDCLK)
      .WRCOUNT          (wrcount),             // 14-bit output: Write count
      .WRERR            (),                 // 1-bit output: Write Error
      .WRRSTBUSY        (),         // 1-bit output: Reset busy (sync to WRCLK)
      // Cascade Signals inputs: Multi-FIFO cascade signals
      .CASDIN           ('0),               // 64-bit input: Data cascade input bus
      .CASDINP          ('0),             // 8-bit input: Parity data cascade input bus
      .CASDOMUX         ('0),           // 1-bit input: Cascade MUX select input
      .CASDOMUXEN       ('1),       // 1-bit input: Enable for cascade MUX select
      .CASNXTRDEN       ('0),       // 1-bit input: Cascade next read enable
      .CASOREGIMUX      ('0),     // 1-bit input: Cascade output MUX select
      .CASOREGIMUXEN    ('1), // 1-bit input: Cascade output MUX select enable
      .CASPRVEMPTY      ('0),     // 1-bit input: Cascade previous empty
      // ECC Signals inputs: Error Correction Circuitry ports
      .INJECTDBITERR    ('0), // 1-bit input: Inject a double bit error
      .INJECTSBITERR    ('0), // 1-bit input: Inject a single bit error
      // Read Control Signals inputs: Read clock, enable and reset input signals
      .RDCLK            (rd_clk),                 // 1-bit input: Read clock
      .RDEN             (rd_en && !empty),                   // 1-bit input: Read enable
      .REGCE            (1'b0),                 // 1-bit input: Output register clock enable
      .RSTREG           (1'b0),               // 1-bit input: Output register reset
      .SLEEP            ('0),                 // 1-bit input: Sleep Mode
      // Write Control Signals inputs: Write clock and enable input signals
      .RST              (RST),                     // 1-bit input: Reset
      .WRCLK            (wr_clk),                 // 1-bit input: Write clock
      .WREN             (wr_en && !full),                   // 1-bit input: Write enable
      // Write Data inputs: Write input data
      .DIN              (DIN),                     // 64-bit input: FIFO data input bus
      .DINP             ('0)                    // 8-bit input: FIFO parity input bus
   );

   // End of FIFO36E2_inst instantiation

endmodule
