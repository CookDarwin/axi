/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018-4-17 12:18:15
madified:
***********************************************/
`timescale 1ns/1ps
`include "define_macro.sv"
(* axi_stream = "true" *)
module axis_link_trigger #(
    `parameter_string MODE  = "STREAM",     //STREAM,LAST
    parameter DSIZE = 32
)(
    axi_stream_inf.mirror       mirror,
    input [DSIZE-1:0]           data,
    data_inf_c.master           trigger_inf
);


initial begin
    assert(DSIZE == trigger_inf.DSIZE)
    else begin
        $error(" `axis_link_trigger` DSIZE[%d] != DSIZE[%d]",trigger_inf.DSIZE,DSIZE);
        $stop;
    end
    assert(MODE=="LAST" || MODE=="STREAM")
    else begin
        $error("`axis_link_trigger` MDOE NAME[%s] ERROR",MODE);
        $stop;
    end
end

logic   clock,rst_n;

assign  clock   = trigger_inf.clock;
assign  rst_n   = trigger_inf.rst_n;

logic   trigger;
logic   stream_idle;

generate
if(MODE=="LAST")
    assign trigger = mirror.axis_tvalid && mirror.axis_tready && mirror.axis_tlast;
else if(MODE=="STREAM")
    assign trigger = mirror.axis_tvalid && mirror.axis_tready && stream_idle;       //first byte
endgenerate


always@(posedge clock,negedge rst_n)
    if(~rst_n)  trigger_inf.valid   <= 1'b0;
    else begin
        if(trigger_inf.valid && trigger_inf.ready)
                trigger_inf.valid   <= 1'b0;
        else if(trigger)
                trigger_inf.valid   <= 1'b1;
        else    trigger_inf.valid   <= trigger_inf.valid;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  trigger_inf.data    <= '0;
    else begin
        if(trigger)
                trigger_inf.data    <= data;
        else    trigger_inf.data    <= trigger_inf.data;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  stream_idle <= 1'b1;
    else begin
        if(mirror.axis_tvalid && mirror.axis_tready && mirror.axis_tlast)
                stream_idle <= 1'b1;
        else if(mirror.axis_tvalid && mirror.axis_tready)
                stream_idle <= 1'b0;
        else    stream_idle <= stream_idle;
    end

endmodule
