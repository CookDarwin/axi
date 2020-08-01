/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.1.0
    add depth
creaded: 2017/10/11 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_slaver_pipe_A1 #(
    parameter DEPTH = 1
)(
    (* up_stream = "true" *)
    axi_stream_inf.slaver      axis_in,
    (* down_stream = "true" *)
    axi_stream_inf.master      axis_out
);

axi_stream_inf #(axis_in.DSIZE) list_in[DEPTH-1:0] (axis_in.aclk,axis_in.aresetn,axis_in.aclken);
axi_stream_inf #(axis_in.DSIZE) list_out[DEPTH-1:0] (axis_in.aclk,axis_in.aresetn,axis_in.aclken);
genvar KK;
generate
for(KK=0;KK<DEPTH;KK++)begin
axis_slaver_pipe axis_slaver_pipe_inst(
/*  axi_stream_inf.slaver  */    .axis_in       (list_in[KK]    ),
/*  axi_stream_inf.master  */    .axis_out      (list_out[KK]   )
);

if(KK==DEPTH-1)begin
    axis_direct axis_direct_inst(
    /*  axi_stream_inf.slaver */  .slaver   (list_out[DEPTH-1]  ),
    /*  axi_stream_inf.master */  .master   (axis_out           )
    );
end else begin
    axis_direct axis_direct_inst(
    /*  axi_stream_inf.slaver */  .slaver   (list_out[KK]       ),
    /*  axi_stream_inf.master */  .master   (list_in[KK+1]      )
    );
end

if(KK==0)begin
    axis_direct axis_direct_inst(
    /*  axi_stream_inf.slaver */  .slaver   (axis_in        ),
    /*  axi_stream_inf.master */  .master   (list_in[0]     )
    );
end
end
endgenerate

endmodule
