/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018-5-4 12:17:26
madified:
***********************************************/
`timescale 1ns/1ps
module tb_axis_bfm_0504;

import AxiBfmPkg::*;
localparam  DSIZE = 8;
logic   clock;
logic   rst_n;

int     stcnt,mtcnt;

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(100     	)
)clock_rst_pixel(
	.clock			(clock   	),
	.rst_x			(rst_n  	)
);

axi_stream_inf #(DSIZE) axis_slaver_inf (clock,rst_n,1'b1);
axi_stream_inf #(DSIZE) axis_master_inf (clock,rst_n,1'b1);

AxiStreamMasterBfm_c #(DSIZE) master_bfm  = new(axis_slaver_inf);
AxiStreamSlaverBfm_c #(DSIZE) slaver_bfm  = new(axis_master_inf);

axis_direct axis_direct_inst(
/*  axi_stream_inf.slaver  */ .slaver       (axis_slaver_inf    ),
/*  axi_stream_inf.master  */ .master       (axis_master_inf    )
);


initial begin
    repeat(1000)
        // slaver_bfm.get_data($urandom_range(10,100));
        slaver_bfm.get_data(100);
end

logic [7:0]     s00_data [$];

initial begin
    wait(rst_n);
    s00_data = {>>{8'h10,64'ha}};
    master_bfm.gen_axi_stream(0,100,s00_data);
end


assign  stcnt   = axis_slaver_inf.axis_tcnt;
assign  mtcnt   = axis_master_inf.axis_tcnt;

endmodule
