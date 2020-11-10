/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
created: xxxx.xx.xx
madified:
***********************************************/
`timescale 1ns/1ps

module axis_vector_slaver_empty #(
    parameter  NUM = 8
)(
    axi_stream_inf.slaver   slaver_vector [NUM-1:0]
);

//==========================================================================
//-------- define ----------------------------------------------------------


//==========================================================================
//-------- instance --------------------------------------------------------

//==========================================================================
//-------- expression ------------------------------------------------------
generate
for(genvar KK0=0;KK0 < NUM;KK0++)begin
    axis_slaver_empty axis_slaver_empty_inst(
    /* axi_stream_inf.slaver */.slaver (slaver_vector[ KK0] )
    );end
endgenerate

endmodule
