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
`include "define_macro.sv"
module axi_stream_planer #(
    parameter LAT   = 3,
    parameter DSIZE = 8,
    `parameter_string HEAD  = "FALSE"
)(
    input                 reset,
    input [DSIZE-1:0]     pack_data,
    axi_stream_inf.slaver axis_in,
    axi_stream_inf.master axis_out        ///HEAD=="ON" : {pack_data,slaver.data} or /HEAD=="OFF" : {slaver.data,pack_data}
);

data_inf_c #(.DSIZE(axis_in.DSIZE + 1)) data_slaver (.clock(axis_in.aclk), .rst_n(axis_in.aresetn) );
data_inf_c #(.DSIZE(axis_in.DSIZE + 1 + DSIZE)) data_master (.clock(axis_in.aclk), .rst_n(axis_in.aresetn) );


data_inf_c_planer_A1 #(
    .LAT        (LAT        ),
    .DSIZE      (DSIZE      ),
    .HEAD       ("FALSE"    )
)data_inf_c_planer_A1_inst(
/*  input             */ .reset         (reset      ),
/*  input [DSIZE-1:0] */ .pack_data     (pack_data  ),
/*  data_inf_c.slaver */ .slaver        (data_slaver    ),
/*  data_inf_c.master */ .master        (data_master    )///HEAD=="ON" : {pack_data,slaver.data} or /HEAD=="OFF" : {slaver.data,pack_data}
);

axis_to_data_inf #(
    .CONTAIN_LAST   ("ON")
)axis_to_data_inf_inst(
/*  axi_stream_inf.slaver  */ .axis_in      (axis_in        ),
/*  data_inf_c.master      */ .data_out_inf (data_slaver    )
);

data_c_to_axis_full data_c_to_axis_full_inst(
/* data_inf_c.slaver     */ .data_in_inf            (data_master    ),
/* axi_stream_inf.master */ .axis_out               (axis_out       )
);

endmodule