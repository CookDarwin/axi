/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/1 
madified:
***********************************************/
`timescale 1ns/1ps
module long_to_wide_3_1_tb;
import AxiBfmPkg::*;

logic   wr_clk;
logic   wrst_n;

logic   rd_clk;
logic   rrst_n;

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(15			),
	.FreqM			(150     	)
)clock_rst_master(
	.clock			(wr_clk	    ),
	.rst_x			(wrst_n 	)
);

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(15			),
	.FreqM			(100     	)
)clock_rst_slaver(
	.clock			(rd_clk     ),
	.rst_x			(rrst_n     )
);


axi_inf #(
    .IDSIZE    (1           ),
    .ASIZE     (12          ),
    .LSIZE     (12          ),
    .DSIZE     (32          )
)axi_inf_master(
    .axi_aclk      (wr_clk),
    .axi_aresetn    (wrst_n)
);

axi_inf #(
    .IDSIZE    (1           ),
    .ASIZE     (12          ),
    .LSIZE     (12          ),
    .DSIZE     (128         )
)axi_inf_slaver(
    .axi_aclk      (rd_clk     ),
    .axi_aresetn    (rrst_n     )
);

// long_axi4_to_wide_axi4 #(
axi4_long_to_axi4_wide #(
    .ADDR_STEP          (1  )
)long_axi4_to_wide_axi4_inst(
/*    axi_inf.slaver */ .slaver     (axi_inf_master     ),
/*    axi_inf.master */ .master    (axi_inf_slaver     )
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
IdAddrLen_S        ial_q [$];
IdAddrLen_S        ial_a [];

// initial begin
//     wait(rrst_n);
//     wait(wrst_n);
//     repeat(10)
//         @(posedge wr_clk);
//     // Axi4SlaverBfm.run(100,100);
//     Axi4SlaverBfm.out_fo_order_burst_read(50);
//     slaver_queue    = {9,8,7,6,5,4,3,2,1};
//     master_queue    = {1,2,3,4,5,6,7,8,9};
//     Axi4SlaverBfm.rd_queue = slaver_queue;
//     begin
//         // Axi4MasterBfm.write_burst(0,1000,100,master_queue);//addr---len---rate---queue
//         Axi4MasterBfm.read_burst(0,1000,50,master_queue);
//         // Axi4MasterBfm.read_burst(0,64,50,master_queue);
//     end
//
// end

initial begin
    wait(rrst_n);
    wait(wrst_n);
    repeat(10)
        @(posedge wr_clk);
    Axi4SlaverBfm.out_fo_order_burst_read(50);
    slaver_queue    = {9,8,7,6,5,4,3,2,1};
    master_queue    = {1,2,3,4,5,6,7,8,9};
    Axi4SlaverBfm.rd_queue = slaver_queue;
    begin
        out_of_order_read(50);
    end

end

task automatic out_of_order_read(int ready_ramdon_percent);
    ial_a = new[2];
    ial_a[0].id  = 0;
    ial_a[0].addr = 0;
    ial_a[0].len  = 999;
    ial_q.push_back(ial_a[0]);
    ial_a[1].id  = 1;
    ial_a[1].addr = 5;
    ial_a[1].len  = 1001;
    ial_q.push_back(ial_a[1]);

    Axi4MasterBfm.out_of_order_read_burst(ial_q,ready_ramdon_percent,master_queue);
endtask:out_of_order_read




endmodule
