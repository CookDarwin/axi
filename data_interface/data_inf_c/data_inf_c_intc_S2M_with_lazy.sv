/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    simple slaver to multi master with lazy data
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018/11/17 
madified:
***********************************************/
`timescale 1ns/1ps
module data_inf_c_intc_S2M_with_lazy #(
    parameter   NUM   = 8,
    parameter   NSIZE =  $clog2(NUM),
    parameter   LAZISE= 1
)(
    input [NSIZE-1:0]       addr,       // sync to s00.valid
    output[LAZISE-1:0]      m00_lazy_data [NUM-1:0],
    input [LAZISE-1:0]      s00_lazy_data ,
    data_inf_c.master       m00 [NUM-1:0],
    data_inf_c.slaver       s00
);

data_inf_c #(s00.DSIZE+LAZISE) bind_m00 [NUM-1:0]  (s00.clock,s00.rst_n);
data_inf_c #(s00.DSIZE+LAZISE) bind_s00            (s00.clock,s00.rst_n);

data_inf_c_intc_S2M #(
    .NUM        (NUM    )
)data_inf_c_intc_S2M_inst(
/*  input [NSIZE-1:0]   */    .addr     (addr       ),       // sync to s00.valid
/*  data_inf_c.master   */    .m00      (bind_m00   ),//[NUM-1:0],
/*  data_inf_c.slaver   */    .s00      (bind_s00   )
);

genvar KK;
generate
for(KK=0;KK<NUM;KK++)begin
assign  {m00_lazy_data[KK],m00[KK].data}  = bind_m00[KK].data   ;
assign  m00[KK].valid                     = bind_m00[KK].valid  ;
assign  bind_m00[KK].ready                = m00[KK].ready       ;
end
endgenerate

assign  bind_s00.data     = {s00_lazy_data,s00.data}   ;  
assign  bind_s00.valid    = s00.valid                  ;  
assign  s00.ready         = bind_s00.ready             ;  

endmodule
