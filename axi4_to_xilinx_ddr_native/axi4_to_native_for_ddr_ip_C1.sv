/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.1 2017/9/28 
    user axi4 addr_step
Version: VERC.0.0 2018/11/23 
    rebuild
Version: VERC.1.0 ###### Fri Apr 24 10:14:28 CST 2020
    use ddr_native_fifo_verb
creaded: 2016/10/12
madified:
***********************************************/
`timescale 1ns / 1ps
(* axi4 = "true" *)
module axi4_to_native_for_ddr_ip_C1 #(
    parameter ADDR_WIDTH            = 27,
    parameter DATA_WIDTH            = 256
)(
    axi_inf.slaver                  ddr3_axi4_inf,
    output logic[ADDR_WIDTH-1:0]    app_addr,
    output logic[2:0]               app_cmd,
    output logic                    app_en,
    output logic[DATA_WIDTH-1:0]    app_wdf_data,
    output logic                    app_wdf_end,
    output logic[DATA_WIDTH/8-1:0]  app_wdf_mask,
    output logic                    app_wdf_wren,
    input  [DATA_WIDTH-1:0]         app_rd_data,
    input                           app_rd_data_end,
    input                           app_rd_data_valid,
    input                           app_rdy,
    input                           app_wdf_rdy,
    input logic                     init_calib_complete
);

axi_stream_inf #(DATA_WIDTH + ADDR_WIDTH + 3)   axis_inf (ddr3_axi4_inf.axi_aclk,ddr3_axi4_inf.axi_aresetn,1'b1);
axi_stream_inf #(DATA_WIDTH)                    axis_rd_inf (ddr3_axi4_inf.axi_aclk,ddr3_axi4_inf.axi_aresetn,1'b1);

ddr_axi4_to_axis ddr_axi4_to_axis_inst(
/*  axi4.slaver            */     .axi4_inf     (ddr3_axi4_inf    ),
/*  axi_stream_inf.master  */     .axis_inf     (axis_inf   ),
/*  axi_stream_inf.slaver  */     .axis_rd_inf  (axis_rd_inf)   //DSIZE
);

ddr_native_fifo_verb #(
    .ADDR_WIDTH     (ADDR_WIDTH   ),
    .DATA_WIDTH     (DATA_WIDTH   )
)ddr_native_fifo_verb_inst(
/*    axi_stream_inf.slaver         */ .axis_inf             (axis_inf              ),
/*    axi_stream_inf.master         */ .axis_rd_inf          (axis_rd_inf           ),
/*    //---DDR IP                   */
/*    output logic[ADDR_WIDTH-1:0]  */ .app_addr             (app_addr              ),
/*    output logic[2:0]             */ .app_cmd              (app_cmd               ),
/*    output logic                  */ .app_en               (app_en                ),
/*    output logic[DATA_WIDTH-1:0]  */ .app_wdf_data         (app_wdf_data          ),
/*    output logic                  */ .app_wdf_end          (app_wdf_end           ),
/*    output logic[DATA_WIDTH/8-1:0]*/ .app_wdf_mask         (app_wdf_mask          ),
/*    output logic                  */ .app_wdf_wren         (app_wdf_wren          ),
/*    input  [DATA_WIDTH-1:0]       */ .app_rd_data          (app_rd_data           ),
/*    input                         */ .app_rd_data_end      (app_rd_data_end       ),
/*    input                         */ .app_rd_data_valid    (app_rd_data_valid     ),
/*    input                         */ .app_rdy              (app_rdy               ),
/*    input                         */ .app_wdf_rdy          (app_wdf_rdy           ),
/*    input logic                   */ .init_calib_complete  (init_calib_complete   )
);

endmodule
