/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018-4-11 16:46:31
madified:
***********************************************/
`timescale 1ns/1ps
module trigger_ready_ctrl(
    input           clock,
    input           rst_n,
    input           trigger_set_high,
    input           trigger_set_low,
    output logic    ready
);



always@(posedge clock,negedge rst_n)
    if(~rst_n)  ready   <= 1'b1;
    else begin
        if(trigger_set_high)
                ready   <= 1'b1;
        else if(trigger_set_low)
                ready   <= 1'b0;
        else    ready   <= ready;
    end


endmodule
