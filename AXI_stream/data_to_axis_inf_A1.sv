/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.1.0 2017/5/26 
    dont use fifo
creaded: 2017/3/29 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module data_to_axis_inf_A1 (
    input                   last_flag,
    data_inf_c.slaver       data_slaver,
    axi_stream_inf.master   axis_master
);


assign axis_master.axis_tvalid  = data_slaver.valid;
assign axis_master.axis_tdata   = data_slaver.data;
assign data_slaver.ready        = axis_master.axis_tready;
assign axis_master.axis_tlast   = last_flag;
assign axis_master.axis_tkeep   = '1;
assign axis_master.axis_tuser   = '0;

endmodule
