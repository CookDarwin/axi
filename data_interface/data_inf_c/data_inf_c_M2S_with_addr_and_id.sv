/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/8/11 
madified:
***********************************************/
`timescale 1ns/1ps
module data_inf_c_M2S_with_addr_and_id #(
    parameter   NUM   = 8,
    parameter   IDSIZE= 4,
    parameter   NSIZE =  $clog2(NUM)
)(
    input [NSIZE-1:0]       addr,
    input                   addr_vld,
    output[NSIZE-1:0]       curr_addr,
    input [IDSIZE-1:0]      sid [NUM-1:0],
    output[IDSIZE-1:0]      mid,
    data_inf_c.slaver       s00 [NUM-1:0],
    data_inf_c.master       m00
);

logic                clock;
logic                rst_n;

assign clock    = m00.clock;
assign rst_n    = m00.rst_n;

data_inf #(m00.DSIZE) m00_nc ();
data_inf #(m00.DSIZE) s00_nc[NUM-1:0] ();

genvar KK;
generate
for(KK=0;KK<NUM;KK++)begin
data_inf_B2A data_inf_B2A_inst(
/*  data_inf_c.slaver  */   .slaver (s00[KK]    ),
/*  data_inf.master    */   .master (s00_nc[KK] )
);
end
endgenerate


data_inf_intc_M2S_force_addr_with_id #(
    .NUM        (NUM     ),
    .IDSIZE     (IDSIZE  )
)data_inf_intc_M2S_force_addr_with_id_inst(
/*  input              */  .clock       (clock      ),
/*  input              */  .rst_n       (rst_n      ),
/*  input [NSIZE-1:0]  */  .addr        (addr       ),
/*  input              */  .addr_vld    (addr_vld   ),
/*  output [NSIZE-1:0]  */ .curr_addr   (curr_addr  ),
/*  input [IDSIZE-1:0] */  .sid         (sid        ),//[NUM-1:0],
/*  output[IDSIZE-1:0] */  .mid         (mid        ),
/*  data_inf.slaver    */  .s00         (s00_nc     ),//[NUM-1:0],
/*  data_inf.master    */  .m00         (m00_nc     )
);

data_inf_A2B data_inf_A2B_inst(
/*  data_inf.slaver   */  .slaver   (m00_nc         ),
/*  data_inf_c.master */  .master   (m00            )
);

endmodule
