/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/5/8 
madified:
***********************************************/
//
// `define Lite_Get_Addr(up_lite,down_lite)\
// import SystemPkg::*;\
// axi_lite_inf #(\
//     .ASIZE      (up_lite.ASIZE        ),\
//     .DSIZE      (up_lite.DSIZE        )\
// )down_lite(\
// /*    input bit */  .axi_aclk      (up_lite.axi_aclk     ),\
// /*    input bit */  .axi_aresetn    (up_lite.axi_aresetn   )\
// );\
// \
// function logic [up_lite.ASIZE-1:0]  up_lite.get_addr(input [31:0] name,input int id=0);\
//     return down_lite.get_addr(name,id);\
// endfunction\
// generate\
// if(SIM=="ON"||SIM=="TRUE")begin:LITE_ADDR_BYPASS\
//     assign down_lite.axi_awvalid    = up_lite.axi_awvalid;\
//     assign up_lite.axi_awready      = down_lite.axi_awready  ;\
//     assign down_lite.axi_awaddr     = up_lite.axi_awaddr ;\
//     assign down_lite.axi_awlock     = up_lite.axi_awlock ;\
//     assign down_lite.axi_wvalid     = up_lite.axi_wvalid ;\
//     assign up_lite.axi_wready       = down_lite.axi_wready   ;\
//     assign down_lite.axi_wdata      = up_lite.axi_wdata  ;\
//     assign up_lite.axi_bresp        = down_lite.axi_bresp    ;\
//     assign up_lite.axi_bvalid       = down_lite.axi_bvalid   ;\
//     assign down_lite.axi_bready     = up_lite.axi_bready ;\
//     assign down_lite.axi_arvalid    = up_lite.axi_arvalid;\
//     assign up_lite.axi_arready      = down_lite.axi_arready  ;\
//     assign down_lite.axi_araddr     = up_lite.axi_araddr ;\
//     assign down_lite.axi_arlock     = up_lite.axi_arlock ;\
//     assign up_lite.axi_rvalid       = down_lite.axi_rvalid   ;\
//     assign down_lite.axi_rready     = up_lite.axi_rready ;\
//     assign up_lite.axi_rdata        = down_lite.axi_rdata    ;\
// end\
// endgenerate
//
//
// `define Lite_Get_Addr_S\
// axi_lite_inf #(\
//     .ASIZE      (axil.ASIZE        ),\
//     .DSIZE      (axil.DSIZE        )\
// )axil_m(\
// /*    input bit */  .axi_aclk      (axil.axi_aclk     ),\
// /*    input bit */  .axi_aresetn    (axil.axi_aresetn   )\
// );\
// \
// function logic [axil.ASIZE-1:0]  axil.get_addr(input [31:0] name,input int id=0);\
//     return axil_m.get_addr(name,id);\
// endfunction\
// generate\
// if(SIM=="ON"||SIM=="TRUE")begin:LITE_ADDR_BYPASS\
// assign axil_m.axi_awvalid    = axil.axi_awvalid;\
// assign axil.axi_awready      = axil_m.axi_awready  ;\
// assign axil_m.axi_awaddr     = axil.axi_awaddr ;\
// assign axil_m.axi_awlock     = axil.axi_awlock ;\
// assign axil_m.axi_wvalid     = axil.axi_wvalid ;\
// assign axil.axi_wready       = axil_m.axi_wready   ;\
// assign axil_m.axi_wdata      = axil.axi_wdata  ;\
// assign axil.axi_bresp        = axil_m.axi_bresp    ;\
// assign axil.axi_bvalid       = axil_m.axi_bvalid   ;\
// assign axil_m.axi_bready     = axil.axi_bready ;\
// assign axil_m.axi_arvalid    = axil.axi_arvalid;\
// assign axil.axi_arready      = axil_m.axi_arready  ;\
// assign axil_m.axi_araddr     = axil.axi_araddr ;\
// assign axil_m.axi_arlock     = axil.axi_arlock ;\
// assign axil.axi_rvalid       = axil_m.axi_rvalid   ;\
// assign axil_m.axi_rready     = axil.axi_rready ;\
// assign axil.axi_rdata        = axil_m.axi_rdata    ;\
// end\
// endgenerate

`define CFG_DEF(num,lite_name)\
localparam         CFG_NUM   = num;\
common_configure_reg_interface #(\
    .ASIZE  (lite_name.ASIZE ),\
    .DSIZE  (lite_name.DSIZE )\
)cfg_inf [CFG_NUM-1:0] ();\
\
axi_lite_configure #(\
    .TOTAL_NUM      (CFG_NUM)\
)axi_lite_configure_inst(\
/*    axi_lite_inf.slaver                    */ .axil           (lite_name  ),\
/*    common_configure_reg_interface.master  */ .cfg_inf        (cfg_inf    )\
);



// `define LITE_CMD_DEF(num=1,lite_name=axil,up_trigger=1'b1,domn_trigger)\
//Vivado dont support default value
`define LITE_CMD_DEF(num,lite_name,up_trigger,domn_trigger)\
localparam   CMD_NUM = num;\
Lite_Addr_Data_CMD #(\
    .ASIZE      (lite_name.ASIZE  ),\
    .DSIZE      (lite_name.DSIZE  )\
)addrdatac [CMD_NUM-1:0] ();\
logic [lite_name.DSIZE-1:0]  lite_rdata;\
gen_axi_lite_ctrl_verb #(\
    .NUM        (CMD_NUM)\
)gen_axi_lite_ctrl_inst(\
/*    input                     */  .from_up_trigger    (up_trigger    ),\
/*    output logic              */  .to_domn_trigger    (domn_trigger),\
/*    axi_lite_inf.master       */  .lite               (lite_name           ),\
/*    Lite_Addr_Data_CMD.slaver */  .addrdatac          (addrdatac      ),\
/*    output logic []           */  .lite_rdata         (lite_rdata     )\
);

`define LITE_CMD_DEF_VERC(num,lite_name,up_trigger,domn_trigger)\
localparam   CMD_NUM = num;\
Lite_Addr_Data_CMD #(\
    .ASIZE      (lite_name.ASIZE  ),\
    .DSIZE      (lite_name.DSIZE  )\
)addrdatac [CMD_NUM-1:0] ();\
logic [lite_name.DSIZE-1:0]  lite_rdata;\
gen_axi_lite_ctrl_verc #(\
    .NUM        (CMD_NUM)\
)gen_axi_lite_ctrl_inst(\
/*    input                     */  .from_up_trigger    (up_trigger    ),\
/*    output logic              */  .to_domn_trigger    (domn_trigger),\
/*    axi_lite_inf.master       */  .lite               (lite_name           ),\
/*    Lite_Addr_Data_CMD.slaver */  .addrdatac          (addrdatac      ),\
/*    output logic []           */  .lite_rdata         (lite_rdata     )\
);
