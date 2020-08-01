/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/7/13 
madified:
***********************************************/
`timescale 1ns/1ps
module microblaze_inf (
    input                   core_clk,
    input                   core_rst_n,
    axi_inf.master          axi4
);

logic [31:0]   MBZ_AXI_araddr;
logic [1:0]    MBZ_AXI_arburst;
logic [3:0]    MBZ_AXI_arcache;
logic [7:0]    MBZ_AXI_arlen;
logic [0:0]    MBZ_AXI_arlock;
logic [2:0]    MBZ_AXI_arprot;
logic [3:0]    MBZ_AXI_arqos;
logic          MBZ_AXI_arready;
logic [3:0]    MBZ_AXI_arregion;
logic [2:0]    MBZ_AXI_arsize;
logic          MBZ_AXI_arvalid;
logic [31:0]   MBZ_AXI_awaddr;
logic [1:0]    MBZ_AXI_awburst;
logic [3:0]    MBZ_AXI_awcache;
logic [7:0]    MBZ_AXI_awlen;
logic [0:0]    MBZ_AXI_awlock;
logic [2:0]    MBZ_AXI_awprot;
logic [3:0]    MBZ_AXI_awqos;
logic          MBZ_AXI_awready;
logic [3:0]    MBZ_AXI_awregion;
logic [2:0]    MBZ_AXI_awsize;
logic          MBZ_AXI_awvalid;
logic          MBZ_AXI_bready;
logic[1:0]     MBZ_AXI_bresp;
logic          MBZ_AXI_bvalid;
logic[31:0]    MBZ_AXI_rdata;
logic          MBZ_AXI_rlast;
logic          MBZ_AXI_rready;
logic[1:0]     MBZ_AXI_rresp;
logic          MBZ_AXI_rvalid;
logic [31:0]   MBZ_AXI_wdata;
logic          MBZ_AXI_wlast;
logic          MBZ_AXI_wready;
logic [3:0]    MBZ_AXI_wstrb;
logic          MBZ_AXI_wvalid;

 MicroBlaze_U_wrapper MicroBlaze_U_wrapper_inst  (
    .M00_ACLK               (axi4 .axi_aclk       ),
    .M00_ARESETN            (axi4 .axi_aresetn     ),
    .M00_AXI_araddr         (MBZ_AXI_araddr      ),
    .M00_AXI_arburst        (MBZ_AXI_arburst     ),
    .M00_AXI_arcache        (MBZ_AXI_arcache     ),
    .M00_AXI_arlen          (MBZ_AXI_arlen       ),
    .M00_AXI_arlock         (MBZ_AXI_arlock      ),
    .M00_AXI_arprot         (MBZ_AXI_arprot      ),
    .M00_AXI_arqos          (MBZ_AXI_arqos       ),
    .M00_AXI_arready        (MBZ_AXI_arready     ),
    .M00_AXI_arregion       (MBZ_AXI_arregion    ),
    .M00_AXI_arsize         (MBZ_AXI_arsize      ),
    .M00_AXI_arvalid        (MBZ_AXI_arvalid     ),
    .M00_AXI_awaddr         (MBZ_AXI_awaddr      ),
    .M00_AXI_awburst        (MBZ_AXI_awburst     ),
    .M00_AXI_awcache        (MBZ_AXI_awcache     ),
    .M00_AXI_awlen          (MBZ_AXI_awlen       ),
    .M00_AXI_awlock         (MBZ_AXI_awlock      ),
    .M00_AXI_awprot         (MBZ_AXI_awprot      ),
    .M00_AXI_awqos          (MBZ_AXI_awqos       ),
    .M00_AXI_awready        (MBZ_AXI_awready     ),
    .M00_AXI_awregion       (MBZ_AXI_awregion    ),
    .M00_AXI_awsize         (MBZ_AXI_awsize      ),
    .M00_AXI_awvalid        (MBZ_AXI_awvalid     ),
    .M00_AXI_bready         (MBZ_AXI_bready      ),
    .M00_AXI_bresp          (MBZ_AXI_bresp       ),
    .M00_AXI_bvalid         (MBZ_AXI_bvalid      ),
    .M00_AXI_rdata          (MBZ_AXI_rdata       ),
    .M00_AXI_rlast          (MBZ_AXI_rlast       ),
    .M00_AXI_rready         (MBZ_AXI_rready      ),
    .M00_AXI_rresp          (MBZ_AXI_rresp       ),
    .M00_AXI_rvalid         (MBZ_AXI_rvalid      ),
    .M00_AXI_wdata          (MBZ_AXI_wdata       ),
    .M00_AXI_wlast          (MBZ_AXI_wlast       ),
    .M00_AXI_wready         (MBZ_AXI_wready      ),
    .M00_AXI_wstrb          (MBZ_AXI_wstrb       ),
    .M00_AXI_wvalid         (MBZ_AXI_wvalid      ),
    .clk_in1                (core_clk            ),
    .resetn                 (core_rst_n          )
);


xilinx_axi4_to_axi4 xilinx_axi4_to_axi4_inst(
/*    input   [31:0] */  .MBZ_AXI_araddr                (MBZ_AXI_araddr         ),
/*    input   [1:0]  */  .MBZ_AXI_arburst               (MBZ_AXI_arburst        ),
/*    input   [3:0]  */  .MBZ_AXI_arcache               (MBZ_AXI_arcache        ),
/*    input   [7:0]  */  .MBZ_AXI_arlen                 (MBZ_AXI_arlen          ),
/*    input   [0:0]  */  .MBZ_AXI_arlock                (MBZ_AXI_arlock         ),
/*    input   [2:0]  */  .MBZ_AXI_arprot                (MBZ_AXI_arprot         ),
/*    input   [3:0]  */  .MBZ_AXI_arqos                 (MBZ_AXI_arqos          ),
/*    output         */  .MBZ_AXI_arready               (MBZ_AXI_arready        ),
/*    input   [3:0]  */  .MBZ_AXI_arregion              (MBZ_AXI_arregion       ),
/*    input   [2:0]  */  .MBZ_AXI_arsize                (MBZ_AXI_arsize         ),
/*    input          */  .MBZ_AXI_arvalid               (MBZ_AXI_arvalid        ),
/*    input   [31:0] */  .MBZ_AXI_awaddr                (MBZ_AXI_awaddr         ),
/*    input   [1:0]  */  .MBZ_AXI_awburst               (MBZ_AXI_awburst        ),
/*    input   [3:0]  */  .MBZ_AXI_awcache               (MBZ_AXI_awcache        ),
/*    input   [7:0]  */  .MBZ_AXI_awlen                 (MBZ_AXI_awlen          ),
/*    input   [0:0]  */  .MBZ_AXI_awlock                (MBZ_AXI_awlock         ),
/*    input   [2:0]  */  .MBZ_AXI_awprot                (MBZ_AXI_awprot         ),
/*    input   [3:0]  */  .MBZ_AXI_awqos                 (MBZ_AXI_awqos          ),
/*    output         */  .MBZ_AXI_awready               (MBZ_AXI_awready        ),
/*    input   [3:0]  */  .MBZ_AXI_awregion              (MBZ_AXI_awregion       ),
/*    input   [2:0]  */  .MBZ_AXI_awsize                (MBZ_AXI_awsize         ),
/*    input          */  .MBZ_AXI_awvalid               (MBZ_AXI_awvalid        ),
/*    input          */  .MBZ_AXI_bready                (MBZ_AXI_bready         ),
/*    output [1:0]   */  .MBZ_AXI_bresp                 (MBZ_AXI_bresp          ),
/*    output         */  .MBZ_AXI_bvalid                (MBZ_AXI_bvalid         ),
/*    output [31:0]  */  .MBZ_AXI_rdata                 (MBZ_AXI_rdata          ),
/*    output         */  .MBZ_AXI_rlast                 (MBZ_AXI_rlast          ),
/*    input          */  .MBZ_AXI_rready                (MBZ_AXI_rready         ),
/*    output [1:0]   */  .MBZ_AXI_rresp                 (MBZ_AXI_rresp          ),
/*    output         */  .MBZ_AXI_rvalid                (MBZ_AXI_rvalid         ),
/*    input   [31:0] */  .MBZ_AXI_wdata                 (MBZ_AXI_wdata          ),
/*    input          */  .MBZ_AXI_wlast                 (MBZ_AXI_wlast          ),
/*    output         */  .MBZ_AXI_wready                (MBZ_AXI_wready         ),
/*    input   [3:0]  */  .MBZ_AXI_wstrb                 (MBZ_AXI_wstrb          ),
/*    input          */  .MBZ_AXI_wvalid                (MBZ_AXI_wvalid         ),
/*    axi_inf.master */  .axi4                          (axi4                   )
);

endmodule
