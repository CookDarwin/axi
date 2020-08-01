/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/9/20 
madified:
***********************************************/
`timescale 1ns/1ps
module ku_long_fifo_4bit #(
    parameter LENGTH = 8192*2
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


// initial begin
//     if(LENGTH < 8192)begin
//         $error("%s,%d,Long FIFO <LENGHT> larger than 8192",`__FILE__,`__LINE__);
//         $finish;
//     end
// end

genvar KK;

localparam K36NUM_S = LENGTH/8192;
localparam K18_EX = (LENGTH%8192 != 0) && (LENGTH%8192 < 8192/2);
localparam K36_EX = (LENGTH%8192 != 0) && (LENGTH%8192 > 8192/2);
localparam K36NUM = K36NUM_S + K36_EX;

logic           ex_fifo_wr_en   [K36NUM-1:0];
logic           ex_fifo_rd_en   [K36NUM-1:0];
logic [3:0]     ex_fifo_din     [K36NUM-1:0];
logic [3:0]     ex_fifo_dout    [K36NUM-1:0];
logic           ex_fifo_full    [K36NUM-1:0];
logic           ex_fifo_empty   [K36NUM-1:0];

logic           k18_fifo_wr_en;
logic           k18_fifo_rd_en;
logic [3:0]     k18_fifo_din;
logic [3:0]     k18_fifo_dout;
logic           k18_fifo_full;
logic           k18_fifo_empty;

logic           k36_fifo_wr_en;
logic           k36_fifo_rd_en;
logic [3:0]     k36_fifo_din;
logic [3:0]     k36_fifo_dout;
logic           k36_fifo_full;
logic           k36_fifo_empty;

generate
if(LENGTH <= 4096)begin
fifo_ku_18bit #(
    .DSIZE  (4)
)fifo_ku_18bit_inst(
/*  input              */ .wr_clk   (wr_clk ),
/*  input              */ .wr_rst   (wr_rst ),
/*  input              */ .rd_clk   (rd_clk ),
/*  input              */ .rd_rst   (rd_rst ),
/*  input [DSIZE-1:0]  */ .din      (din    ),
/*  input              */ .wr_en    (wr_en  ),
/*  input              */ .rd_en    (rd_en  ),
/*  output [DSIZE-1:0] */ .dout     (dout   ),
/*  output             */ .full     (full   ),
/*  output             */ .empty    (empty  ),
/*  output [13-1:0]    */ .rdcount  (),
/*  output [13-1:0]    */ .wrcount  ()
);
end else if(LENGTH <= 8192)begin
fifo_ku_36bit #(
    .DSIZE  (4)
)fifo_ku_36bit_inst(
/*  input              */ .wr_clk   (wr_clk ),
/*  input              */ .wr_rst   (wr_rst ),
/*  input              */ .rd_clk   (rd_clk ),
/*  input              */ .rd_rst   (rd_rst ),
/*  input [DSIZE-1:0]  */ .din      (din    ),
/*  input              */ .wr_en    (wr_en  ),
/*  input              */ .rd_en    (rd_en  ),
/*  output [DSIZE-1:0] */ .dout     (dout   ),
/*  output             */ .full     (full   ),
/*  output             */ .empty    (empty  ),
/*  output [13-1:0]    */ .rdcount  (),
/*  output [13-1:0]    */ .wrcount  ()
);
end else begin
assign ex_fifo_din[0]   = din;
assign ex_fifo_wr_en[0] = wr_en;
assign full             = ex_fifo_full[0];
// assign empty            = ex_fifo_empty[K36NUM-1];
// assign ex_fifo_rd_en[K36NUM-1] = rd_en;

for(KK=0;KK<K36NUM;KK++)begin
fifo_ku_36bit #(
    .DSIZE  (4)
)fifo_ku_36bit_inst(
/*  input              */ .wr_clk   (wr_clk ),
/*  input              */ .wr_rst   (wr_rst ),
/*  input              */ .rd_clk   (rd_clk ),
/*  input              */ .rd_rst   (rd_rst ),
/*  input [DSIZE-1:0]  */ .din      (ex_fifo_din  [KK]  ),
/*  input              */ .wr_en    (ex_fifo_wr_en[KK]  ),
/*  input              */ .rd_en    (ex_fifo_rd_en[KK]  ),
/*  output [DSIZE-1:0] */ .dout     (ex_fifo_dout [KK]  ),
/*  output             */ .full     (ex_fifo_full [KK]  ),
/*  output             */ .empty    (ex_fifo_empty[KK]  ),
/*  output [13-1:0]    */ .rdcount  (),
/*  output [13-1:0]    */ .wrcount  ()
);
if(KK<K36NUM-1)begin
    assign ex_fifo_din[KK+1]    = ex_fifo_dout[KK];
    assign ex_fifo_wr_en[KK+1]  = !ex_fifo_empty[KK];
    assign ex_fifo_rd_en[KK]    = !ex_fifo_full[KK+1];
end

end

if(K18_EX)begin
assign k18_fifo_din      = ex_fifo_dout[K36NUM-1];
assign k18_fifo_wr_en    = !ex_fifo_empty[K36NUM-1];

assign ex_fifo_rd_en[K36NUM-1]  = !k18_fifo_full;
assign k18_fifo_rd_en    = rd_en;
assign empty        = k18_fifo_empty;
assign dout         = k18_fifo_dout;

fifo_ku_18bit #(
    .DSIZE  (4)
)fifo_ku_18bit_inst(
/*  input              */ .wr_clk   (wr_clk ),
/*  input              */ .wr_rst   (wr_rst ),
/*  input              */ .rd_clk   (rd_clk ),
/*  input              */ .rd_rst   (rd_rst ),
/*  input [DSIZE-1:0]  */ .din      (k18_fifo_din    ),
/*  input              */ .wr_en    (k18_fifo_wr_en  ),
/*  input              */ .rd_en    (k18_fifo_rd_en  ),
/*  output [DSIZE-1:0] */ .dout     (k18_fifo_dout   ),
/*  output             */ .full     (k18_fifo_full   ),
/*  output             */ .empty    (k18_fifo_empty  ),
/*  output [13-1:0]    */ .rdcount  (),
/*  output [13-1:0]    */ .wrcount  ()
);
end else if(K36_EX)begin
assign k36_fifo_din      = ex_fifo_dout[K36NUM-1];
assign k36_fifo_wr_en    = !ex_fifo_empty[K36NUM-1];

assign ex_fifo_rd_en[K36NUM-1]  = !k36_fifo_full;
assign k36_fifo_rd_en    = rd_en;
assign empty        = k36_fifo_empty;
assign dout         = k36_fifo_dout;

fifo_ku_36bit #(
    .DSIZE  (4)
)fifo_ku_36bit_inst(
/*  input              */ .wr_clk   (wr_clk ),
/*  input              */ .wr_rst   (wr_rst ),
/*  input              */ .rd_clk   (rd_clk ),
/*  input              */ .rd_rst   (rd_rst ),
/*  input [DSIZE-1:0]  */ .din      (k36_fifo_din    ),
/*  input              */ .wr_en    (k36_fifo_wr_en  ),
/*  input              */ .rd_en    (k36_fifo_rd_en  ),
/*  output [DSIZE-1:0] */ .dout     (k36_fifo_dout   ),
/*  output             */ .full     (k36_fifo_full   ),
/*  output             */ .empty    (k36_fifo_empty  ),
/*  output [13-1:0]    */ .rdcount  (),
/*  output [13-1:0]    */ .wrcount  ()
);
end else begin
assign empty            = ex_fifo_empty[K36NUM-1];
assign ex_fifo_rd_en[K36NUM-1] = rd_en;
assign dout             = ex_fifo_dout[K36NUM-1];
end

end
endgenerate

endmodule
