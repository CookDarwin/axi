/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/31 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_merge_tb_0331;

import AxiBfmPkg::*;

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
    .IDSIZE    (4           ),
    .ASIZE     (8          ),
    .LSIZE     (8           ),
    .DSIZE     (8           )
)axi_inf_master(
    .axi_aclk      (pclk    ),
    .axi_aresetn    (prst_n  )
);

axi_inf #(
    .IDSIZE    (4           ),
    .ASIZE     (8          ),
    .LSIZE     (8           ),
    .DSIZE     (8           )
)axi_inf_slaver(
    .axi_aclk      (pclk    ),
    .axi_aresetn    (prst_n  )
);

axi4_merge #(
    .MAX        (8  )
)axi4_merge_inst(
/* axi_inf.slaver */    .slaver (axi_inf_master     ),
/* axi_inf.master */    .master (axi_inf_slaver     )
);

Axi4MasterBfm_c #(
    .IDSIZE    (axi_inf_master.IDSIZE   ),
    .ASIZE     (axi_inf_master.ASIZE    ),
    .DSIZE     (axi_inf_master.DSIZE    ),
    .LSIZE     (axi_inf_master.LSIZE    ),
    .MSG       ("OFF"                   )
) Axi4MasterBfm;

Axi4SlaverBfm_c #(
    .IDSIZE    (axi_inf_slaver.IDSIZE   ),
    .ASIZE     (axi_inf_slaver.ASIZE    ),
    .DSIZE     (axi_inf_slaver.DSIZE    ),
    .LSIZE     (axi_inf_slaver.LSIZE    ),
    .MSG       ("ON"                    )
) Axi4SlaverBfm;

logic[axi_inf_master.DSIZE-1:0]     master_queue [$];
logic[axi_inf_slaver.DSIZE-1:0]     slaver_queue [$];

IdAddrLen_S        ial_q [$];
IdAddrLen_S        ial_a [];

initial begin
    wait(prst_n);
    repeat(10)
        @(posedge pclk);
    // axi_slaver_inst.slaver_recieve_burst(3);
    Axi4MasterBfm = new(axi_inf_master);
    Axi4SlaverBfm = new(axi_inf_slaver);
    // Axi4SlaverBfm.run(100,100);
    Axi4SlaverBfm.out_fo_order_burst_read(100);
    master_queue    = {1,2,3,4,5,6,7,8,9};
    Axi4SlaverBfm.rd_queue = master_queue;
    //--------------------------------------------------------
    // Axi4MasterBfm.write_burst(0,0,100,master_queue);//addr---len---rate---queue
    // Axi4MasterBfm.read_burst(0,9,100,slaver_queue);
    // Axi4MasterBfm.read_burst(0,9,100,master_queue);
    out_of_order_read(100);

end

task automatic out_of_order_read(int ready_ramdon_percent);

    set_ial(0,0,5);
    set_ial(1,5,6);
    set_ial(2,11,10);
    set_ial(3,21,1);
    set_ial(4,22,1);
    set_ial(5,23,1);
    set_ial(6,24,10);
    set_ial(7,34,5);
    set_ial(8,39,5);
    set_ial(8,9,5);


    Axi4MasterBfm.out_of_order_read_burst(ial_q,ready_ramdon_percent,master_queue);
endtask:out_of_order_read

task automatic set_ial(int id,int addr,int len);
IdAddrLen_S a;
    a.id  = id;
    a.addr = addr;
    a.len  = len;
    ial_q.push_back(a);
endtask:set_ial

endmodule
