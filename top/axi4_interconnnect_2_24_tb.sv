/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/24 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_interconnect_2_24_tb;
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


axi_inf #(
    .IDSIZE    (1           ),
    .ASIZE     (8          ),
    .LSIZE     (8           ),
    .DSIZE     (8           )
)axi_inf_master[7:0](
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

AXI4_interconnect_M2S #(
    .NUM        (8  )
)AXI4_interconnect_M2S_inst(
/*    axi_inf.slaver   */  .s00     (axi_inf_master ),
/*    axi_inf.master   */  .m00     (axi_inf_slaver )
);

Axi4MasterBfm_c #(
    .IDSIZE    (axi_inf_slaver.IDSIZE   ),
    .ASIZE     (axi_inf_slaver.ASIZE    ),
    .DSIZE     (axi_inf_slaver.DSIZE    ),
    .LSIZE     (axi_inf_slaver.LSIZE    ),
    .MSG       ("OFF"                   )
) Axi4MasterBfm[7:0];

Axi4SlaverBfm_c #(
    .IDSIZE    (axi_inf_slaver.IDSIZE   ),
    .ASIZE     (axi_inf_slaver.ASIZE    ),
    .DSIZE     (axi_inf_slaver.DSIZE    ),
    .LSIZE     (axi_inf_slaver.LSIZE    ),
    .MSG       ("ON"                    )
) Axi4SlaverBfm;

logic[axi_inf_slaver.DSIZE-1:0]     master_queue_0 [$];
logic[axi_inf_slaver.DSIZE-1:0]     master_queue_1 [$];
logic[axi_inf_slaver.DSIZE-1:0]     master_queue_2 [$];
logic[axi_inf_slaver.DSIZE-1:0]     master_queue_3 [$];

logic[axi_inf_slaver.DSIZE-1:0]     slaver_queue_0 [$];
logic[axi_inf_slaver.DSIZE-1:0]     slaver_queue_1 [$];
logic[axi_inf_slaver.DSIZE-1:0]     slaver_queue_2 [$];
logic[axi_inf_slaver.DSIZE-1:0]     slaver_queue_3 [$];
logic[axi_inf_slaver.DSIZE-1:0]     slaver_queue_4 [$];
logic[axi_inf_slaver.DSIZE-1:0]     slaver_queue_5 [$];
logic[axi_inf_slaver.DSIZE-1:0]     slaver_queue_6 [$];
logic[axi_inf_slaver.DSIZE-1:0]     slaver_queue_7 [$];


initial begin
    wait(prst_n);
    repeat(10)
        @(posedge pclk);
    Axi4MasterBfm[0]    = new(axi_inf_master[0]);
    Axi4MasterBfm[1]    = new(axi_inf_master[1]);
    Axi4MasterBfm[2]    = new(axi_inf_master[2]);
    Axi4MasterBfm[3]    = new(axi_inf_master[3]);
    Axi4MasterBfm[4]    = new(axi_inf_master[4]);
    Axi4MasterBfm[5]    = new(axi_inf_master[5]);
    Axi4MasterBfm[6]    = new(axi_inf_master[6]);
    Axi4MasterBfm[7]    = new(axi_inf_master[7]);
    foreach(Axi4MasterBfm[i])
        Axi4MasterBfm[i].init();

    Axi4SlaverBfm = new(axi_inf_slaver);
    //----
    Axi4SlaverBfm.run(100,100);
    master_queue_0    = {1,2,3,4,5,6,7,8,9};
    Axi4SlaverBfm.rd_queue = master_queue_0;
    fork
        //--->> WRITE
        begin
            master_queue_0    = {1,2,3,4,5,6,7,8,9};
            Axi4MasterBfm[0].write_burst(0,0,50,master_queue_0);//addr---len---rate---queue
        end
        begin
            random_queue(master_queue_1);
            Axi4MasterBfm[1].write_burst(0,0,50,master_queue_1);
        end
        begin
            random_queue(master_queue_2);
            Axi4MasterBfm[2].write_burst(0,0,50,master_queue_2);
        end
        //--->> READ
        Axi4MasterBfm[0].read_burst(0,9,100,slaver_queue_0);
        Axi4MasterBfm[1].read_burst(0,5,100,slaver_queue_3);
        Axi4MasterBfm[4].read_burst(0,6,100,slaver_queue_4);
        Axi4MasterBfm[5].read_burst(0,7,100,slaver_queue_5);
    join
    //-->> READ
    // Axi4SlaverBfm.rd_queue = master_queue_0;
    // Axi4MasterBfm[0].read_burst(0,9,100,slaver_queue);
end

task automatic random_queue(ref logic[axi_inf_slaver.DSIZE-1:0] queue [$]);
int rt;
logic[axi_inf_slaver.DSIZE-1:0] data;
    queue   = {};
    rt = $urandom_range(20,5);
    for(int i=0;i<rt;i++)begin
        data =  $urandom_range(10,0);
        queue = {queue,data};
    end
endtask:random_queue


endmodule
