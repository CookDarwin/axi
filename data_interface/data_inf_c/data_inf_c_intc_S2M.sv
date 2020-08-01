/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    simple slaver to multi master
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/8/3 
madified:
***********************************************/
`timescale 1ns/1ps
module data_inf_c_intc_S2M #(
    parameter   NUM   = 8,
    parameter   NSIZE =  $clog2(NUM)
)(
    input [NSIZE-1:0]       addr,       // sync to s00.valid
    data_inf_c.master       m00 [NUM-1:0],
    data_inf_c.slaver       s00
);

data_inf #(s00.DSIZE) s00_nc   ();
data_inf #(s00.DSIZE) m00_nc [NUM-1:0]  ();

genvar KK;
generate
for(KK=0;KK<NUM;KK++)begin
data_inf_A2B data_inf_A2B_inst_intc_S2M(
/*  data_inf.slaver   */  .slaver   (m00_nc[KK]     ),
/*  data_inf_c.master */  .master   (m00[KK]        )
);
end
endgenerate

data_inf_B2A data_inf_B2A_inst_intc_S2M(
/*  data_inf_c.slaver */  .slaver       (s00        ),
/*  data_inf.master   */  .master       (s00_nc     )
);

// data_pipe_interconnect_S2M #(
//     .DSIZE  (s00.DSIZE  ),
//     .NUM    (NUM    )
// )data_pipe_interconnect_S2M_inst(
// /*  input             */ .clock     (s00.clock  ),
// /*  input             */ .rst_n     (s00.rst_n  ),
// /*  input             */ .clk_en    (1'b1       ),
// /*  input [NSIZE-1:0] */ .addr      (addr       ),       // sync to s00.valid
// /*  data_inf.master   */ .m00       (m00_nc     ),//[NUM-1:0],
// /*  data_inf.slaver   */ .s00       (s00_nc     )
// );
generate
if(NUM>1)begin
data_pipe_interconnect_S2M_verb #(
    .NUM        (NUM)
)data_pipe_interconnect_S2M_verb_inst(
/*  input             */ .clock     (s00.clock  ),
/*  input             */ .rst_n     (s00.rst_n  ),
/*  input             */ .clk_en    (1'b1       ),
/*  input [NSIZE-1:0] */ .addr      (addr       ),       // sync to s00.valid
/*  data_inf.master   */ .m00       (m00_nc     ),//[NUM-1:0],
/*  data_inf.slaver   */ .s00       (s00_nc     )
);
end else begin
assign m00_nc[0].valid  = s00_nc.valid;
assign m00_nc[0].data   = s00_nc.data;
assign s00_nc.ready     = m00_nc[0].ready;
end
endgenerate

endmodule
