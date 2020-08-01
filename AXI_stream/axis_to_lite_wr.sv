/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018-4-18 10:01:29
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_to_lite_wr #(
    parameter DUMMY = 8
)(
    axi_stream_inf.slaver   axis_in,
    axi_lite_inf.master_wr  lite
);


axi_stream_inf #(axis_in.DSIZE)   cm_tb_m (axis_in.aclk,axis_in.aresetn,axis_in.aclken);

logic [31:0]        addr,data;
logic               out_valid;

parse_big_field_table_A2 #(
    .DSIZE         (axis_in.DSIZE   ),
    .FIELD_LEN     (DUMMY           )     //MAX 16*8
)parse_big_field_table_A2_ins(
/*  input                       */     .enable      (1'b1           ),
/*  output[0:DSIZE*FIELD_LEN-1] */     .value       ({addr,data }   ),
/*  output logic                */     .out_valid   (out_valid      ),
/*  axi_stream_inf.slaver       */     .cm_tb_s     (axis_in        ),
/*  axi_stream_inf.master       */     .cm_tb_m     (cm_tb_m        ),
/*  axi_stream_inf.mirror       */     .cm_mirror   (axis_in        )
);

assign cm_tb_m.axis_tready  = 1'b1;

data_inf_c #(1) trigger_aw_inf (axis_in.aclk,axis_in.aresetn);
data_inf_c #(1) trigger_w_inf (axis_in.aclk,axis_in.aresetn);

trigger_data_inf_c #(
    .DSIZE  (1  )
)trigger_data_inf_c_aw_inst(
/*  input             */  .trigger          (/*cm_tb_m.axis_tvalid && cm_tb_m.axis_tready && cm_tb_m.axis_tlast*/out_valid),
/*  input [DSIZE-1:0] */  .data             (1'b0),
/*  data_inf_c.master */  .trigger_inf      (trigger_aw_inf     )
);

trigger_data_inf_c #(
    .DSIZE  (1  )
)trigger_data_inf_c_w_inst(
/*  input             */  .trigger          (cm_tb_m.axis_tvalid && cm_tb_m.axis_tready && cm_tb_m.axis_tlast),
/*  input [DSIZE-1:0] */  .data             (1'b0),
/*  data_inf_c.master */  .trigger_inf      (trigger_w_inf      )
);


assign lite.axi_awvalid    =    trigger_aw_inf.valid;
assign lite.axi_awaddr     =    addr;
assign lite.axi_awlock     =    1'b0;
assign lite.axi_wvalid     =    trigger_w_inf.valid;
assign lite.axi_wdata      =    data;
assign lite.axi_bready     =    1'b1;

assign trigger_aw_inf.ready = lite.axi_awvalid;
assign trigger_w_inf.ready  = lite.axi_wready;


endmodule
