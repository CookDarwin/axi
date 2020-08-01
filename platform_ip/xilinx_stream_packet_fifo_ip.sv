/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    xilinx ip wrapper
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/28 
madified:
***********************************************/
`timescale 1ns/1ps
module xilinx_stream_packet_fifo_ip (
    input               wr_clk,
    input               wr_rst,
    input               rd_clk,
    input               rd_rst,
    input [7:0]         din   ,
    input               wr_en ,
    input               rd_en ,
    output [7:0]        dout  ,
    output              full  ,
    output              empty
);


stream_packet_fifo_ip stream_packet_fifo_ip_inst (
/*    input        */ .wr_clk      (wr_clk          ),
/*    input        */ .wr_rst      (wr_rst          ),
/*    input        */ .rd_clk      (rd_clk          ),
/*    input        */ .rd_rst      (rd_rst          ),
/*    input [7:0]  */ .din         (din             ),
/*    input        */ .wr_en       (wr_en           ),
/*    input        */ .rd_en       (rd_en           ),
/*    output [7:0] */ .dout        (dout            ),
/*    output       */ .full        (full            ),
/*    output       */ .empty       (empty           )
);

endmodule
