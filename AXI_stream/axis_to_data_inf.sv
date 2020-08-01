/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.1 2018-4-13 16:35:20
    add CONTAIN_LAST
creaded: 2017/3/20 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_to_data_inf #(
    parameter CONTAIN_LAST = "OFF"
)(
    axi_stream_inf.slaver  axis_in,
    data_inf_c.master      data_out_inf
);

generate
    if(CONTAIN_LAST=="ON" || CONTAIN_LAST=="TRUE")
        assign  data_out_inf.data   = {axis_in.axis_tlast,axis_in.axis_tdata[data_out_inf.DSIZE-2:0]};
    else begin 
        if(data_out_inf.DSIZE <= axis_in.DSIZE)
                assign  data_out_inf.data   = axis_in.axis_tdata[data_out_inf.DSIZE-1:0];
        else    assign  data_out_inf.data   = axis_in.axis_tdata;
    end
endgenerate

assign  data_out_inf.valid  = axis_in.axis_tvalid;
assign  axis_in.axis_tready = data_out_inf.ready;

endmodule
