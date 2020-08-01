/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
created: ###### Tue Sep 10 17:13:52 CST 2019
madified:
***********************************************/
`timescale 1ns/1ps
`include "define_macro.sv"
module vcs_data_c_comptable #(
    `parameter_string   ORIGIN = "master",
    `parameter_string   TO     = "slaver"
)(
    data_inf_c         origin,
    data_inf_c         to
);

generate 
if(1)begin 
    if(TO=="mirror")begin 
        assign    to.data   = origin.data ;
        assign    to.valid  = origin.valid;
        assign    to.ready  = origin.ready;
    end 
end 

if(ORIGIN=="out_mirror")begin 
    if(TO=="master")begin 
        assign    origin.data   = to.data ;
        assign    origin.valid  = to.valid;
        assign    origin.ready  = to.ready;
    end 
end 
endgenerate


endmodule