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

module axis_vector_master_empty #(
    parameter  NUM = 8
)(
    axi_stream_inf.master   master_vector [NUM-1:0]
);

//==========================================================================
//-------- define ----------------------------------------------------------


//==========================================================================
//-------- instance --------------------------------------------------------

//==========================================================================
//-------- expression ------------------------------------------------------
generate
for(genvar KK0=0;KK0 < NUM;KK0++)begin
    axis_master_empty axis_master_empty_inst(
    /* axi_stream_inf.master */.master (master_vector[ KK0] )
    );end
endgenerate

endmodule
