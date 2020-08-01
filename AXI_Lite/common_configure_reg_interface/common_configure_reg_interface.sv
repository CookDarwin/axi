
/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript: 通用配置寄存器接口 用于配置模块寄存器
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/1/9 
madified:
***********************************************/
interface  common_configure_reg_interface #(
    parameter ASIZE = 8,
    parameter DSIZE = 32
)();

// `include "E:/work/xilinx_exp/digilent_aritx_ethernet_1205/RTL/data_interface/cfg_reg_define.svh"

// logic [ASIZE-1:0]   bus_addr;
logic [DSIZE-1:0]   wdata;
logic [DSIZE-1:0]   rdata;
logic [ASIZE-1:0]   addr;
logic [DSIZE-1:0]   default_value;
logic               rst;
logic               interrupt_enable;
logic               interrupt_trigger;


modport master (        //configure centor
output  wdata,
input   rdata,
input   addr,
input   default_value,
input   rst,
input   interrupt_enable,
input   interrupt_trigger
// import function  logic[DSIZE-1:0] SET_REG(
//     input int                       faddr,
//     // output [cfg_inf.DSIZE-1:0]      fwdata,
//     input int                       fdefault_value,
//     input int                       frdata,
//     input int                       frst)
);

modport slaver (
input   wdata,
output  rdata,
output  addr,
output  default_value,
output  rst,
output  interrupt_enable,
output  interrupt_trigger
);

// function logic [DSIZE-1:0] SET_REG(
//     input int                       faddr,
//     // output [cfg_inf.DSIZE-1:0]      fwdata,
//     input int                       fdefault_value,
//     input int                       frdata,
//     input int                       frst);
//
//     addr    = faddr[ASIZE-1:0];
//     // fwdata  = wdata;
//     rdata   = frdata[DSIZE-1:0];
//     rst     = frst[0];
//
//     default_value  = fdefault_value[DSIZE-1:0];
//
//     return wdata;
//
// endfunction:SET_REG


endinterface:common_configure_reg_interface

module CFG_REG #(
    parameter DSIZE = 32
)(
    common_configure_reg_interface.slaver  cfg_inf,
    input int                       addr,
    output[DSIZE-1:0]               wdata,
    input [DSIZE-1:0]               default_value,
    input [DSIZE-1:0]               rdata,
    input logic                     rst
);

assign cfg_inf.addr = addr[cfg_inf.ASIZE-1:0];
assign wdata        = cfg_inf.wdata[DSIZE-1:0];
assign cfg_inf.default_value  = default_value[cfg_inf.DSIZE-1:0];
assign cfg_inf.rdata[DSIZE-1:0]     = rdata;
assign cfg_inf.rst   = rst;
assign cfg_inf.interrupt_enable     = 1'b0;
assign cfg_inf.interrupt_trigger    = 1'b0;
endmodule:CFG_REG

// module CFG_REG_A1 #(
//     parameter DSIZE = 1
// )(
//     common_configure_reg_interface.slaver  cfg_inf,
//     input int                    addr,
//     output [DSIZE-1:0]           wdata,
//     input [DSIZE-1:0]            default_value,
//     input [DSIZE-1:0]            rdata,
//     input                        rst
// );
//
// assign cfg_inf.addr = addr[cfg_inf.ASIZE-1:0];
// assign wdata        = cfg_inf.wdata;
// assign cfg_inf.default_value  = default_value[cfg_inf.DSIZE-1:0];
// assign cfg_inf.rdata = rdata[cfg_inf.DSIZE-1:0];
// assign cfg_inf.rst   = rst[0];
// assign cfg_inf.interrupt_enable     = 1'b0;
// assign cfg_inf.interrupt_trigger    = 1'b0;
// endmodule:CFG_REG_A1

module CFG_REG_INTR (
    common_configure_reg_interface.slaver  cfg_inf,
    input int                       addr,
    output int                      wdata,
    input int                       default_value,
    input int                       rdata,
    input int                       rst,
    input logic                     interrupt_trigger
);

