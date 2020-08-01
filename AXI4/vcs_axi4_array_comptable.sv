/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
created: ###### Wed Sep 11 13:34:14 CST 2019
madified:
***********************************************/
`timescale 1ns/1ps
`include "define_macro.sv"
module vcs_axi4_array_comptable #(
    `parameter_string   ORIGIN = "master",
    `parameter_string   TO     = "slaver",
    parameter   NUM    = 8
)(
    axi_inf         origin  [NUM-1:0],
    axi_inf         to      [NUM-1:0]
);

generate 
for(genvar KK=0;KK<NUM;KK++)begin 
vcs_axi4_comptable #(
    .ORIGIN (ORIGIN ),
    .TO     (TO     )
)vcs_axi4_comptable_inst(
/*  axi_inf */   .origin    (origin[KK] ),
/*  axi_inf */   .to        (to[KK]     )
);
end 
endgenerate


endmodule