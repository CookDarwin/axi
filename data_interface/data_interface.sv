/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version:
creaded: 2016/9/22 
madified:
***********************************************/
interface data_inf #(
    parameter DSIZE = 8
)(

);

logic                   valid   ;
logic                   ready   ;
logic[DSIZE-1:0]        data    ;
logic                   vld_rdy ;

assign vld_rdy  = valid && ready;

modport master (
output  valid,
output  data,
input   ready,
input   vld_rdy
);

modport slaver (
input   valid,
input   data,
output  ready,
input   vld_rdy
);

endinterface : data_inf

interface data_inf_c #(
    parameter DSIZE = 8,
    parameter real FreqM    = 1
)(
    input bit   clock,
    input bit   rst_n
);

logic                   valid   ;
logic                   ready   ;
logic[DSIZE-1:0]        data    ;
logic                   vld_rdy;

assign vld_rdy  = valid && ready;

modport master (
input   clock,
input   rst_n,
output  valid,
output  data,
input   ready,
input   vld_rdy
);

modport slaver (
input   clock,
input   rst_n,
input   valid,
input   data,
output  ready,
input   vld_rdy
);

modport mirror (
input   clock,
input   rst_n,
input   valid,
input   data,
input   ready,
input   vld_rdy
);

modport out_mirror (
input   clock,
input   rst_n,
output  valid,
output  data,
output  ready,
input   vld_rdy
);

endinterface:data_inf_c
