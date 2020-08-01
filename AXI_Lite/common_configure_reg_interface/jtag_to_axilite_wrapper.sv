/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/11/16 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_lite = "true" *)
module jtag_to_axilite_wrapper(
    axi_lite_inf.master     lite
);

import SystemPkg::*;
assign clock = lite.axi_aclk;
assign rst_n = lite.axi_aresetn;


generate
if(SIM=="FALSE" || SIM=="OFF")begin

assign  lite.axi_arlock     = 1'b0;
assign  lite.axi_awlock     = 1'b0;

jtag_axi_0 jtag_axi_0_inst(
/*  input         */  .aclk                   (clock                ),
/*  input         */  .aresetn                (/*rst_n*/1'b1             ),
/*  output [31:0] */  .m_axi_awaddr           (lite.axi_awaddr           ),
/*  output [2:0]  */  .m_axi_awprot           (/*lite.axi_awprot*/       ),
/*  output        */  .m_axi_awvalid          (lite.axi_awvalid          ),
/*  input         */  .m_axi_awready          (lite.axi_awready          ),
/*  output [31:0] */  .m_axi_wdata            (lite.axi_wdata            ),
/*  output [3:0]  */  .m_axi_wstrb            (/*lite.axi_wstrb  */      ),
/*  output        */  .m_axi_wvalid           (lite.axi_wvalid           ),
/*  input         */  .m_axi_wready           (lite.axi_wready           ),
/*  input [1:0]   */  .m_axi_bresp            (lite.axi_bresp            ),
/*  input         */  .m_axi_bvalid           (lite.axi_bvalid           ),
/*  output        */  .m_axi_bready           (lite.axi_bready           ),
/*  output [31:0] */  .m_axi_araddr           (lite.axi_araddr           ),
/*  output [2:0]  */  .m_axi_arprot           (/*lite.axi_arprot  */     ),
/*  output        */  .m_axi_arvalid          (lite.axi_arvalid          ),
/*  input         */  .m_axi_arready          (lite.axi_arready          ),
/*  input [31:0]  */  .m_axi_rdata            (lite.axi_rdata            ),
/*  input [1:0]   */  .m_axi_rresp            (/*lite.axi_rresp */'0     ),
/*  input         */  .m_axi_rvalid           (lite.axi_rvalid           ),
/*  output        */  .m_axi_rready           (lite.axi_rready           )
);
end else
sim_jtag_debug jtag_axi_0_inst(
/*  axi_lite_inf.master  */   .lite     (lite   )
);
endgenerate
endmodule
