/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.1.0 2019/7/1 
    compcat data
creaded: 2018-4-11 15:54:02
madified:
***********************************************/
`timescale 1ns/1ps
module trigger_data_inf_c_A1 #(
    parameter DSIZE = 32
)(
    input               trigger,
    input [DSIZE-1:0]   data,
    data_inf_c.master   trigger_inf
);

initial begin
    assert(DSIZE == trigger_inf.DSIZE)
    else begin
        $error(" `trigger_data_inf_c` DSIZE[%d] != DSIZE[%d]",trigger_inf.DSIZE,DSIZE);
        $stop;
    end
end

logic   clock,rst_n;

assign  clock   = trigger_inf.clock;
assign  rst_n   = trigger_inf.rst_n;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  trigger_inf.valid   <= 1'b0;
    else begin
        if(trigger_inf.valid && trigger_inf.ready)
                trigger_inf.valid   <= 1'b0;
        else if(trigger)
                trigger_inf.valid   <= 1'b1;
        else    trigger_inf.valid   <= trigger_inf.valid;
    end

// always@(posedge clock,negedge rst_n)
//     if(~rst_n)  trigger_inf.data    <= '0;
//     else begin
//         if(trigger)
//                 trigger_inf.data    <= data;
//         else    trigger_inf.data    <= trigger_inf.data;
//     end

assign trigger_inf.data = data;

endmodule
