/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:   covert A to B
author : Cook.Darwin
Version: VERA.0.0
creaded: ###### Mon Jul 13 16:41:19 CST 2020
madified:
***********************************************/
`timescale 1ns/1ps
(* data_inf_c = "true" *)
module data_c_pipe_force_vld_bind_data #(
    parameter   DSIZE = 32,
    parameter   HEAD_MODE = "ON",        // data in master.head
    parameter   SYNC = "master"
)(
    input [DSIZE-1:0]           data,   //sync master
    data_inf_c.slaver           slaver,
    data_inf_c.master           master
);

initial begin
    assert(slaver.DSIZE+DSIZE == master.DSIZE)
    else begin
        $error("slaver DSIZE<%0d>+DSIZE<%0d> != master DSIZE<%0d>",slaver.DSIZE,DSIZE,master.DSIZE);
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

logic[slaver.DSIZE-1:0] master_origin_data;

generate
    if(SYNC=="SLAVER") begin 
        always@(posedge clock,negedge rst_n)
            if(~rst_n)  master.data    <= '0;
            else begin
                if(slaver.valid && slaver.ready)begin 
                    if(HEAD_MODE=="ON" || HEAD_MODE=="TRUE")
                            master.data    <= {data,slaver.data};
                    else    master.data    <= {slaver.data,data};
                end else if(master.valid && master.ready)
                        master.data    <= '0;
                else    master.data    <= master.data;
            end
    end else begin 
        always@(posedge clock,negedge rst_n)
            if(~rst_n)   master_origin_data  <= '0;
            else begin 
                if(slaver.valid && slaver.ready)begin 
                    if(HEAD_MODE=="ON" || HEAD_MODE=="TRUE")
                            master_origin_data    <= slaver.data;
                    else    master_origin_data    <= slaver.data;
                end else if(master.valid && master.ready)
                        master_origin_data    <= '0;
                else    master_origin_data    <= master_origin_data;
            end

        assign  master.data = (HEAD_MODE=="ON" || HEAD_MODE=="TRUE") ? {data,master_origin_data} : {master_origin_data,data};
    end
endgenerate

endmodule
