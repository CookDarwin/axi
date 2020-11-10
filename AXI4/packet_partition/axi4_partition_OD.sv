/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    out of order
author : Cook.Darwin
Version: VERB.0.0
    update read partition
creaded: 2017/3/7 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_partition_OD #(
    parameter PSIZE = 128,          //master side
    // parameter real ADDR_STEP = 1
    parameter FORCE_MODE = 99  // 0: BOTH ,1: WRITE, 2: READ
)(
    axi_inf.slaver slaver,
    axi_inf.master master
);

import SystemPkg::*;

initial begin
    assert(slaver.MODE == master.MODE)
    else begin
        $error("SLAVER AXIS MODE != MASTER AXIS MODE");
        $stop;
    end

    assert(real'(slaver.DSIZE)/slaver.ADDR_STEP == real'(master.DSIZE)/master.ADDR_STEP)
    else begin
        $error("SLAVER ADDR STEP [%d][%d] DONT MATCH MASTER[%d][%d]",slaver.DSIZE,slaver.ADDR_STEP,master.DSIZE,master.ADDR_STEP);
        $finish;
    end
end
`include "define_macro.sv"
`VCS_AXI4_CPT(slaver,slaver,slaver_rd,Read)
`VCS_AXI4_CPT(slaver,slaver,slaver_wr,Write)
`VCS_AXI4_CPT_LT(master,master_rd,master,Read)
`VCS_AXI4_CPT_LT(master,master_wr,master,Write)

generate
if((FORCE_MODE>2 && (slaver.MODE=="BOTH" || slaver.MODE=="ONLY_WRITE")) || FORCE_MODE==0 || FORCE_MODE==1)
axi4_partition_wr_OD #(
    .PSIZE      (PSIZE      )
    // .ADDR_STEP  (ADDR_STEP  )
)axi4_partition_wr_inst(
/*    axi_inf.slaver_wr */  .axi_in      (`slaver_vcs_cptWrite        ),
/*    axi_inf.master_wr */  .axi_out     (`master_vcs_cptWrite        )
);
endgenerate

generate
if((FORCE_MODE>2 && (slaver.MODE=="BOTH" || slaver.MODE=="ONLY_READ")) || FORCE_MODE==0 || FORCE_MODE==2)
axi4_partition_rd_verb #(
    .PSIZE      (PSIZE      )
    // .ADDR_STEP  (ADDR_STEP  )
)axi4_partition_rd_inst(
/*    axi_inf.slaver_rd */  .long_inf     (`slaver_vcs_cptRead       ),
/*    axi_inf.master_rd */  .short_inf    (`master_vcs_cptRead       )
);
endgenerate

endmodule
