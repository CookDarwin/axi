/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/23 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module check_stream_crc (
    (* mirror_stream = "true" *)
    axi_stream_inf.mirror   axis_in
);

logic [31:0]     b_crc;
logic [15:0]     crc;

stream_crc stream_crc_inst(
/*  axi_stream_inf.mirror  */ .axis_in      (axis_in    ),
/*  output logic [31:0]    */ .crc          (b_crc      )
);

assign crc  = b_crc[31:16]+b_crc[15:0];

endmodule
