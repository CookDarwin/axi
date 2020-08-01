/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2016/10/12 
madified:
***********************************************/
`timescale 1ns / 1ps
module ddr3_ip_native_to_axi4 #(
    parameter BANK_WIDTH            = 3,// # of memory Bank Address bits.
    parameter CK_WIDTH              = 1,// # of CK/CK# outputs to memory.
    parameter CS_WIDTH              = 1,// # of unique CS outputs to memory.
    parameter ROW_WIDTH             = 13,
    parameter CKE_WIDTH             = 1,// # of CKE outputs to memory.
    parameter DM_WIDTH              = 4,// # of DM (data mask)
    parameter DQ_WIDTH              = 32,// # of DQ (data)
    parameter DQS_WIDTH             = 4,
    parameter ODT_WIDTH             = 1,
    parameter ADDR_WIDTH            = 27,
    parameter DATA_WIDTH            = 256,
    parameter SIM                   = "OFF"
)(
    axi_inf.slaver                              axi_inf,
    output                                      app_clk,
    output                                      app_sync_rst,
    // Inouts
    inout [DQ_WIDTH-1:0]                        ddr3_dq,
    inout [DQS_WIDTH-1:0]                       ddr3_dqs_n,
    inout [DQS_WIDTH-1:0]                       ddr3_dqs_p,
    // Outputs
    output [ROW_WIDTH-1:0]                      ddr3_addr,
    output [BANK_WIDTH-1:0]                     ddr3_ba,
    output                                      ddr3_ras_n,
    output                                      ddr3_cas_n,
    output                                      ddr3_we_n,
    output                                      ddr3_reset_n,
    output [CK_WIDTH-1:0]                       ddr3_ck_p,
    output [CK_WIDTH-1:0]                       ddr3_ck_n,
    output [CKE_WIDTH-1:0]                      ddr3_cke,
    output [CS_WIDTH-1:0]                       ddr3_cs_n,
    output [DM_WIDTH-1:0]                       ddr3_dm,
    output [ODT_WIDTH-1:0]                      ddr3_odt,
    input                                       sys_clk_i,
    input                                       clk_ref_i,
    input                                       sys_rst,
    output                                      init_calib_complete
);

logic   ui_clk;
logic   ui_clk_sync_rst;
// logic   init_calib_complete     ;

assign  app_clk         = ui_clk;
assign  app_sync_rst    = ui_clk_sync_rst;
// user interface signals
logic[ADDR_WIDTH-1:0]                       app_addr;
logic[2:0]                                  app_cmd;
logic                                       app_en;
logic[DATA_WIDTH-1:0]                       app_wdf_data;
logic                                       app_wdf_end;
logic[(DATA_WIDTH/8)-1:0]                   app_wdf_mask;
logic                                       app_wdf_wren;
logic [DATA_WIDTH-1:0]                      app_rd_data;
logic                                       app_rd_data_end;
logic                                       app_rd_data_valid;
logic                                       app_rdy;
logic                                       app_wdf_rdy;
logic                                       app_sr_req;
logic                                       app_ref_req;
logic                                       app_zq_req;
logic                                       app_sr_active;
logic                                       app_ref_ack;
logic                                       app_zq_ack;

assign app_sr_req   = 1'b0;
assign app_ref_req  = 1'b0;
assign app_zq_req   = 1'b0;


DDR3_native u_DDR3_native (

    // Memory interface ports
    .ddr3_addr                      (ddr3_addr),  // output [12:0]		ddr3_addr
    .ddr3_ba                        (ddr3_ba),  // output [2:0]		ddr3_ba
    .ddr3_cas_n                     (ddr3_cas_n),  // output			ddr3_cas_n
    .ddr3_ck_n                      (ddr3_ck_n),  // output [0:0]		ddr3_ck_n
    .ddr3_ck_p                      (ddr3_ck_p),  // output [0:0]		ddr3_ck_p
    .ddr3_cke                       (ddr3_cke),  // output [0:0]		ddr3_cke
    .ddr3_ras_n                     (ddr3_ras_n),  // output			ddr3_ras_n
    .ddr3_reset_n                   (ddr3_reset_n),  // output			ddr3_reset_n
    .ddr3_we_n                      (ddr3_we_n),  // output			ddr3_we_n
    .ddr3_dq                        (ddr3_dq),  // inout [31:0]		ddr3_dq
    .ddr3_dqs_n                     (ddr3_dqs_n),  // inout [3:0]		ddr3_dqs_n
    .ddr3_dqs_p                     (ddr3_dqs_p),  // inout [3:0]		ddr3_dqs_p
    .init_calib_complete            (init_calib_complete),  // output			init_calib_complete

	.ddr3_cs_n                      (ddr3_cs_n),  // output [0:0]		ddr3_cs_n
    .ddr3_dm                        (ddr3_dm),  // output [3:0]		ddr3_dm
    .ddr3_odt                       (ddr3_odt),  // output [0:0]		ddr3_odt
    // Application interface ports
    .app_addr                       (app_addr),  // input [26:0]		app_addr
    .app_cmd                        (app_cmd),  // input [2:0]		app_cmd
    .app_en                         (app_en),  // input				app_en
    .app_wdf_data                   (app_wdf_data),  // input [255:0]		app_wdf_data
    .app_wdf_end                    (app_wdf_end),  // input				app_wdf_end
    .app_wdf_wren                   (app_wdf_wren),  // input				app_wdf_wren
    .app_rd_data                    (app_rd_data),  // output [255:0]		app_rd_data
    .app_rd_data_end                (app_rd_data_end),  // output			app_rd_data_end
    .app_rd_data_valid              (app_rd_data_valid),  // output			app_rd_data_valid
    .app_rdy                        (app_rdy),  // output			app_rdy
    .app_wdf_rdy                    (app_wdf_rdy),  // output			app_wdf_rdy
    .app_sr_req                     (app_sr_req ),  // input			app_sr_req
    .app_ref_req                    (app_ref_req),  // input			app_ref_req
    .app_zq_req                     (app_zq_req ),  // input			app_zq_req
    .app_sr_active                  (),  // output			app_sr_active
    .app_ref_ack                    (),  // output			app_ref_ack
    .app_zq_ack                     (),  // output			app_zq_ack
    .ui_clk                         (ui_clk),  // output			ui_clk
    .ui_clk_sync_rst                (ui_clk_sync_rst),  // output			ui_clk_sync_rst
    .app_wdf_mask                   (app_wdf_mask),  // input [31:0]		app_wdf_mask
    // System Clock Ports
    .sys_clk_i                      (sys_clk_i),
    // Reference Clock Ports
    .clk_ref_i                      (clk_ref_i),
    .sys_rst                        (sys_rst) // input sys_rst
);

axi4_to_native_for_ddr_ip #(
    .ADDR_WIDTH     (ADDR_WIDTH     ),
    .DATA_WIDTH     (DATA_WIDTH     )
)axi4_to_native_for_ddr_ip_inst(
/*  axi_inf.slaver     */ .axi_inf                   (axi_inf               ),
/*  output logic[26:0] */ .app_addr                  (app_addr              ),
/*  output logic[2:0]  */ .app_cmd                   (app_cmd               ),
/*  output logic       */ .app_en                    (app_en                ),
/*  output logic[255:0]*/ .app_wdf_data              (app_wdf_data          ),
/*  output logic       */ .app_wdf_end               (app_wdf_end           ),
/*  output logic[31:0] */ .app_wdf_mask              (app_wdf_mask          ),
/*  output logic       */ .app_wdf_wren              (app_wdf_wren          ),
/*  input  [255:0]     */ .app_rd_data               (app_rd_data           ),
/*  input              */ .app_rd_data_end           (app_rd_data_end       ),
/*  input              */ .app_rd_data_valid         (app_rd_data_valid     ),
/*  input              */ .app_rdy                   (app_rdy               ),
/*  input              */ .app_wdf_rdy               (app_wdf_rdy           ),
/*  input              */ .init_calib_complete       (init_calib_complete   )
);

// generate
// if(DATA_WIDTH==256 && SIM == "ON")begin
// probe_large_width_data wr_probe_large_width_data_inst(
// /*  input             */  .clock               (axi_inf.axi_aclk        ),
// /*  input             */  .rst                 (!axi_inf.axi_aresetn     ),
// /*  input [DSIZE-1:0] */  .data                (axi_inf.axi_wdata       ),
// /*  input             */  .valid               (axi_inf.axi_wvalid      ),
// /*  input             */  .sync                (axi_inf.axi_bvalid && axi_inf.axi_awlen==0),
// /*  input             */  .sync_negedge        (),
// /*  input             */  .sync_posedge        ()
// );
//
// probe_large_width_data rd_probe_large_width_data_inst(
// /*  input             */  .clock               (axi_inf.axi_aclk        ),
// /*  input             */  .rst                 (!axi_inf.axi_aresetn     ),
// /*  input [DSIZE-1:0] */  .data                (axi_inf.axi_rdata       ),
// /*  input             */  .valid               (axi_inf.axi_rvalid      ),
// /*  input             */  .sync                (),
// /*  input             */  .sync_negedge        (axi_inf.axi_rlast && axi_inf.axi_arlen==79),
// /*  input             */  .sync_posedge        ()
// );
//
// probe_large_width_data app_wr_probe_large_width_data_inst(
// /*  input             */  .clock               (axi_inf.axi_aclk        ),
// /*  input             */  .rst                 (!axi_inf.axi_aresetn     ),
// /*  input [DSIZE-1:0] */  .data                (app_wdf_data       ),
// /*  input             */  .valid               (app_wdf_wren       ),
// /*  input             */  .sync                (axi_inf.axi_bvalid && axi_inf.axi_awlen==0),
// /*  input             */  .sync_negedge        (),
// /*  input             */  .sync_posedge        ()
// );
//
// probe_large_width_data app_rd_probe_large_width_data_inst(
// /*  input             */  .clock               (axi_inf.axi_aclk        ),
// /*  input             */  .rst                 (!axi_inf.axi_aresetn     ),
// /*  input [DSIZE-1:0] */  .data                (app_rd_data      ),
// /*  input             */  .valid               (app_rd_data_valid      ),
// /*  input             */  .sync                (),
// /*  input             */  .sync_negedge        (axi_inf.axi_rlast && axi_inf.axi_arlen==79),
// /*  input             */  .sync_posedge        ()
// );
// end
// endgenerate
endmodule
