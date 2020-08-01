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
module long_fifo_4bit #(
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


localparam K36NUM_S = LENGTH/8192;
localparam K18_EX = (LENGTH%8192 != 0) && (LENGTH%8192 < 8192/2);
localparam K36_EX = (LENGTH%8192 != 0) && (LENGTH%8192 > 8192/2);
localparam K36NUM = K36NUM_S + K36_EX;

logic           ex_fifo_wr_en;
logic           ex_fifo_rd_en;
logic [3:0]     ex_fifo_wr_data;
logic [3:0]     ex_fifo_rd_data;

logic           ex_fifo_full;
logic           ex_fifo_empty;

logic           fx_fifo_wr_en;
logic           fx_fifo_rd_en;
logic [3:0]     fx_fifo_wr_data;
logic [3:0]     fx_fifo_rd_data;

logic           fx_fifo_full;
logic           fx_fifo_empty;

generate
if(LENGTH <= 8192)begin
long_fifo_4bit_8192 #(
    .LENGTH     (LENGTH )
)long_fifo_4bit_8192_inst(
/*  input         */      .wr_clk       (wr_clk ),
/*  input         */      .wr_rst       (wr_rst ),
/*  input         */      .rd_clk       (rd_clk ),
/*  input         */      .rd_rst       (rd_rst ),
/*  input [3:0]   */      .din          (din    ),
/*  input         */      .wr_en        (wr_en  ),
/*  input         */      .rd_en        (rd_en  ),
/*  output [3:0]  */      .dout         (dout   ),
/*  output        */      .full         (full   ),
/*  output        */      .empty        (empty  )
);
end else if(LENGTH%8192 != 0)begin
long_fifo_4bit_SL8192 #(
    .LENGTH     (K36NUM_S*8192)
)long_fifo_4bit_SL8192_inst(
/*    input         */    .clk      (wr_clk     ),
/*    input         */    .rst      (wr_rst     ),
/*    input [3:0]   */    .din      (din        ),
/*    input         */    .wr_en    (wr_en      ),
/*    input         */    .rd_en    (ex_fifo_rd_en  ),
/*    output [3:0]  */    .dout     (ex_fifo_rd_data),
/*    output        */    .full     (ex_fifo_full   ),
/*    output        */    .empty    (ex_fifo_empty  )
);

long_fifo_4bit_8192 #(
    .LENGTH     (LENGTH%8192 )
)long_fifo_4bit_8192_inst(
/*  input         */      .wr_clk       (wr_clk ),
/*  input         */      .wr_rst       (wr_rst ),
/*  input         */      .rd_clk       (rd_clk ),
/*  input         */      .rd_rst       (rd_rst ),
/*  input [3:0]   */      .din          (fx_fifo_wr_data    ),
/*  input         */      .wr_en        (fx_fifo_wr_en      ),
/*  input         */      .rd_en        (fx_fifo_rd_en      ),
/*  output [3:0]  */      .dout         (fx_fifo_rd_data    ),
/*  output        */      .full         (fx_fifo_full   ),
/*  output        */      .empty        (fx_fifo_empty  )
);

assign ex_fifo_rd_en    = !fx_fifo_full && !ex_fifo_empty;
assign fx_fifo_wr_en    = ex_fifo_rd_en;

assign fx_fifo_wr_data  = ex_fifo_rd_data;
assign fx_fifo_rd_en    = rd_en;

assign dout             = fx_fifo_rd_data;

assign full             = ex_fifo_full;
assign empty            = fx_fifo_empty;

end else begin

long_fifo_4bit_SL8192 #(
    .LENGTH     ((K36NUM_S-1)*8192)
)long_fifo_4bit_SL8192_inst(
/*    input         */    .clk      (wr_clk     ),
/*    input         */    .rst      (wr_rst     ),
/*    input [3:0]   */    .din      (din        ),
/*    input         */    .wr_en    (wr_en      ),
/*    input         */    .rd_en    (ex_fifo_rd_en  ),
/*    output [3:0]  */    .dout     (ex_fifo_rd_data),
/*    output        */    .full     (ex_fifo_full   ),
/*    output        */    .empty    (ex_fifo_empty  )
);

long_fifo_4bit_8192 #(
    .LENGTH     (8192 )
)long_fifo_4bit_8192_inst(
/*  input         */      .wr_clk       (wr_clk ),
/*  input         */      .wr_rst       (wr_rst ),
/*  input         */      .rd_clk       (rd_clk ),
/*  input         */      .rd_rst       (rd_rst ),
/*  input [3:0]   */      .din          (fx_fifo_wr_data    ),
/*  input         */      .wr_en        (fx_fifo_wr_en      ),
/*  input         */      .rd_en        (fx_fifo_rd_en      ),
/*  output [3:0]  */      .dout         (fx_fifo_rd_data    ),
/*  output        */      .full         (fx_fifo_full   ),
/*  output        */      .empty        (fx_fifo_empty  )
);

assign ex_fifo_rd_en    = !fx_fifo_full && !ex_fifo_empty;
assign fx_fifo_wr_en    = ex_fifo_rd_en;

assign fx_fifo_wr_data  = ex_fifo_rd_data;
assign fx_fifo_rd_en    = rd_en;

assign dout             = fx_fifo_rd_data;

assign full             = ex_fifo_full;
assign empty            = fx_fifo_empty;
end
endgenerate

endmodule
