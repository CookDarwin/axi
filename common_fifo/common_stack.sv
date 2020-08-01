/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018/11/24 
madified:
***********************************************/
`timescale 1ns/1ps
module common_stack #(
    parameter DEPTH = 1024
)(
    input                           clock,
    input                           rst_n,
    input                           push,
    input                           pop,
    output logic                    empty,
    output logic[$clog2(DEPTH)-1:0] addr
);

always@(posedge clock,negedge rst_n)
    if(~rst_n)      addr    <= '0;
    else begin
        if(push && pop)
            addr    <= addr;
        else if(push)begin
            if(addr != '1)
                    addr    <= addr + 1'b1;
            else    addr    <= '1;
        end else if(pop)begin
            if(addr != '0)
                    addr    <= addr - 1'b1;
            else    addr    <= '0;
        end else begin
            addr <= addr;
        end
    end


always@(posedge clock,negedge rst_n)
    if(~rst_n)  empty   <= 1'b0;
    else begin
        if(push && pop && addr == '0)
                empty   <= 1'b1;
        else if(push)
                empty   <= 1'b0;
        else if(pop && addr == 1)
                empty   <= 1'b1;
        else if(addr == '0)
                empty   <= 1'b1;
        else    empty   <= empty;
    end

endmodule
