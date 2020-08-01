/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:   covert A to B
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/16 
madified:
***********************************************/
`timescale 1ns/1ps
module data_inf_B2A (
    data_inf_c.slaver     slaver,
    data_inf.master       master
);

assign slaver.ready     = master.ready;
assign master.valid     = slaver.valid;
assign master.data      = slaver.data;

endmodule
