/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/7/31 
madified:
***********************************************/
`timescale 1ns/1ps
`include "define_macro.sv"
(* axi_stream = "true" *)
module axis_mirrors #(
    parameter H     = 0,
    parameter L     = 0,
    parameter NUM   = 8,
    `parameter_string MODE  = "CDS_MODE"        //(* show = "true" *)//CDS_MODE FULL_MODE
)(
    input [H:L]                   condition_data,
    (* axis_up = "true" *)
    axi_stream_inf.slaver         axis_in,
    (* axis_down = "true" *)
    axi_stream_inf.master         axis_mirror [NUM-1:0]
);

logic   clock,rst_n;
assign  clock   = axis_in.aclk;
assign  rst_n   = axis_in.aresetn;


data_inf_c #(axis_in.DSIZE+1) data_in                (clock,rst_n);
data_inf_c #(axis_in.DSIZE+1) data_mirror[NUM-1:0]   (clock,rst_n);

data_mirrors #(
    .H      (H      ),
    .L      (L      ),
    .NUM    (NUM    ),
    .MODE   (MODE   )        //(* show = "true" *)//CDS_MODE FULL_MODE
)data_mirrors_iinst(
/*  input [H:L]        */    .condition_data        (condition_data ),
/*  data_inf_c.slaver  */    .data_in               (data_in        ),
/*  data_inf_c.master  */    .data_mirror           (data_mirror    )//[NUM-1:0]
);

assign data_in.valid    = axis_in.axis_tvalid;
assign data_in.data     = {axis_in.axis_tlast,axis_in.axis_tdata};
assign axis_in.axis_tready  = data_in.ready;

genvar CC;
generate
for(CC=0;CC<NUM;CC++)begin
assign axis_mirror[CC].axis_tvalid    = data_mirror[CC].valid;
assign axis_mirror[CC].axis_tdata     = data_mirror[CC].data[axis_in.DSIZE-1:0];
assign axis_mirror[CC].axis_tlast     = data_mirror[CC].data[axis_in.DSIZE];
assign data_mirror[CC].ready          = axis_mirror[CC].axis_tready;
end
endgenerate

endmodule
