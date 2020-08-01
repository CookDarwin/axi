/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/5/24 
madified:
***********************************************/
`timescale 1ns/1ps
import AxiBfmPkg::*;
module axi4_data_convert_5_24_tb;

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
    .DSIZE     (24          ),
    .ADDR_STEP (1536        )
)axi_inf_master(
    .axi_aclk      (pclk    ),
    .axi_aresetn    (prst_n  )
);

axi_inf #(
    .IDSIZE    (1           ),
    .ASIZE     (8          ),
    .LSIZE     (8           ),
    .DSIZE     (32           ),
    .ADDR_STEP (2048        )
)axi_inf_slaver(
    .axi_aclk      (pclk    ),
    .axi_aresetn    (prst_n  )
);


axi4_data_convert_A1 axi4_data_convert_inst(
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
    .MSG       ("OFF"                    ),
    .ADDR_STEP (axi_inf_master.ADDR_STEP)
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
    .MSG       ("ON"                    ),
    .ADDR_STEP (axi_inf_slaver.ADDR_STEP)
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
    Axi4MasterBfm = new(axi_inf_master);
    Axi4SlaverBfm = new(axi_inf_slaver);
    wait(prst_n);
    repeat(100)
        @(posedge pclk);
    // axi_slaver_inst.slaver_recieve_burst(3);
    Axi4SlaverBfm.run(50,50);


    // Axi4SlaverBfm.rd_queue = {1,2,3,4,5,6,7,8,9};

    // Axi4MasterBfm.write_burst(0,5,100,master_queue);
    Axi4MasterBfm.read_burst(0,axi_inf_slaver.DSIZE*axi_inf_master.DSIZE/32*$urandom_range(1,4),100,master_queue);

end

task automatic gen_slaver_queue();
    repeat(axi_inf_slaver.DSIZE*axi_inf_master.DSIZE/32*$urandom_range(1,4))begin
        slaver_queue = {slaver_queue,$urandom_range(1024,0)};
    end
    Axi4SlaverBfm.rd_queue = slaver_queue;
endtask:gen_slaver_queue

initial begin
    wait(prst_n);
    gen_slaver_queue();
end

always@(posedge axi_inf_slaver.axi_aclk) begin
    if(axi_inf_slaver.axi_rvalid && axi_inf_slaver.axi_rready && axi_inf_slaver.axi_rlast)begin
        gen_slaver_queue();
    end
end


feed_check #(
    .ASIZE      (axi_inf_master.DSIZE    ),
    .BSIZE      (axi_inf_slaver.DSIZE    ),
    .LIST       ("ON")
)feed_check_inst(
/*  input             */  .aclock   (axi_inf_master.axi_aclk             ),
/*  input [ASIZE-1:0] */  .adata    (axi_inf_master.axi_rdata          ),
/*  input             */  .avld     (axi_inf_master.axi_rvalid && axi_inf_master.axi_rready),
/*  input             */  .amark    (0       ),
/*  input             */  .bclock   (axi_inf_slaver.axi_aclk            ),
/*  input [BSIZE-1:0] */  .bdata    (axi_inf_slaver.axi_rdata          ),
/*  input             */  .bmark    (0      ),
/*  input             */  .bvld     (axi_inf_slaver.axi_rvalid && axi_inf_slaver.axi_rready)
);



endmodule
