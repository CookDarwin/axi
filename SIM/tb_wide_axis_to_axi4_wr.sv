/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: ###### Wed May 6 13:44:14 CST 2020
madified:
***********************************************/
`timescale 1ns/1ps
module tb_wide_axis_to_axi4_wr;

import AxiBfmPkg::*;
localparam  DSIZE = 64;
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

axi_stream_inf #(DSIZE) axis_in_inf (clock,rst_n,1'b1);

axi_inf #(
    .IDSIZE    (1           ),
    .ASIZE     (8           ),
    .LSIZE     (8           ),
    .DSIZE     (DSIZE       ),
	.MODE 	   ("BOTH"      )
)axi4_out(
    .axi_aclk       (clock),
    .axi_aresetn    (rst_n)
);

wide_axis_to_axi4_wr wide_axis_to_axi4_wr_inst(
/* input logic[31:0]     */ .addr           (0              ),
/* input logic[31:0]     */ .max_length     (128            ),
/* axi_stream_inf.slaver */ .axis_in        (axis_in_inf    ),
/* axi_inf.master_wr     */ .axi_wr			(axi4_out		)
);

AxiStreamMasterBfm_c #(DSIZE) AxisMasterBfm = new(axis_in_inf);

Axi4SlaverBfm_c #(
    .IDSIZE    (axi4_out.IDSIZE   ),
    .ASIZE     (axi4_out.ASIZE    ),
    .DSIZE     (axi4_out.DSIZE    ),
    .LSIZE     (axi4_out.LSIZE    ),
    .MSG       ("ON"              )
) Axi4SlaverBfm;

logic [DSIZE-1:0]     wdata_queue     [$];

initial begin
    wait(rst_n);
    wdata_queue = {1,2,3,4,5,6,7,8,9,10};
    // wdata_queue   = {>>{64'd1,64'd2,64'd3,64'd4}};    
    #(100us);
    repeat(100) begin
        AxisMasterBfm.gen_axi_stream(523,100,wdata_queue);
    end
end

initial begin 
	wait(rst_n);
    Axi4SlaverBfm = new(axi4_out);
	repeat(100) begin 
		Axi4SlaverBfm.run(50,50);
	end
end

endmodule 