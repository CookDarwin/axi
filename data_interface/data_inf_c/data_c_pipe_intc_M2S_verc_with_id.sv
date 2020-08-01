/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    multi slaver to simple master
author : Cook.Darwin
Version: VERA.0.0
    build from data_pipe_interconnect
Version: 2017/8/23 
    more effection
creaded: 2016/12/28 
madified:
***********************************************/
`timescale 1ns/1ps
`include "define_macro.sv"
module data_c_pipe_intc_M2S_verc_with_id #(
    `parameter_string   PRIO   = "BEST_ROBIN",   //BEST_ROBIN BEST_LAST ROBIN LAST WAIT_IDLE
    parameter   NUM    = 8,
    parameter   IDSIZE = 1
)(
    input [NUM-1:0]             last,             //ctrl prio
    input [IDSIZE-1:0]          sid [NUM-1:0],
    output[IDSIZE-1:0]          mid,
    data_inf_c.slaver           s00 [NUM-1:0],
    data_inf_c.master           m00
);

data_inf_c #(m00.DSIZE + IDSIZE ) m00_plus (m00.clock,m00.rst_n);
data_inf_c #(m00.DSIZE + IDSIZE ) s00_plus[NUM-1:0] (m00.clock,m00.rst_n);

genvar KK;
generate
for(KK=0;KK<NUM;KK++)begin
assign s00_plus[KK].data    = {sid[KK],s00[KK].data};
assign s00_plus[KK].valid   = s00[KK].valid;
assign s00[KK].ready        = s00_plus[KK].ready;
end
endgenerate

assign {mid,m00.data}   = m00_plus.data;
assign m00.valid        = m00_plus.valid;
assign m00_plus.ready   = m00.ready;

data_c_pipe_intc_M2S_verc #(
    .PRIO  (PRIO    ),   //BEST_ROBIN BEST_LAST ROBIN LAST WAIT_IDLE
    .NUM   (NUM     )
)data_c_pipe_intc_M2S_verc_inst(
/*  input [NUM-1:0]   */      .last     (last   ),             //ctrl prio
/*  data_inf_c.slaver */      .s00      (s00_plus   ),//[NUM-1:0],
/*  data_inf_c.master */      .m00      (m00_plus   )
);

endmodule
