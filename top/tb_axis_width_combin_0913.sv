/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/9/13 
madified:
***********************************************/
`timescale 1ns/1ps
module tb_axis_width_combin_0913;
import AxiBfmPkg::*;
logic   pclk;
logic   prst_n;


clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(50			),
	.FreqM			(148.5     	)
)clock_rst_pixel(
	.clock			(pclk   	),
	.rst_x			(prst_n  	)
);

localparam  DSIZE = 8,
            NDSIZE = DSIZE * 3;

axi_stream_inf #(DSIZE) slim_inf (pclk,prst_n,1'b1);
axi_stream_inf #(NDSIZE) wide_inf (pclk,prst_n,1'b1);


AxiStreamMasterBfm_c #(DSIZE,"OFF") MasterBfm = new(slim_inf);
AxiStreamSlaverBfm_c #(NDSIZE)      SlaverBfm = new(wide_inf);

axis_width_combin axis_width_combin_inst(
/*  axi_stream_inf.slaver  */ .slim_axis        (slim_inf   ),
/*  axi_stream_inf.master  */ .wide_axis        (wide_inf   )
);

initial begin
    forever begin
        SlaverBfm.get_data(100,0);
    end
end

logic [DSIZE-1:0]   data [$];

initial begin
    data   = {>>{8'd1,8'd2,8'd3,8'd4}};
    forever
        MasterBfm.gen_axi_stream(10,100,data);
end

endmodule
