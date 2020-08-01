/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/8/25 
madified:
***********************************************/
`timescale 1ns/1ps
(* data_inf_c = "true" *)
module data_c_tmp_cache (
    (* data_up = "true" *)
    data_inf_c.slaver     slaver,
    (* data_down = "true" *)
    data_inf_c.master     master
);

import SystemPkg::*;
logic   full;
logic   empty;

xilinx_fifo_verb #(
//xilinx_fifo #(
    .DSIZE      (slaver.DSIZE)
)xilinx_fifo_inst(
/*  input              */ .wr_clk       (slaver.clock   ),
/*  input              */ .wr_rst       (!slaver.rst_n   ),
/*  input              */ .rd_clk       (master.clock   ),
/*  input              */ .rd_rst       (!master.rst_n   ),
/*  input [DSIZE-1:0]  */ .din          (slaver.data    ),
/*  input              */ .wr_en        ((slaver.valid && slaver.ready)),
/*  input              */ .rd_en        ((master.valid && master.ready)),
/*  output [DSIZE-1:0] */ .dout         (master.data    ),
/*  output             */ .full         (full           ),
/*  output             */ .empty        (empty          )
);


assign slaver.ready = !full && master.ready;
assign master.valid = !empty;

endmodule
