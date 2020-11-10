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
module ddr3_ip_wrapper_sim #(
    parameter MARK_X = "OFF"
)(
    // axi4
    axi_inf.slaver  caxi_inf,
    output          calib_complete
);


logic[28:0]    app_addr;
logic[2:0]     app_cmd;
logic          app_en;
logic[127:0]   app_wdf_data;
logic          app_wdf_end;
logic[15:0]    app_wdf_mask;
logic          app_wdf_wren;
logic [127:0]  app_rd_data;
logic          app_rd_data_end;
logic          app_rd_data_valid;
logic          app_rdy;
logic          app_wdf_rdy;
logic          app_sr_req;
logic          app_ref_req;
logic          app_zq_req;
logic          app_sr_active;
logic          app_ref_ack;
logic          app_zq_ack;

logic          init_calib_complete;

assign calib_complete = init_calib_complete;

axi4_to_native_for_ddr_ip_verc #(
    .ADDR_WIDTH     (29     ),
    .DATA_WIDTH     (128    )
)axi4_to_native_for_ddr_ip_verb_inst(
/*  axi_inf.slaver                */  .ddr3_axi4_inf        (caxi_inf               ),
/*  output logic[ADDR_WIDTH-1:0]  */  .app_addr             (app_addr               ),
/*  output logic[2:0]             */  .app_cmd              (app_cmd                ),
/*  output logic                  */  .app_en               (app_en                 ),
/*  output logic[DATA_WIDTH-1:0]  */  .app_wdf_data         (app_wdf_data           ),
/*  output logic                  */  .app_wdf_end          (app_wdf_end            ),
/*  output logic[DATA_WIDTH/8-1:0]*/  .app_wdf_mask         (app_wdf_mask           ),
/*  output logic                  */  .app_wdf_wren         (app_wdf_wren           ),
/*  input  [DATA_WIDTH-1:0]       */  .app_rd_data          (app_rd_data            ),
/*  input                         */  .app_rd_data_end      (app_rd_data_end        ),
/*  input                         */  .app_rd_data_valid    (app_rd_data_valid      ),
/*  input                         */  .app_rdy              (app_rdy                ),
/*  input                         */  .app_wdf_rdy          (app_wdf_rdy            ),
/*  input                         */  .init_calib_complete  (init_calib_complete    )
);

logic   driver_axi4_clk;
logic   driver_axi4_rst;

clock_rst_verb #(
	.ACTIVE			(1			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(500		),
	.FreqM			(200     	)
)clock_rst_pixel(
	.clock			(driver_axi4_clk   	),
	.rst_x			(driver_axi4_rst  	)
);

model_ddr_ip_app #(
    .ADDR_WIDTH            (29),
    .DATA_WIDTH            (128),
    .MARK_X                (MARK_X)
)model_ddr_ip_app_inst(
/*    input                          */ .clock                  (driver_axi4_clk        ),
/*    input  [ADDR_WIDTH-1:0]        */ .app_addr               (app_addr               ),
/*    input  [2:0]                   */ .app_cmd                (app_cmd                ),
/*    input                          */ .app_en                 (app_en                 ),
/*    input  [DATA_WIDTH-1:0]        */ .app_wdf_data           (app_wdf_data           ),
/*    input                          */ .app_wdf_end            (app_wdf_end            ),
/*    input  [DATA_WIDTH/8-1:0]      */ .app_wdf_mask           (app_wdf_mask           ),
/*    input                          */ .app_wdf_wren           (app_wdf_wren           ),
/*    output logic[DATA_WIDTH-1:0]   */ .app_rd_data            (app_rd_data            ),
/*    output logic                   */ .app_rd_data_end        (app_rd_data_end        ),
/*    output logic                   */ .app_rd_data_valid      (app_rd_data_valid      ),
/*    output logic                   */ .app_rdy                (app_rdy                ),
/*    output logic                   */ .app_wdf_rdy            (app_wdf_rdy            ),
/*    output logic                   */ .init_calib_complete    (init_calib_complete    )
);


endmodule
