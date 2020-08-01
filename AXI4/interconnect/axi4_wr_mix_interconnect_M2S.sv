/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    The slaver dont need to wait current burst finished,when get next burst
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/27 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_wr_mix_interconnect_M2S #(
    parameter NUM = 8
)(
    axi_inf.master_wr slaver [NUM-1:0],
    axi_inf.slaver_wr master
);

localparam NSIZE =  $clog2(NUM);
//--->> STREAM CLOCK AND RESET <<-------------------
wire        clock,rst_n;
assign      clock   = m00.axi_aclk;
assign      rst_n   = m00.axi_aresetn;
//---<< STREAM CLOCK AND RESET >>-------------------

//--->> AUXILIARY <<----------------


//---<< AUXILIARY >>----------------

endmodule
