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
`include "define_macro.sv"
(* axi4 = "true" *)
module axi4_packet_fifo #(
    parameter   PIPE    = "OFF",
    parameter   DEPTH   = 4,
    `parameter_string   MODE    = "BOTH"        //ONLY_WRITE ONLY_READ BOTH
)(
    (* axi4_up = "true" *)
    axi_inf.slaver axi_in,
    (* axi4_down = "true" *)
    axi_inf.master axi_out
);

import SystemPkg::*;

initial begin
    assert(axi_in.MODE == axi_out.MODE)
    else begin
        $error("SLAVER AXIS MODE != MASTER AXIS MODE");
        $stop;
    end
end

`VCS_AXI4_CPT(axi_in,slaver,slaver_rd,Read)
`VCS_AXI4_CPT(axi_in,slaver,slaver_wr,Write)
`VCS_AXI4_CPT_LT(axi_out,master_rd,master,Read)
`VCS_AXI4_CPT_LT(axi_out,master_wr,master,Write)

generate
if(axi_in.MODE=="BOTH" || axi_in.MODE=="ONLY_WRITE")
axi4_wr_packet_fifo #(
    .PIPE       (PIPE       ),
    .DEPTH      (DEPTH      )
)axi4_wr_packet_fifo_inst(
/*    axi_inf.slaver_wr */  .axi_in      (`axi_in_vcs_cptWrite        ),
/*    axi_inf.master_wr */  .axi_out     (`axi_out_vcs_cptWrite       )
);
endgenerate

generate
if(axi_in.MODE=="BOTH" || axi_in.MODE=="ONLY_READ")
axi4_rd_packet_fifo #(
    .DEPTH      (DEPTH      )
)axi4_rd_packet_fifo_inst(
/*    axi_inf.slaver_rd */  .slaver      (`axi_in_vcs_cptRead        ),
/*    axi_inf.master_rd */  .master      (`axi_out_vcs_cptRead       )
);
endgenerate

endmodule
