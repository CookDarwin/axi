/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
    build from data_inf_interconnect_M2S_with_id_noaddr
creaded: 2017/8/3 
madified:
***********************************************/
`timescale 1ns/1ps
module data_inf_c_intc_M2S_with_id #(
    parameter   NUM   = 8,
    parameter   IDSIZE= 4,
    parameter   PRIO  = "ON",
    parameter   NSIZE =  $clog2(NUM)
)(
    input [IDSIZE-1:0]  sid [NUM-1:0],
    output[IDSIZE-1:0]  mid,
    data_inf_c.slaver     s00 [NUM-1:0],
    data_inf_c.master     m00
);

data_inf #(m00.DSIZE) s00_nc [NUM-1:0]  ();
data_inf #(m00.DSIZE) m00_nc   ();

genvar KK;
generate
for(KK=0;KK<NUM;KK++)begin
data_inf_B2A data_inf_B2A_inst_intc_with_id(
/*  data_inf_c.slaver */  .slaver   (s00[KK]    ),
/*  data_inf.master   */  .master   (s00_nc[KK] )
);
end
endgenerate

generate
if(NSIZE>0)begin
data_inf_intc_M2S_prio_with_id #(
    .NUM        (NUM      ),
    .IDSIZE     (IDSIZE   ),
    .PRIO       (PRIO   )
)with_id_noaddr_inst(
/*  input              */   .clock          (m00.clock  ),
/*  input              */   .rst_n          (m00.rst_n  ),
/*  input [IDSIZE-1:0] */   .sid            (sid        ),//[NUM-1:0],
/*  output[IDSIZE-1:0] */   .mid            (mid        ),
/*  data_inf.slaver    */   .s00            (s00_nc     ),//[NUM-1:0],
/*  data_inf.master    */   .m00            (m00_nc     )
);
end else begin

assign mid   = sid[0];
assign m00_nc.valid         = s00_nc[0].valid;
assign m00_nc.data          = s00_nc[0].data;
assign s00_nc[0].ready      = m00_nc.ready;

end
endgenerate

data_inf_A2B data_inf_A2B_inst_intc_with_id(
/*  data_inf.slaver   */  .slaver       (m00_nc ),
/*  data_inf_c.master */  .master       (m00    )
);

endmodule
