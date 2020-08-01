/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/6/13 
madified:
***********************************************/
`timescale 1ns/1ps
module axis_slaver_vector_empty #(
    parameter   NUM = 4
)(
    axi_stream_inf.slaver       slaver [NUM-1:0]
);

genvar KK;
generate
for(KK=0;KK<NUM;KK++)begin
axis_slaver_empty axis_slaver_empty_inst(
/*  axi_stream_inf.slaver  */   .slaver (slaver[KK] )
);
end
endgenerate

endmodule
