/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/20 
madified:
***********************************************/
`timescale 1ns/1ps
import AxiBfmPkg::*;
module axi4_data_convert_2_20_tb;

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
    .DSIZE     (6           )
)axi_inf_master(
    .axi_aclk      (pclk    ),
    .axi_aresetn    (prst_n  )
);

axi_inf #(
    .IDSIZE    (1           ),
    .ASIZE     (8          ),
    .LSIZE     (8           ),
    .DSIZE     (32           )
)axi_inf_slaver(
    .axi_aclk      (pclk    ),
    .axi_aresetn    (prst_n  )
);


axi4_data_convert axi4_data_convert_inst(
/*    axi_inf.master */ .axi_in         (axi_inf_master ),
/*    axi_inf.slaver */ .axi_out        (axi_inf_slaver )
);

// axi_master #(
//     .ASIZE      (axi_inf_master.ASIZE),
//     .DSIZE      (axi_inf_master.DSIZE),
//     .LSIZE      (axi_inf_master.LSIZE)
// )axi_master_inst(
// /*    axi_inf.master*/ .inf (axi_inf_master)
// );

Axi4MasterBfm_c #(
    .IDSIZE    (axi_inf_master.IDSIZE   ),
    .ASIZE     (axi_inf_master.ASIZE    ),
    .DSIZE     (axi_inf_master.DSIZE    ),
    .LSIZE     (axi_inf_master.LSIZE    ),
    .MSG       ("OFF"                    )
) Axi4MasterBfm;


// axi_slaver #(
//     .ASIZE      (axi_inf_slaver.ASIZE),
//     .DSIZE      (axi_inf_slaver.DSIZE),
//     .LSIZE      (axi_inf_slaver.LSIZE)
// )axi_slaver_inst(
// /*    axi_inf.master*/ .inf (axi_inf_slaver)
// );

Axi4SlaverBfm_c #(
    .IDSIZE    (axi_inf_slaver.IDSIZE   ),
    .ASIZE     (axi_inf_slaver.ASIZE    ),
    .DSIZE     (axi_inf_slaver.DSIZE    ),
    .LSIZE     (axi_inf_slaver.LSIZE    ),
    .MSG       ("ON"                    )
) Axi4SlaverBfm;


logic[axi_inf_master.DSIZE-1:0]     master_queue [$];
logic[axi_inf_slaver.DSIZE-1:0]     slaver_queue [$];

// initial begin
//     master_queue    = {0,1,2,3,4,5,6,7,8};
//     axi_master_inst.initial_master_info(0);
//     axi_slaver_inst.slaver_recieve_burst(3);
//     axi_master_inst.burst_write(0,master_queue);
// end

initial begin
    wait(prst_n);
    repeat(10)
        @(posedge pclk);
    // axi_slaver_inst.slaver_recieve_burst(3);
    Axi4MasterBfm = new(axi_inf_master);
    Axi4SlaverBfm = new(axi_inf_slaver);
    Axi4SlaverBfm.run(50,50);
    master_queue    = {1,2,3,4,5,6,7,8,9};
    slaver_queue    = {>>{master_queue}};
    Axi4SlaverBfm.rd_queue = slaver_queue;
    // Axi4SlaverBfm.rd_queue = {1,2,3,4,5,6,7,8,9};

    Axi4MasterBfm.write_burst(0,100,30,master_queue);
    Axi4MasterBfm.read_burst(0,100,50,master_queue);

end

logic [axi_inf_master.DSIZE-1:0]    split_slaver_data [axi_inf_slaver.DSIZE/axi_inf_master.DSIZE-1:0];
logic [axi_inf_master.DSIZE-1:0]    split_slaver_rdata [axi_inf_slaver.DSIZE/axi_inf_master.DSIZE-1:0];

always_comb begin
    split_slaver_data =  {>>{axi_inf_slaver.axi_wdata[(axi_inf_slaver.DSIZE/axi_inf_master.DSIZE)*axi_inf_master.DSIZE-1:0]}};
    split_slaver_rdata = {>>{axi_inf_slaver.axi_rdata[(axi_inf_slaver.DSIZE/axi_inf_master.DSIZE)*axi_inf_master.DSIZE-1:0]}};
end


endmodule
