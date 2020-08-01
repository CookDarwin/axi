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
module axis_full_to_data_c (
    axi_stream_inf.slaver  axis_in,
    data_inf_c.master      data_out_inf
);



assign  data_out_inf.data   = {axis_in.axis_tuser,axis_in.axis_tkeep,axis_in.axis_tlast,axis_in.axis_tdata};
assign  data_out_inf.valid  = axis_in.axis_tvalid;
assign  axis_in.axis_tready = data_out_inf.ready;



endmodule
