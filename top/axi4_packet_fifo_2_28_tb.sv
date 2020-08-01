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
import AxiBfmPkg::*;
module axi4_packet_fifo_2_28_tb;

logic   wr_clk;
logic   wrst_n;

logic   rd_clk;
logic   rrst_n;

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(150     	)
)clock_rst_master(
	.clock			(wr_clk	    ),
	.rst_x			(wrst_n 	)
);

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(100     	)
)clock_rst_slaver(
	.clock			(rd_clk     ),
	.rst_x			(rrst_n     )
);


axi_inf #(
    .IDSIZE    (1           ),
    .ASIZE     (8          ),
    .LSIZE     (8           ),
    .DSIZE     (8           )
)axi_inf_master(
    .axi_aclk      (wr_clk),
    .axi_aresetn    (wrst_n)
);

axi_inf #(
    .IDSIZE    (1           ),
    .ASIZE     (8          ),
    .LSIZE     (8           ),
    .DSIZE     (8           )
)axi_inf_slaver(
    .axi_aclk      (rd_clk     ),
    .axi_aresetn    (rrst_n     )
);

axi4_packet_fifo #(
    .DEPTH      (4  )
)axi4_packet_fifo_inst(
/*    axi_inf.master*/ .axi_in      (axi_inf_master),
/*    axi_inf.slaver*/ .axi_out     (axi_inf_slaver)
);

Axi4MasterBfm_c #(
    .IDSIZE    (axi_inf_master.IDSIZE   ),
    .ASIZE     (axi_inf_master.ASIZE    ),
    .DSIZE     (axi_inf_master.DSIZE    ),
    .LSIZE     (axi_inf_master.LSIZE    ),
    .MSG       ("OFF"                   )
) Axi4MasterBfm = new(axi_inf_master);

Axi4SlaverBfm_c #(
    .IDSIZE    (axi_inf_slaver.IDSIZE   ),
    .ASIZE     (axi_inf_slaver.ASIZE    ),
    .DSIZE     (axi_inf_slaver.DSIZE    ),
    .LSIZE     (axi_inf_slaver.LSIZE    ),
    .MSG       ("ON"                    )
) Axi4SlaverBfm = new(axi_inf_slaver);


logic[axi_inf_master.DSIZE-1:0]     master_queue [$];
logic[axi_inf_slaver.DSIZE-1:0]     slaver_queue [$];

initial begin
    wait(rrst_n);
    wait(wrst_n);
    repeat(10)
        @(posedge wr_clk);
    // axi_slaver_inst.slaver_recieve_burst(3);
    Axi4SlaverBfm.run(100,100);
    master_queue    = {1,2,3,4,5,6,7,8,9};
    Axi4SlaverBfm.rd_queue = master_queue;
    // Axi4MasterBfm.write_burst(0,0,100,master_queue);//addr---len---rate---queue
    fork
        Axi4MasterBfm.read_burst(0,5,100,slaver_queue);
        Axi4MasterBfm.read_burst(0,9,100,master_queue);
        Axi4MasterBfm.read_burst(0,1,100,slaver_queue);
    join

end

endmodule
