/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018-4-18 10:24:04
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_to_lite_rd #(
    parameter DUMMY = 8
)(
    axi_stream_inf.slaver   axis_in,
    axi_stream_inf.master   rd_rel_axis,
    axi_lite_inf.master_rd  lite
);


axi_stream_inf #(axis_in.DSIZE)   cm_tb_m (axis_in.aclk,axis_in.aresetn,axis_in.aclken);

logic [31:0]        addr;
logic               out_valid;

parse_big_field_table_A2 #(
    .DSIZE         (axis_in.DSIZE   ),
    .FIELD_LEN     (DUMMY           )     //MAX 16*8
)parse_big_field_table_A2_ins(
/*  input                       */     .enable      (1'b1           ),
/*  output[0:DSIZE*FIELD_LEN-1] */     .value       (addr           ),
/*  output logic                */     .out_valid   (out_valid      ),
/*  axi_stream_inf.slaver       */     .cm_tb_s     (axis_in        ),
/*  axi_stream_inf.master       */     .cm_tb_m     (cm_tb_m        ),
/*  axi_stream_inf.mirror       */     .cm_mirror   (axis_in        )
);

assign cm_tb_m.axis_tready  = 1'b1;

data_inf_c #(1) trigger_ar_inf (axis_in.aclk,axis_in.aresetn);
data_inf_c #(32) trigger_r_inf (axis_in.aclk,axis_in.aresetn);

trigger_data_inf_c #(
    .DSIZE  (1  )
)trigger_data_inf_c_ar_inst(
/*  input             */  .trigger          (out_valid          ),
/*  input [DSIZE-1:0] */  .data             (1'b0),
/*  data_inf_c.master */  .trigger_inf      (trigger_ar_inf     )
);

trigger_data_inf_c #(
    .DSIZE  (32  )
)trigger_data_inf_c_r_inst(
/*  input             */  .trigger          (lite.axi_rvalid && lite.axi_rready ),
/*  input [DSIZE-1:0] */  .data             (lite.axi_rdata     ),
/*  data_inf_c.master */  .trigger_inf      (trigger_r_inf      )
);


assign lite.axi_arvalid    =    trigger_ar_inf.valid;
assign lite.axi_araddr     =    addr;
assign lite.axi_arlock     =    1'b0;

assign lite.axi_rready     = 1'b1;


gen_big_field_table #(
    .MASTER_MODE    ("ON"               ),
    .DSIZE          (rd_rel_axis.DSIZE  ),
    .FIELD_LEN      (DUMMY              )     //MAX 16*8
)gen_big_field_table_inst(
/*  input                       */     .enable      (trigger_r_inf.valid    ),
/*  input [DSIZE*FIELD_LEN-1:0] */     .value       (trigger_r_inf.data     ),
/*  axi_stream_inf.master       */     .cm_tb       (rd_rel_axis            )
);

assign trigger_r_inf.ready  = rd_rel_axis.axis_tvalid;
assign trigger_ar_inf.ready = lite.axi_arvalid;

endmodule
