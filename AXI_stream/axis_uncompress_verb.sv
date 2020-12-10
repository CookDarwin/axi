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

module axis_uncompress_verb #(
    parameter  ASIZE = 8,
    parameter  LSIZE = 8,
    parameter  STEP  = 1
)(
    axi_stream_inf.slaver   axis_zip,
    axi_stream_inf.master   axis_unzip
);

//==========================================================================
//-------- define ----------------------------------------------------------
logic [32-1:0]  cc_length ;
logic [32-1:0]  cc_start ;

//==========================================================================
//-------- instance --------------------------------------------------------
gen_origin_axis_A2 #(
    .MODE ("RANGE" )
)gen_origin_axis_A2_inst(
/* input                 */.enable   (axis_zip.axis_tvalid ),
/* output                */.ready    (axis_zip.axis_tready ),
/* input                 */.length   (cc_length            ),
/* input                 */.start    (cc_start             ),
/* axi_stream_inf.master */.axis_out (axis_unzip           )
);
//==========================================================================
//-------- expression ------------------------------------------------------
initial begin
    assert( axis_zip.DSIZE==( ASIZE+LSIZE))else begin
         $error(" axis_zip.DSIZE<%0d> != (param.ASIZE<%0d>+param.LSIZE<%0d>)",axis_zip.DSIZE,ASIZE,LSIZE);
         $stop;
    end
    assert( axis_unzip.DSIZE==ASIZE)else begin
         $error("axis_unzip.DSIZE<%0d> != param.ASIZE<%0d>",axis_unzip.DSIZE,ASIZE);
         $stop;
    end
end

assign  cc_length = ( axis_zip.axis_tdata[ LSIZE-1:0]+1'b1);
assign  cc_start = axis_zip.axis_tdata[ ASIZE+LSIZE-1:LSIZE];

endmodule
