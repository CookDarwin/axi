/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
    build from data_inf_interconnect_M2S_noaddr
creaded: 2017/7/27 
madified:
***********************************************/
`timescale 1ns/1ps
module data_inf_c_interconnect_M2S #(
    parameter   NUM   = 8,
    parameter   NSIZE =  $clog2(NUM),       //(* show = "false" *)
    parameter   PRIO  = "OFF"
)(
    data_inf_c.slaver  s00 [NUM-1:0],
    data_inf_c.master  m00
);

data_inf #(m00.DSIZE) pre_m00 ();
data_inf #(m00.DSIZE) post_s00 [NUM-1:0] ();

genvar CC;
generate
for(CC=0;CC<NUM;CC++)
data_inf_B2A data_inf_B2A_inst_intc_with_id(
/*    data_inf_c.slaver  */   .slaver   (s00[CC]        ),
/*    data_inf.master    */   .master   (post_s00[CC]   )
);
endgenerate


data_inf_intc_M2S_prio #(
    .NUM    (NUM      ),
    .PRIO   ("ON"  )
)M2S_noaddr_inst(
/*  input           */ .clock       (m00.clock  ),
/*  input           */ .rst_n       (m00.rst_n  ),
/*  data_inf.slaver */ .s00         (post_s00   ),//[NUM-1:0],
/*  data_inf.master */ .m00         (pre_m00    )
);

data_inf_A2B data_inf_A2B_inst_intc_with_id(
/*  data_inf.slaver   */  .slaver       (pre_m00),
/*  data_inf_c.master */  .master       (m00    )
);

endmodule
