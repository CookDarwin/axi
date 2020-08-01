/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/20 
madified:
***********************************************/
`timescale 1ns/1ps
import DataInterfacePkg::*;
module simple_data_pipe_slaver #(
    parameter DSIZE = 24
)(
    input                       clock,
    input                       rst_n,
    input [DSIZE-1:0]           indata,
    input                       invalid,
    input                       inready,
    output logic[DSIZE-1:0]     outdata,
    input                       outvalid,
    input                       outready
);

always@(posedge clock,negedge rst_n)
    if(~rst_n)  outdata     <= '0;
    else begin
        foreach(outdata[i])
            outdata[i]  <= pipe_data_func(invalid,outready,outvalid,indata[i],outdata[i]);
    end

endmodule
