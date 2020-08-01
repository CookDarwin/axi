/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/23 
madified:
***********************************************/
`timescale 1ns/1ps
import AxiBfmPkg::*;
module axi4_partition_2_23_tb;

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


axi_inf #(
    .IDSIZE    (1           ),
    .ASIZE     (8          ),
    .LSIZE     (8           ),
    .DSIZE     (8           )
)axi_inf_master(
    .axi_aclk      (pclk    ),
    .axi_aresetn    (prst_n  )
);

axi_inf #(
    .IDSIZE    (1           ),
    .ASIZE     (8          ),
    .LSIZE     (8           ),
    .DSIZE     (8           )
)axi_inf_slaver(
    .axi_aclk      (pclk    ),
    .axi_aresetn    (prst_n  )
);

axi4_partition #(
    .PSIZE      (9       ),
    .ADDR_STEP  (1       )
)axi4_partition_inst(
/*    axi_inf.master*/ .axi_in      (axi_inf_master),
/*    axi_inf.slaver*/ .axi_out     (axi_inf_slaver)
);

Axi4MasterBfm_c #(
    .IDSIZE    (axi_inf_master.IDSIZE   ),
    .ASIZE     (axi_inf_master.ASIZE    ),
    .DSIZE     (axi_inf_master.DSIZE    ),
    .LSIZE     (axi_inf_master.LSIZE    ),
    .MSG       ("ON"                   )
) Axi4MasterBfm;

Axi4SlaverBfm_c #(
    .IDSIZE    (axi_inf_slaver.IDSIZE   ),
    .ASIZE     (axi_inf_slaver.ASIZE    ),
    .DSIZE     (axi_inf_slaver.DSIZE    ),
    .LSIZE     (axi_inf_slaver.LSIZE    ),
    .MSG       ("OFF"                    )
) Axi4SlaverBfm;

logic[axi_inf_master.DSIZE-1:0]     master_queue [$];
logic[axi_inf_slaver.DSIZE-1:0]     slaver_queue [$];


initial begin
    wait(prst_n);
    repeat(10)
        @(posedge pclk);
    // axi_slaver_inst.slaver_recieve_burst(3);
    Axi4MasterBfm = new(axi_inf_master);
    Axi4SlaverBfm = new(axi_inf_slaver);
    Axi4SlaverBfm.run(100,100);
    master_queue    = {1,2,3,4,5,6,7,8,9};
    Axi4SlaverBfm.rd_queue = master_queue;
    // Axi4MasterBfm.write_burst(0,0,100,master_queue);//addr---len---rate---queue
    Axi4MasterBfm.read_burst(0,1,100,slaver_queue);
    // Axi4MasterBfm.read_burst(0,9,100,master_queue);

end

endmodule
