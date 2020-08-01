/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/1 
madified:
***********************************************/
`timescale 1ns/1ps
module id_record #(
    parameter LEN       = 16,
    parameter IDSIZE    = $clog2(LEN)
)(
    input                   clock,
    input                   rst_n,
    input [IDSIZE-1:0]      set_id,
    input                   set_vld,
    input [IDSIZE-1:0]      clear_id,
    input                   clear_vld,
    input [IDSIZE-1:0]      read_id,
    input                   read_en,
    output logic            result,
    output logic            full
);

logic [LEN-1:0]     data;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  data    <= '0;
    else begin
        if(clear_vld)
                data[clear_id]  <= 1'b0;
        else    data[clear_id]  <= data[clear_id];

        if(set_vld)
                data[set_id]    <= 1'b1;
        else    data[set_id]    <= data[set_id];

    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  result  <= 1'b0;
    else begin
        if(read_en)
                result  <= data[read_id];
        else    result  <= result;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  full    <= 1'b0;
    else        full    <= &data;

endmodule
