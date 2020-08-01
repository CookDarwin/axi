/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/28 
madified:
***********************************************/
`timescale 1ns/1ps
module axi_stream_packet_fifo_2_28_tb;
import AxiBfmPkg::*;

logic   pclk;
logic   prst_n;

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(148.5     	)
)clock_rst_pixel(
	.clock			(pclk   	),
	.rst_x			(prst_n  	)
);

axi_stream_inf #(
    .DSIZE       (8  )
)master_inf(
/*    input bit  */ .aclk       (pclk       ),
/*    input bit  */ .aresetn    (prst_n     ),
/*    input bit  */ .aclken     (1'b1       )
);

axi_stream_inf #(
    .DSIZE       (8  )
)slaver_inf(
/*    input bit  */ .aclk       (pclk       ),
/*    input bit  */ .aresetn    (prst_n     ),
/*    input bit  */ .aclken     (1'b1       )
);

axi_stream_packet_fifo #(
    .DEPTH      (4      )   //2-4
)axi_stream_packet_fifo_inst(
/*    axi_stream_inf.slaver   */   .axis_in         (master_inf     ),
/*    axi_stream_inf.master   */   .axis_out        (slaver_inf     )
);

AxiStreamSlaverBfm_c #(8) SlaverBfm = new(slaver_inf);
AxiStreamMasterBfm_c #(8) MasterBfm = new(master_inf);

logic [7:0]     wdata_queue     [$];
logic [7:0]     rdata_queue     [$];
event           master_done_even;

initial begin
    wait(prst_n);
    wdata_queue = {1,2,3,4,5,6,7,8,9,10};
    fork
        begin
            MasterBfm.gen_axi_stream(16,100,wdata_queue);
            MasterBfm.gen_axi_stream(1,100,wdata_queue);
            MasterBfm.gen_axi_stream(2,100,wdata_queue);
            MasterBfm.gen_axi_stream(3,100,wdata_queue);
            MasterBfm.gen_axi_stream(20,100,wdata_queue);
            -> master_done_even;
        end
        begin
            wait(master_done_even.triggered());
            repeat(6)
                SlaverBfm.get_data(100);
        end
    join
end

endmodule
