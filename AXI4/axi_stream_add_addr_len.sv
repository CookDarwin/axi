/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/1 
madified:
***********************************************/
`timescale 1ns/1ps
module axi_stream_add_addr_len (
    input [31:0]                addr,
    input [31:0]                length,
    axi_stream_inf.slaver       axis_in,
    axi_stream_inf.master       axis_out
);

localparam FIELD_LEN    = 64/axis_in.DSIZE + (64%axis_in.DSIZE != 0);

axi_stream_inf #(.DSIZE(axis_in.DSIZE)) addr_len_inf     (.aclk(axis_in.aclk),.aresetn(axis_in.aresetn),.aclken(axis_in.aclken));
// axi_stream_inf #(.DSIZE(axis_in.DSIZE)) mix_inf          (.aclk(axis_in.aclk),.aresetn(axis_in.aresetn),.aclken(axis_in.aclken));
axi_stream_inf #(.DSIZE(axis_in.DSIZE)) end_inf          (.aclk(axis_in.aclk),.aresetn(axis_in.aresetn),.aclken(axis_in.aclken));


gen_big_field_table #(
    .MASTER_MODE    ("OFF"  ),
    .DSIZE          (axis_in.DSIZE        ),
    .FIELD_LEN      (FIELD_LEN            ),     //MAX 16*8
    .FIELD_NAME     ("Big Filed"          )
)gen_big_field_table_inst(
/*    input                          */  .enable        (1'b1           ),
/*    input [DSIZE*FIELD_LEN-1:0]    */  .value         ({addr,length}  ),
/*    axi_stream_inf.master          */  .cm_tb         (addr_len_inf   )
);

axi_streams_combin #(
  .MODE                 ("HEAD"     ),      //HEAD END
  .CUT_OR_COMBIN_BODY   ("OFF"      ), //ON OFF
  .DSIZE                (axis_in.DSIZE  )
)axi_streams_combin_inst(
/*   input [15:0]           */    .new_body_len     (length[15:0]       ),
/*   input                  */    .trigger_signal   (1'b1               ),
/*   axi_stream_inf.slaver  */    .head_inf         (addr_len_inf       ),
/*   axi_stream_inf.slaver  */    .body_inf         (axis_in            ),
/*   axi_stream_inf.slaver  */    .end_inf          (end_inf            ),
/*   axi_stream_inf.master  */    .m00              (axis_out           )
);

endmodule
