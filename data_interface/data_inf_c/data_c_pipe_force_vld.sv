/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:   covert A to B
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/12/28 
madified:
***********************************************/
`timescale 1ns/1ps
(* data_inf_c = "true" *)
module data_c_pipe_force_vld (
    (* data_up = "true" *)
    data_inf_c.slaver           slaver,
    (* data_down = "true" *)
    data_inf_c.master           master
);

initial begin
    assert(slaver.DSIZE == master.DSIZE)
    else begin
        $error("slaver DSIZE[%d] != master DSIZE[%d]",slaver.DSIZE,master.DSIZE);
        $stop;
    end
end

logic   clock;
logic   rst_n;

assign  clock   = slaver.clock;
assign  rst_n   = slaver.rst_n;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  master.valid    <= 1'b0;
    else begin
        if(slaver.valid && slaver.ready)
                master.valid    <= 1'b1;
        else if(master.valid && master.ready)
                master.valid    <= 1'b0;
        else    master.valid    <= master.valid;
    end

assign slaver.ready = !master.valid || master.ready;


always@(posedge clock,negedge rst_n)
    if(~rst_n)  master.data    <= '0;
    else begin
        if(slaver.valid && slaver.ready)
                master.data    <= slaver.data;
        else if(master.valid && master.ready)
                master.data    <= '0;
        else    master.data    <= master.data;
    end

endmodule
