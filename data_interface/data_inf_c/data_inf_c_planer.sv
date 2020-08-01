/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.1 2018-3-22 16:48:16
    can set where pack_data at
creaded: 2017/8/3 
madified:
***********************************************/
`timescale 1ns/1ps
`include "define_macro.sv"
module data_inf_c_planer #(
    parameter LAT   = 3,
    parameter DSIZE = 8,
    `parameter_string HEAD  = "FALSE"
)(
    input [DSIZE-1:0]     pack_data,
    data_inf_c.slaver     slaver,
    data_inf_c.master     master        //{pack_data,slaver.data} or {slaver.data,pack_data} depen on HEAD
);


data_inf #(slaver.DSIZE) slaver_nc ();
data_inf #(master.DSIZE) master_nc ();

data_inf_A2B data_inf_A2B_planer_inst(
/*  data_inf.slaver   */  .slaver       (master_nc  ),
/*  data_inf_c.master */  .master       (master     )
);

data_inf_B2A data_inf_B2A_planer_inst(
/*  data_inf_c.slaver */  .slaver       (slaver     ),
/*  data_inf.master   */  .master       (slaver_nc  )
);

data_inf_planer_A1 #(
    .LAT    (LAT    ),
    .DSIZE  (DSIZE  ),
    .HEAD   (HEAD   )
)data_inf_planer_inst(
/*  input              */   .clock      (slaver.clock   ),
/*  input              */   .rst_n      (slaver.rst_n   ),
/*  input [DSIZE-1:0]  */   .pack_data  (pack_data  ),
/*  data_inf.slaver    */   .slaver     (slaver_nc  ),
/*  data_inf.master    */   .master     (master_nc  )        //{pack_data,slaver.data}
);

endmodule
