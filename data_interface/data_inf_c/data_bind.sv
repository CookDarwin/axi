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
module data_bind #(
    parameter NUM = 2
)(

    data_inf_c.slaver     data_in [NUM-1:0],
    data_inf_c.master     data_out    //[data_NUM]...[data_0]
);

logic               clock;
logic               rst_n;

assign  clock   = data_out.clock;
assign  rst_n   = data_out.rst_n;

data_inf_c #(data_in[0].DSIZE) data_in_post [NUM-1:0] (clock,rst_n);
data_inf_c #(data_out.DSIZE)   data_in_post_mix(clock,rst_n);
data_inf_c #(data_out.DSIZE)   data_out_pre(clock,rst_n);

logic [NUM-1:0] button;
logic [data_in[0].DSIZE-1:0]    data [NUM-1:0];

genvar CC;
generate
for(CC=0;CC<NUM;CC++)begin
// data_connect_pipe_inf data_connect_pipe_inf_inst(
// /*  data_inf_c.slaver  */   .indata       (data_in[CC]        ),
// /*  data_inf_c.master  */   .outdata      (data_in_post[CC]   )
// );
data_c_pipe_inf data_c_pipe_inf_inst(
/*  data_inf_c.slaver  */   .slaver         (data_in[CC]            ),
/*  data_inf_c.master  */   .master         (data_in_post[CC]       )
);
assign button[CC] = data_in_post[CC].valid;
assign data_in_post[CC].ready = data_in_post_mix.ready;
assign data[CC] =  data_in_post[CC].data;
end
endgenerate

assign data_in_post_mix.valid   = &button;
assign data_in_post_mix.data    = {>>{data}};





data_valve data_valve_inst(
/*  input                */   .button     (&button            ),          //[1] OPEN ; [0] CLOSE
/*  data_inf_c.slaver    */   .data_in    (data_in_post_mix   ),
/*  data_inf_c.master    */   .data_out   (data_out_pre       )
);

// data_connect_pipe_inf out_inst(
// /*  data_inf_c.slaver  */   .indata       (data_out_pre       ),
// /*  data_inf_c.master  */   .outdata      (data_out           )
// );

data_c_pipe_inf out_inst(
/*  data_inf_c.slaver  */   .slaver         (data_out_pre       ),
/*  data_inf_c.master  */   .master         (data_out           )
);

endmodule
