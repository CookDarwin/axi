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
module fifo_ku_18bit #(
    parameter DSIZE = 18
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
    output [13-1:0]     rdcount,
    output [13-1:0]     wrcount
);

// parameter LSIZE = $clog2(900*18/DSIZE);

initial begin
    assert(DSIZE<=32)
    else $error("FIFO DSIZE must smaller than 32");
end

// localparam   PDSIZE =   DSIZE<=4 ? 4 :
//                         DSIZE<=9 ? 9 :
//                         DSIZE<=18? 18 : 36 ;

localparam   PDSIZE =   DSIZE<=4 ? 4 :
                        DSIZE<=8 ? 9 :
                        DSIZE<=16? 18 : 36 ;

// localparam PDSIZE   = DSIZE;

logic [32-1:0]      DOUT;
logic [32-1:0]      DIN;
logic                   RST;

assign DIN  = din;
assign dout = DOUT[DSIZE-1:0];

assign RST  = wr_rst || rd_rst;

//  FIFO18E2   : In order to incorporate this function into the design,
//   Verilog   : the following instance declaration needs to be placed
//  instance   : in the body of the design code.  The instance name
// declaration : (FIFO18E2_inst) and/or the port declarations within the
//    code     : parenthesis may be changed to properly reference and
//             : connect this function to the design.  All inputs
//             : and outputs must be connected.

//  <-----Cut code below this line---->

   // FIFO18E2: 18Kb FIFO (First-In-First-Out) Block RAM Memory
   //           Kintex UltraScale
   // Xilinx HDL Language Template, version 2017.1

   FIFO18E2 #(
      .CASCADE_ORDER            ("NONE"),            // FIRST, LAST, MIDDLE, NONE, PARALLEL
      .CLOCK_DOMAINS            ("INDEPENDENT"),     // COMMON, INDEPENDENT
      .FIRST_WORD_FALL_THROUGH  ("TRUE"), // FALSE, TRUE
      .INIT                     (36'h000000000),              // Initial values on output port
      .PROG_EMPTY_THRESH        (256),           // Programmable Empty Threshold
      .PROG_FULL_THRESH         (256),            // Programmable Full Threshold
      // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
      .IS_RDCLK_INVERTED        (1'b0),          // Optional inversion for RDCLK
      .IS_RDEN_INVERTED         (1'b0),           // Optional inversion for RDEN
      .IS_RSTREG_INVERTED       (1'b0),         // Optional inversion for RSTREG
      .IS_RST_INVERTED          (1'b0),            // Optional inversion for RST
      .IS_WRCLK_INVERTED        (1'b0),          // Optional inversion for WRCLK
      .IS_WREN_INVERTED         (1'b0),           // Optional inversion for WREN
      .RDCOUNT_TYPE             ("SIMPLE_DATACOUNT"),         // EXTENDED_DATACOUNT, RAW_PNTR, SIMPLE_DATACOUNT, SYNC_PNTR
      .READ_WIDTH               (PDSIZE),                    // 18-9
      .REGISTER_MODE            ("UNREGISTERED"),    // DO_PIPELINED, REGISTERED, UNREGISTERED
      .RSTREG_PRIORITY          ("RSTREG"),        // REGCE, RSTREG
      .SLEEP_ASYNC              ("FALSE"),             // FALSE, TRUE
      .SRVAL                    (36'h000000000),             // SET/reset value of the FIFO outputs
      .WRCOUNT_TYPE             ("SIMPLE_DATACOUNT"),         // EXTENDED_DATACOUNT, RAW_PNTR, SIMPLE_DATACOUNT, SYNC_PNTR
      .WRITE_WIDTH              (PDSIZE)                    // 18-9
   )
   FIFO18E2_inst (
      // Cascade Signals outputs: Multi-FIFO cascade signals
      .CASDOUT          (),             // 32-bit output: Data cascade output bus
      .CASDOUTP         (),           // 4-bit output: Parity data cascade output bus
      .CASNXTEMPTY      (),     // 1-bit output: Cascade next empty
      .CASPRVRDEN       (),       // 1-bit output: Cascade previous read enable
      // Read Data outputs: Read output data
      .DOUT                 (DOUT),                   // 32-bit output: FIFO data output bus
      .DOUTP                (),                 // 4-bit output: FIFO parity output bus.
      // Status outputs: Flags and other FIFO status outputs
      .EMPTY                (empty),                 // 1-bit output: Empty
      .FULL                 (full),                   // 1-bit output: Full
      .PROGEMPTY            (),         // 1-bit output: Programmable empty
      .PROGFULL             (),           // 1-bit output: Programmable full
      .RDCOUNT              (rdcount),             // 13-bit output: Read count
      .RDERR                (),                 // 1-bit output: Read error
      .RDRSTBUSY            (),         // 1-bit output: Reset busy (sync to RDCLK)
      .WRCOUNT              (wrcount),             // 13-bit output: Write count
      .WRERR                (),                 // 1-bit output: Write Error
      .WRRSTBUSY            (),         // 1-bit output: Reset busy (sync to WRCLK)
      // Cascade Signals inputs: Multi-FIFO cascade signals
      .CASDIN               ('0),               // 32-bit input: Data cascade input bus
      .CASDINP              ('0),             // 4-bit input: Parity data cascade input bus
      .CASDOMUX             ('0),           // 1-bit input: Cascade MUX select
      .CASDOMUXEN           ('0),       // 1-bit input: Enable for cascade MUX select
      .CASNXTRDEN           ('0),       // 1-bit input: Cascade next read enable
      .CASOREGIMUX          ('0),     // 1-bit input: Cascade output MUX select
      .CASOREGIMUXEN        ('0), // 1-bit input: Cascade output MUX select enable
      .CASPRVEMPTY          ('0),     // 1-bit input: Cascade previous empty
      // Read Control Signals inputs: Read clock, enable and reset input signals
      .RDCLK                (rd_clk),                 // 1-bit input: Read clock
      .RDEN                 (rd_en && !empty),                   // 1-bit input: Read enable
      .REGCE                (1'b0),                 // 1-bit input: Output register clock enable
      .RSTREG               (1'b0),               // 1-bit input: Output register reset
      .SLEEP                (1'b0),                 // 1-bit input: Sleep Mode
      // Write Control Signals inputs: Write clock and enable input signals
      .RST                  (RST),                     // 1-bit input: Reset
      .WRCLK                (wr_clk),                 // 1-bit input: Write clock
      .WREN                 (wr_en && !full),                   // 1-bit input: Write enable
      // Write Data inputs: Write input data
      .DIN                  (DIN),                     // 32-bit input: FIFO data input bus
      .DINP                 ('1)                    // 4-bit input: FIFO parity input bus
   );

   // End of FIFO18E2_inst instantiation

endmodule
