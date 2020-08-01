/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/16 
madified:
***********************************************/
`timescale 1ns/1ps
import AxiBfmPkg::*;
module odd_width_convert_tb_420;

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(148.5     	)
)clock_rst_pixel(
	.clock			(pclk   	),
	.rst_x			(prst_n  	)
);


axi_stream_inf #(16)axis_in(pclk,prst_n,1'b1);
axi_stream_inf #(24)axis_out(pclk,prst_n,1'b1);

AxiStreamMasterBfm_c #(axis_in.DSIZE) axis_master_bfm   = new(axis_in   );
AxiStreamSlaverBfm_c #(axis_out.DSIZE) axis_slaver_bfm  = new(axis_out  );

odd_width_convert #(
    .ISIZE      (axis_in.DSIZE),
    .OSIZE      (axis_out.DSIZE)
)odd_width_convert_inst(
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

int     ocnt;

assign  ocnt = axis_out.axis_tcnt;

initial begin
    repeat(100)
        axis_slaver_bfm.get_data($urandom_range(100,0),0);
end

logic [axis_in.DSIZE-1:0]  ds_data [$];

initial begin
    repeat(100)begin
        repeat(2*3*10)
            ds_data = {$urandom_range(10000,0),ds_data};
        axis_master_bfm.gen_axi_stream(ds_data.size(),$urandom_range(100,0),ds_data);
    end

end

feed_check #(
    .ASIZE      (axis_in.DSIZE    ),
    .BSIZE      (axis_out.DSIZE    ),
    .LIST       ("ON")
)feed_check_inst(
/*  input             */  .aclock   (axis_in.aclk             ),
/*  input [ASIZE-1:0] */  .adata    (axis_in.axis_tdata       ),
/*  input             */  .avld     (axis_in.axis_tvalid && axis_in.axis_tready),
/*  input             */  .amark    (0       ),
/*  input             */  .bclock   (axis_out.aclk            ),
/*  input [BSIZE-1:0] */  .bdata    (axis_out.axis_tdata      ),
/*  input             */  .bmark    (0      ),
/*  input             */  .bvld     (axis_out.axis_tvalid && axis_out.axis_tready)
);

endmodule
