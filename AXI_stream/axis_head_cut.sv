/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018/2/2 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_head_cut #(
    parameter LEN = 1
)(
    (* up_stream = "true" *)
    axi_stream_inf.slaver      slaver,
    (* down_stream = "true" *)
    axi_stream_inf.master      master
);

initial begin
    assert(slaver.DSIZE == master.DSIZE)
    else begin
        $error("slaver DSIZE[%d] MUST EQL master DSIZE[%d]",slaver.DSIZE,master.DSIZE);
        $stop;
    end
end

// localparam DSIZE = slaver.DSIZE;

axi_stream_inf #(slaver.DSIZE) post_slaver (slaver.aclk,slaver.aresetn,slaver.aclken);
`include "define_macro.sv"
`VCS_AXIS_CPT(slaver,slaver,mirror,)
generate
if(LEN == 0)begin
axis_direct axis_direct_inst(
/*  axi_stream_inf.slaver */  .slaver   (slaver     ),
/*  axi_stream_inf.master */  .master   (master     )
);
end else if(LEN <=6) begin
parse_big_field_table_A2 #(
    .DSIZE          (slaver.DSIZE     ),
    .FIELD_LEN      (LEN       )     //MAX 16*8
)parse_big_field_table_A2_inst(
/*  input                         */   .enable      (1'b1),
/*  output[0:DSIZE*FIELD_LEN-1]   */   .value       (),
/*  output logic                  */   .out_valid   (),
/*  axi_stream_inf.slaver         */   .cm_tb_s     (slaver ),
/*  axi_stream_inf.master         */   .cm_tb_m     (master ),
/*  axi_stream_inf.mirror         */   .cm_mirror   (`slaver_vcs_cpt )
);
end else begin
axis_filter axis_filter_inst(
/*  input                  */  .button      (slaver.axis_tcnt > LEN - 1),          //[1] pass ; [0] filter
/*  axi_stream_inf.slaver  */  .axis_in     (slaver         ),
/*  axi_stream_inf.master  */  .axis_out    (post_slaver    )
);

axi_stream_cache axi_stream_cache_inst(
/*  axi_stream_inf.slaver  */ .axis_in      (post_slaver    ),
/*  axi_stream_inf.master  */ .axis_out     (master         )
);
end
endgenerate

endmodule
