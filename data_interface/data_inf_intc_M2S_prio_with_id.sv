/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
    build from data_inf_interconnect_M2S_noaddr
creaded: 2017/3/30 
madified:
***********************************************/
`timescale 1ns/1ps
module data_inf_intc_M2S_prio_with_id #(
    parameter   NUM   = 8,
    parameter   IDSIZE= 4,
    parameter   PRIO = "OFF",
    parameter   NSIZE =  $clog2(NUM)
)(
    input               clock,
    input               rst_n,
    input [IDSIZE-1:0]  sid [NUM-1:0],
    output[IDSIZE-1:0]  mid,
    data_inf.slaver     s00 [NUM-1:0],
    data_inf.master     m00
);

data_inf #(s00[0].DSIZE+IDSIZE)    id_s00 [NUM-1:0]    ();
data_inf #(m00.DSIZE+IDSIZE)       id_m00              ();

genvar i;

generate
for(i=0;i<NUM;i++)begin
assign id_s00[i].data   = {sid[i],s00[i].data};
assign id_s00[i].valid  = s00[i].valid;
assign s00[i].ready     = id_s00[i].ready;
end
endgenerate

assign {mid,m00.data}    = id_m00.data;
assign m00.valid         = id_m00.valid;
assign id_m00.ready      = m00.ready;


data_inf_intc_M2S_prio #(
    .NUM    (NUM    ),
    .PRIO   (PRIO   )
)data_inf_interconnect_M2S_inst(
/*  input           */ .clock           (clock      ),
/*  input           */ .rst_n           (rst_n      ),
/*  data_inf.slaver */ .s00             (id_s00     ),//[NUM-1:0]   ,
/*  data_inf.master */ .m00             (id_m00     )
);

endmodule
