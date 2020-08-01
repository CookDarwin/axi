/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/8/14 
madified:
***********************************************/
`timescale 1ns/1ps
(* data_inf_c = "true" *)
module data_inf_c_pipe_condition (
    input                 and_condition,
    (* data_up = "true" *)
    data_inf_c.slaver     indata,
    (* data_down = "true" *)
    data_inf_c.master     outdata
);


data_inf_c #(indata.DSIZE) post_indata (indata.clock,indata.rst_n);

assign post_indata.data     = indata.data;
assign post_indata.valid    = indata.valid && and_condition;
assign indata.ready         = post_indata.ready;

data_connect_pipe_inf data_connect_pipe_inf(
/*  data_inf_c.slaver  */   .indata         (post_indata),
/*  data_inf_c.master  */   .outdata        (outdata    )
);

endmodule
