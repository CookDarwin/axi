/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.1 2018-4-19 12:09:50
    use axi_streams_combin_A1
creaded: 2017/3/31 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_append #(
    parameter   MODE  = "BOTH",
    parameter   DSIZE       = 8,
    parameter   HEAD_FIELD_LEN     = 16*8,     //MAX 16*8
    parameter   HEAD_FIELD_NAME    = "HEAD Filed",
    parameter   END_FIELD_LEN     = 16*8,     //MAX 16*8
    parameter   END_FIELD_NAME    = "END Filed"
)(
    input [HEAD_FIELD_LEN*DSIZE-1:0]      head_value,
    input [END_FIELD_LEN*DSIZE-1:0]       end_value,
    (* up_stream = "true" *)
    axi_stream_inf.slaver                 origin_in,
    (* down_stream = "true" *)
    axi_stream_inf.master                 append_out
);


axi_stream_inf #(.DSIZE(origin_in.DSIZE)) head_inf      (.aclk(origin_in.aclk),.aresetn(origin_in.aresetn),.aclken(origin_in.aclken));
axi_stream_inf #(.DSIZE(origin_in.DSIZE)) end_inf      (.aclk(origin_in.aclk),.aresetn(origin_in.aresetn),.aclken(origin_in.aclken));

generate
if(MODE=="BOTH" || MODE=="HEAD")begin
gen_big_field_table #(
    .MASTER_MODE    ("ON"               ),
    .DSIZE          (DSIZE              ),
    .FIELD_LEN      (HEAD_FIELD_LEN     ),     //MAX 16*8
    .FIELD_NAME     (HEAD_FIELD_NAME    )
)gen_big_field_table_head(
/*  input                       */  .enable     (1'b1           ),
/*  input [DSIZE*FIELD_LEN-1:0] */  .value      (head_value     ),
/*  axi_stream_inf.master       */  .cm_tb      (head_inf       )
);
end
endgenerate

generate
if(MODE=="BOTH" || MODE=="END")begin
gen_big_field_table #(
    .MASTER_MODE    ("ON"               ),
    .DSIZE          (DSIZE              ),
    .FIELD_LEN      (END_FIELD_LEN      ),     //MAX 16*8
    .FIELD_NAME     (END_FIELD_NAME     )
)gen_big_field_table_end(
/*  input                       */  .enable     (1'b1           ),
/*  input [DSIZE*FIELD_LEN-1:0] */  .value      (end_value      ),
/*  axi_stream_inf.master       */  .cm_tb      (end_inf        )
);
end
endgenerate

// axi_streams_combin #(
axi_streams_combin_A1 #(
    .MODE                   (MODE       ),      //HEAD END
    .CUT_OR_COMBIN_BODY     ("OFF"      ) //ON OFF
    // .DSIZE                  (DSIZE      )
// )axi_streams_combin_inst(
)axi_streams_combin_A1_inst(
/* input [15:0]          */ .new_body_len       (16'hFFFF   ),
/* input                 */ .trigger_signal     (1'b1       ),
/* axi_stream_inf.slaver */ .head_inf           (head_inf   ),
/* axi_stream_inf.slaver */ .body_inf           (origin_in  ),
/* axi_stream_inf.slaver */ .end_inf            (end_inf    ),
/* axi_stream_inf.master */ .m00                (append_out )
);

endmodule
