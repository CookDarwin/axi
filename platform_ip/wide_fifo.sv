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
module wide_fifo #(
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


import GlobalPkg::*;
generate
if(FAMIRY == "kintexu" || FAMIRY == "ultrascale")begin
fifo_ku #(
    .DSIZE  (DSIZE  )
)fifo_ku_inst(
/*  input                   */ .wr_clk          (wr_clk     ),
/*  input                   */ .wr_rst          (wr_rst     ),
/*  input                   */ .rd_clk          (rd_clk     ),
/*  input                   */ .rd_rst          (rd_rst     ),
/*  input [DSIZE-1:0]       */ .din             (din        ),
/*  input                   */ .wr_en           (wr_en      ),
/*  input                   */ .rd_en           (rd_en      ),
/*  output logic[DSIZE-1:0] */ .dout            (dout       ),
/*  output logic            */ .full            (full       ),
/*  output logic            */ .empty           (empty      ),
/*  output logic[14-1:0]    */ .rdcount         (),
/*  output logic[14-1:0]    */ .wrcount         ()
);
end else begin
wide_fifo_7series #(
    .DSIZE      (DSIZE  )
)wide_fifo_7series_inst(
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

end
endgenerate

endmodule