assign cfg_inf.addr = addr[cfg_inf.ASIZE-1:0];
assign wdata        = cfg_inf.wdata;
assign cfg_inf.default_value  = default_value[cfg_inf.DSIZE-1:0];
assign cfg_inf.rdata = rdata[cfg_inf.DSIZE-1:0];
assign cfg_inf.rst   = rst[0];
assign cfg_inf.interrupt_enable     = 1'b1;
assign cfg_inf.interrupt_trigger    = interrupt_trigger;

endmodule:CFG_REG_INTR

module general_reg (
    common_configure_reg_interface.slaver  cfg_inf,
    input int                       addr,
    output int                      data,
    input int                       default_value
);

CFG_REG  CFG_REG_INST(
/*    common_configure_reg_interface.slaver */ .cfg_inf (cfg_inf    ),
/*    input int                     */  .addr           (addr       ),
/*    output [cfg_inf.DSIZE-1:0]    */  .wdata          (data       ),
/*    input int                     */  .default_value  (default_value),
/*    input int                     */  .rdata          (data       ),
/*    input int                     */  .rst            (0          )
);

endmodule:general_reg

module general_reg_intr (
    common_configure_reg_interface.slaver  cfg_inf,
    input int                       addr,
    output int                      data,
    input int                       default_value,
    input                           interrupt_trigger
);

CFG_REG_INTR  CFG_REG_INST(
/*    common_configure_reg_interface.slaver */ .cfg_inf (cfg_inf    ),
/*    input int                     */  .addr           (addr       ),
/*    output [cfg_inf.DSIZE-1:0]    */  .wdata          (data       ),
/*    input int                     */  .default_value  (default_value),
/*    input int                     */  .rdata          (data       ),
/*    input int                     */  .rst            ('0          ),
/*    input                         */  .interrupt_trigger  (interrupt_trigger  )
);

endmodule:general_reg_intr

module general_only_read_reg #(
    parameter   DSIZE = 32
)(
    common_configure_reg_interface.slaver  cfg_inf,
    input int                       addr,
    input [DSIZE-1:0]               rdata
);

CFG_REG #(DSIZE) CFG_REG_INST(
/*    common_configure_reg_interface.slaver */ .cfg_inf (cfg_inf    ),
/*    input int                     */  .addr           (addr       ),
/*    output nit                    */  .wdata          (           ),
/*    input int                     */  .default_value  ('0         ),
/*    input int                     */  .rdata          (rdata      ),
/*    input int                     */  .rst            ('0         )
);

endmodule:general_only_read_reg

module general_only_read_reg_intr (
    common_configure_reg_interface.slaver  cfg_inf,
    input int                       addr,
    input int                       rdata,
    input                           interrupt_trigger
);

CFG_REG_INTR  CFG_REG_INST(
/*    common_configure_reg_interface.slaver */ .cfg_inf (cfg_inf    ),
/*    input int                     */  .addr           (addr       ),
/*    output nit                    */  .wdata          (           ),
/*    input int                     */  .default_value  ('0          ),
/*    input int                     */  .rdata          (rdata      ),
/*    input int                     */  .rst            ('0          ),
/*    input                         */  .interrupt_trigger  (interrupt_trigger)
);

endmodule:general_only_read_reg_intr

module general_pulse(
    common_configure_reg_interface.slaver  cfg_inf,
    input int                       addr,
    output                          data
);

int     wdata;
assign  data = wdata[0];

CFG_REG  CFG_REG_inst(
/*    common_configure_reg_interface.slaver */ .cfg_inf (cfg_inf    ),
/*    input int                     */  .addr           (addr       ),
/*    output int                    */  .wdata          (wdata      ),
/*    input int                     */  .default_value  ('0          ),
/*    input int                     */  .rdata          ('0          ),
/*    input int                     */  .rst            (data       )
);

endmodule:general_pulse
