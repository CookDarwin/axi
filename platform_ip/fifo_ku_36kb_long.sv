/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018/1/18 
madified:
***********************************************/
`timescale 1ns/1ps
module fifo_ku_36kb_long #(
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

logic  EMPTY,FULL;

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

fifo_ku #(
    .DSIZE  (DSIZE  )
)fifo_ku_inst(
/*  input                   */ .wr_clk      (mfifo_wr_clk[KK]   ),
/*  input                   */ .wr_rst      (RST                ),
/*  input                   */ .rd_clk      (mfifo_rd_clk[KK]   ),
/*  input                   */ .rd_rst      (RST                ),
/*  input [DSIZE-1:0]       */ .din         (mfifo_din[KK]      ),
/*  input                   */ .wr_en       (mfifo_wr_en[KK] && en_wr_en    ),
/*  input                   */ .rd_en       (mfifo_rd_en[KK] && en_rd_en    ),
/*  output logic[DSIZE-1:0] */ .dout        (mfifo_dout [KK]    ),
/*  output logic            */ .full        (mfifo_full [KK]    ),
/*  output logic            */ .empty       (mfifo_empty[KK]    ),
/*  output logic[14-1:0]    */ .rdcount     (),
/*  output logic[14-1:0]    */ .wrcount     ()
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
