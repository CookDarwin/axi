/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERB.0.0
    add FAMIRY parameter
creaded: 2017/5/19 
madified:
***********************************************/
`timescale 1ns/1ps
module long_fifo_verb #(
    parameter DSIZE  = 10,
    parameter LENGTH = 8192*2
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

import GlobalPkg::FAMIRY;

localparam  NUM = DSIZE/4 + (DSIZE%4 != 0);

logic [NUM-1:0]     fifo_wr_en;
logic [NUM-1:0]     fifo_rd_en;

logic [NUM-1:0]     fifo_full;
logic [NUM-1:0]     fifo_empty;

logic [4-1:0]       fifo_wr_data [NUM-1:0];
logic [4-1:0]       fifo_rd_data [NUM-1:0];

logic [4*NUM-1:0]   pre_dout;

logic   RST;
logic   en_rd_en;
logic   en_wr_en;

fifo_wr_rd_mark fifo_wr_rd_mark_inst(
/*  input        */   .rd_clk       (rd_clk ),
/*  input        */   .wr_clk       (wr_clk ),
/*  input        */   .rd_rst       (rd_rst ),
/*  input        */   .wr_rst       (wr_rst ),
// /*  output logic */   .en_rd_en     (en_rd_en   ),
// /*  output logic */   .en_wr_en     (en_wr_en   ),
/*  output logic */   .en_rd_en     (   ),
/*  output logic */   .en_wr_en     (   ),
/*  output logic */   .fifo_rst     (RST        )
);

assign en_rd_en = 1'b1;
assign en_wr_en = 1'b1;

genvar KK;
generate
for(KK=0;KK<NUM;KK++)begin

if(FAMIRY == "kintexu" || FAMIRY == "ultrascale")
    ku_long_fifo_4bit #(
        .LENGTH     (LENGTH)
    )ku_long_fifo_4bit_inst(
    /*  input          */ .wr_clk       (wr_clk   ),
    /*  input          */ .wr_rst       (RST   ),
    /*  input          */ .rd_clk       (rd_clk   ),
    /*  input          */ .rd_rst       (RST   ),
    /*  input [3:0]  */   .din          (fifo_wr_data[KK] ),
    /*  input        */   .wr_en        (fifo_wr_en[KK] && en_wr_en),
    /*  input        */   .rd_en        (fifo_rd_en[KK] && en_rd_en),
    /*  output [4:0] */   .dout         (fifo_rd_data[KK]),
    /*  output       */   .full         (fifo_full[KK]),
    /*  output       */   .empty        (fifo_empty[KK])
    );
else
    long_fifo_4bit #(
        .LENGTH     (LENGTH)
    )long_fifo_4bit_inst(
    /*  input          */ .wr_clk       (wr_clk   ),
    /*  input          */ .wr_rst       (RST   ),
    /*  input          */ .rd_clk       (rd_clk   ),
    /*  input          */ .rd_rst       (RST   ),
    /*  input [3:0]  */   .din          (fifo_wr_data[KK] ),
    /*  input        */   .wr_en        (fifo_wr_en[KK] && en_wr_en),
    /*  input        */   .rd_en        (fifo_rd_en[KK] && en_rd_en),
    /*  output [4:0] */   .dout         (fifo_rd_data[KK]),
    /*  output       */   .full         (fifo_full[KK]),
    /*  output       */   .empty        (fifo_empty[KK])
    );

assign  fifo_wr_en[KK]   = wr_en;
assign  fifo_wr_data[KK] = ((DSIZE/4 != 0) && (KK==NUM-1))? din[DSIZE-1:KK*4] : din[KK*4+:4];
assign  pre_dout[KK*4+:4]      = fifo_rd_data[KK];

assign fifo_rd_en[KK]    = rd_en;
end
endgenerate

assign empty    = fifo_empty[0];
assign full     = fifo_full[0];
assign dout     = pre_dout[DSIZE-1:0];

endmodule
