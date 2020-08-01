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
module axi4_partition #(
    parameter PSIZE = 128,
    parameter real ADDR_STEP = 1
)(
    axi_inf.slaver axi_in,
    axi_inf.master axi_out
);

axi4_partition_wr #(
    .PSIZE      (PSIZE      ),
    .ADDR_STEP  (ADDR_STEP  )
)axi4_partition_wr_inst(
/*    axi_inf.slaver_wr */  .axi_in      (axi_in        ),
/*    axi_inf.master_wr */  .axi_out     (axi_out       )
);

axi4_partition_rd #(
    .PSIZE      (PSIZE      ),
    .ADDR_STEP  (ADDR_STEP  )
)axi4_partition_rd_inst(
/*    axi_inf.slaver_rd */  .axi_in      (axi_in        ),
/*    axi_inf.master_rd */  .axi_out     (axi_out       )
);

endmodule
