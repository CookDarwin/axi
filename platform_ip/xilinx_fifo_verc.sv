/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    xilinx fifo ip wrapper
author : Cook.Darwin
Version: VERB.0.0 2017/9/19 
    add famiry parameter
Version: VERC.0.0 2018/1/19 
    use LENGTH,and use 36kb
creaded: 2017/3/1 
madified:
***********************************************/
`timescale 1ns/1ps
module xilinx_fifo_verc #(
    parameter DEPTH     = 4,
    parameter DSIZE     = 18,
    parameter LENGTH    = 1024             // it control none
    // parameter LSIZE     = $clog2(LENGTH+1)
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
    // output [LSIZE-1:0]  rdcount,
    // output [LSIZE-1:0]  wrcount
);

import GlobalPkg::*;

// parameter LLSIZE =
// (DSIZE>= 37             )?  9 :         //
// (DSIZE>= 19 && DSIZE<=36)?  9 :         //
// (DSIZE>= 10 && DSIZE<=18)? 10 :         //
// (DSIZE>=  5 && DSIZE<=9 )? 11 :         //
// (DSIZE>=  1 && DSIZE<=4 )? 12 :  1 ;      //

// logic [LLSIZE-1:0]   wcount;
// logic [LLSIZE-1:0]   rcount;

generate
if(FAMIRY == "kintexu" || FAMIRY == "ultrascale")begin
fifo_ku_36kb_long #(
    .DSIZE          (DSIZE  ),
    .DEPTH          (DEPTH )
)fifo_ku_36kb_long_inst(
/*  input              */ .wr_clk       (wr_clk     ),
/*  input              */ .wr_rst       (wr_rst     ),
/*  input              */ .rd_clk       (rd_clk     ),
/*  input              */ .rd_rst       (rd_rst     ),
/*  input [DSIZE-1:0]  */ .din          (din        ),
/*  input              */ .wr_en        (wr_en      ),
/*  input              */ .rd_en        (rd_en      ),
/*  output [DSIZE-1:0] */ .dout         (dout       ),
/*  output             */ .full         (full       ),
/*  output             */ .empty        (empty      )
);
end else begin
fifo_36kb_long #(
    .DSIZE          (DSIZE  ),
    .DEPTH          (DEPTH )
)fifo_36kb_long_inst(
/*  input              */ .wr_clk       (wr_clk     ),
/*  input              */ .wr_rst       (wr_rst     ),
/*  input              */ .rd_clk       (rd_clk     ),
/*  input              */ .rd_rst       (rd_rst     ),
/*  input [DSIZE-1:0]  */ .din          (din        ),
/*  input              */ .wr_en        (wr_en      ),
/*  input              */ .rd_en        (rd_en      ),
/*  output [DSIZE-1:0] */ .dout         (dout       ),
/*  output             */ .full         (full       ),
/*  output             */ .empty        (empty      )
);
// assign wrcount  = wcount;
// assign rdcount  = rcount;

end
endgenerate

endmodule
