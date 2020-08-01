/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018-4-17 11:13:59
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module data_c_to_axis_full (
    data_inf_c.slaver      data_in_inf,
    axi_stream_inf.master  axis_out
);


assign {axis_out.axis_tuser,axis_out.axis_tkeep,axis_out.axis_tlast,axis_out.axis_tdata} = data_in_inf.data;
assign  axis_out.axis_tvalid  = data_in_inf.valid;
assign  data_in_inf.ready = axis_out.axis_tready;

endmodule
