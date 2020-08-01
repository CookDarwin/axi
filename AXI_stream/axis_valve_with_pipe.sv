/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/10/11 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_valve_with_pipe #(
    parameter MODE = "BOTH"
)(
    input                      button,          //[1] OPEN ; [0] CLOSE
    (* up_stream = "true" *)
    axi_stream_inf.slaver      axis_in,
    (* down_stream = "true" *)
    axi_stream_inf.master      axis_out
);

axi_stream_inf #(
   .DSIZE(axis_out.DSIZE)
)post_axis_in(
   .aclk        (axis_out.aclk       ),
   .aresetn     (axis_out.aresetn    ),
   .aclken      (axis_out.aclken     )
);

axi_stream_inf #(
   .DSIZE(axis_out.DSIZE)
)pre_axis_out(
   .aclk        (axis_out.aclk       ),
   .aresetn     (axis_out.aresetn    ),
   .aclken      (axis_out.aclken     )
);

generate
if(MODE=="BOTH" || MODE=="IN")
    axis_connect_pipe in_axis_connect_pipe_inst(
    /* axi_stream_inf.slaver   */   .axis_in        (axis_in            ),
    /* axi_stream_inf.master   */   .axis_out       (post_axis_in       )
    );
else begin
    axis_direct axis_direct_in_inst(
    /*  axi_stream_inf.slaver */  .slaver   (axis_in        ),
    /*  axi_stream_inf.master */  .master   (post_axis_in   )
    );
end
endgenerate


assign pre_axis_out.axis_tdata    = post_axis_in.axis_tdata;
assign pre_axis_out.axis_tlast    = post_axis_in.axis_tlast && button;
assign pre_axis_out.axis_tvalid   = post_axis_in.axis_tvalid && button;
assign pre_axis_out.axis_tkeep    = post_axis_in.axis_tkeep;
assign pre_axis_out.axis_tuser    = post_axis_in.axis_tuser;
assign post_axis_in.axis_tready   = pre_axis_out.axis_tready && button;

generate
if(MODE=="BOTH" || MODE=="OUT")begin
    axis_connect_pipe out_axis_connect_pipe_inst(
    /* axi_stream_inf.slaver   */   .axis_in        (pre_axis_out   ),
    /* axi_stream_inf.master   */   .axis_out       (axis_out       )
    );
end else begin
    axis_direct axis_direct_out_inst(
    /*  axi_stream_inf.slaver */  .slaver   (pre_axis_out   ),
    /*  axi_stream_inf.master */  .master   (axis_out       )
    );
end
endgenerate


endmodule
