/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/7/27 
madified:
***********************************************/
`timescale 1ns/1ps
(* data_inf_c = "true" *)
module data_condition_valve #(
    parameter H     = 0,
    parameter L     = 0
)(
    input                       condition_button,          //[1] OPEN ; [0] CLOSE
    input [H:L]                 condition_data,
    (* data_up = "true" *)
    data_inf_c.slaver             data_in,
    (* data_down = "true" *)
    data_inf_c.master             data_out
);

logic               clock;
logic               rst_n;

assign  clock   = data_in.clock;
assign  rst_n   = data_in.rst_n;

data_inf_c #(data_in.DSIZE) data_in_post (clock,rst_n);
data_inf_c #(data_in.DSIZE) data_out_pre (clock,rst_n);

data_connect_pipe_inf data_connect_pipe_inf_inst1(
/*  data_inf_c.slaver  */   .indata       (data_in        ),
/*  data_inf_c.master  */   .outdata      (data_in_post   )
);

logic   button;
assign  button = (condition_button && data_in_post.data[H:L] == condition_data) || data_in_post.data[H:L] != condition_data;

data_valve data_valve_inst(
/*  input              */   .button     (button         ),          //[1] OPEN ; [0] CLOSE
/*  data_inf_c.slaver    */   .data_in    (data_in_post   ),
/*  data_inf_c.master    */   .data_out   (data_out_pre   )
);

data_connect_pipe_inf data_connect_pipe_inf_inst2(
/*  data_inf_c.slaver  */   .indata       (data_out_pre        ),
/*  data_inf_c.master  */   .outdata      (data_out            )
);

endmodule
