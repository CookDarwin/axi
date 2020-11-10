/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 
madified:
***********************************************/
`timescale 1ns/1ps
import AxiBfmPkg::*;
module tb_ddr_ip_wrapper_sim;

logic   pclk;
logic   prst_n;

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(200     	)
)clock_rst_pixel(
	.clock			(pclk   	),
	.rst_x			(prst_n  	)
);


axi_inf #(
    .IDSIZE    (2          ),
    .ASIZE     (29         ),
    .LSIZE     (8          ),
    .DSIZE     (128        ),
    .MODE      ("BOTH"     ),
    .ADDR_STEP (1024*8     ),
    .FreqM     (200  )
)axi_inf_master(
    .axi_aclk      (pclk    ),
    .axi_aresetn   (prst_n  )
);

logic   calib_complete;

ddr3_ip_wrapper_sim #(
    .MARK_X     ("OFF")
)ddr3_ip_wrapper_sim_inst(
/*  output          */  .calib_complete (calib_complete       ),
/*  axi_inf.slaver  */  .caxi_inf       (axi_inf_master       )
);



Axi4MasterBfm_c #(
    .IDSIZE    (axi_inf_master.IDSIZE   ),
    .ASIZE     (axi_inf_master.ASIZE    ),
    .DSIZE     (axi_inf_master.DSIZE    ),
    .LSIZE     (axi_inf_master.LSIZE    ),
    .MSG       ("ON"                    ),
    .ADDR_STEP (1024*8       ),
    .FreqM     (200 )
) Axi4MasterBfm;

logic[axi_inf_master.DSIZE-1:0]     master_queue [$];
logic[axi_inf_master.DSIZE-1:0]     slaver_queue [$];

IdAddrLen_S        ial_q [$];

task automatic set_ial(int id,int addr,int len);
IdAddrLen_S a;
    a.id  = id;
    a.addr = addr;
    a.len  = len;
    ial_q.push_back(a);
endtask:set_ial

initial begin
    int ready_ramdon_percent;

    ready_ramdon_percent = 100;
    Axi4MasterBfm = new(axi_inf_master);
    Axi4MasterBfm.init();

    wait(prst_n);
    @(posedge calib_complete);
    repeat(100)
        @(posedge pclk);

    

    fork 
        repeat(10)begin
            Axi4MasterBfm.write_burst(0,16,$urandom_range(99,40),master_queue);//addr---len---rate---queue
            repeat(200)
                @(posedge pclk);

        end
        repeat(20)begin 
            // Axi4MasterBfm.read_burst(0,8,100,slaver_queue);
            // Axi4MasterBfm.read_burst(0,8,$urandom_range(99,40),slaver_queue);
            set_ial(0, 0, 8);
            set_ial(1, 5, 8);
            set_ial(2,11, 8);
            set_ial(3,21, 8);
            set_ial(4,22, 8);
            set_ial(5,23, 8);
            set_ial(6,24, 8);
            set_ial(7,34, 8);
            set_ial(8,39, 8);
            set_ial(8, 9, 8);
            Axi4MasterBfm.out_of_order_read_burst(ial_q,ready_ramdon_percent,slaver_queue);
            repeat(100)
                @(posedge pclk);
        end
    join
    // Axi4MasterBfm.read_burst(0,100,100,master_queue);

end

// initial begin
//     Axi4MasterBfm = new(axi_inf_master);
//     Axi4MasterBfm.init();

//     wait(prst_n);
//     @(posedge calib_complete);
//     repeat(100)
//         @(posedge pclk);

//     master_queue    = {1,2,3,4,5,6,7,8,9};
//     // Axi4MasterBfm.write_burst(0,100,100,master_queue);//addr---len---rate---queue
    
//     Axi4MasterBfm.read_burst(0,100,100,slaver_queue);
//     Axi4MasterBfm.read_burst(0,8,100,slaver_queue);
//     Axi4MasterBfm.read_burst(0,8,100,slaver_queue);
//     Axi4MasterBfm.read_burst(0,8,100,slaver_queue);
//     fork 
//         // repeat(20)begin
//         //     Axi4MasterBfm.write_burst(0,16,$urandom_range(99,40),master_queue);//addr---len---rate---queue
//         //     repeat(200)
//         //         @(posedge pclk);

//         //     $display("$$$$$$$$$$$$$$$$$$$$$$$$");
//         // end
//         repeat(20)begin 
//             // $display("0-0-0-0-0-0");
//             Axi4MasterBfm.read_burst(0,8,100,slaver_queue);
//             // Axi4MasterBfm.read_burst(0,8,$urandom_range(99,40),slaver_queue);
            
//         end
//     join
//     // Axi4MasterBfm.read_burst(0,100,100,master_queue);

// end

endmodule
