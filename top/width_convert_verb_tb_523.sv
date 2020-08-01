/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/5/23 
madified:
***********************************************/
`timescale 1ns/1ps
import AxiBfmPkg::*;
module width_convert_verb_tb_523;

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(148.5     	)
)clock_rst_pixel(
	.clock			(pclk   	),
	.rst_x			(prst_n  	)
);


axi_stream_inf #(8)axis_in(pclk,prst_n,1'b1);
axi_stream_inf #(16)axis_out(pclk,prst_n,1'b1);

AxiStreamMasterBfm_c #(axis_in.DSIZE) axis_master_bfm   = new(axis_in   );
AxiStreamSlaverBfm_c #(axis_out.DSIZE) axis_slaver_bfm  = new(axis_out  );

width_convert_verb #(
    .ISIZE      (axis_in.DSIZE),
    .OSIZE      (axis_out.DSIZE)
)width_convert_inst(
/*  input                   */  .clock      (pclk   	),
/*  input                   */  .rst_n      (prst_n  	),
/*  input [ISIZE-1:0]       */  .wr_data    (axis_in.axis_tdata ),
/*  input                   */  .wr_vld     (axis_in.axis_tvalid),
/*  output logic            */  .wr_ready   (axis_in.axis_tready),
/*  input                   */  .wr_last    (axis_in.axis_tlast ),
/*  output logic[OSIZE-1:0] */  .rd_data    (axis_out.axis_tdata ),
/*  output logic            */  .rd_vld     (axis_out.axis_tvalid),
/*  input                   */  .rd_ready   (axis_out.axis_tready),
/*  output logic            */  .rd_last    (axis_out.axis_tlast )
);



initial begin
    repeat(100)
        axis_slaver_bfm.get_data(50,0);
end

logic [axis_in.DSIZE-1:0]  ds_data [$];
logic [axis_out.DSIZE-1:0]  ok_data [$];

initial begin
    ds_data = {0,1,2,3,4,5,6,7};
    ok_data = {>>{ds_data}};
    repeat(100)
        @(posedge pclk);
    repeat(40)
        // axis_master_bfm.gen_axi_stream(1,100,ds_data);
        axis_master_bfm.gen_axi_stream(($urandom_range(1,0)*11+1),50,ds_data);
end

endmodule
