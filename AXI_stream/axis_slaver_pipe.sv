/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/10/11 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_slaver_pipe (
    (* up_stream = "true" *)
    axi_stream_inf.slaver      axis_in,
    (* down_stream = "true" *)
    axi_stream_inf.master      axis_out
);

assign axis_in.axis_tready  = axis_out.axis_tready; //very importemt

import SystemPkg::*;

initial begin
    assert(axis_in.DSIZE == axis_out.DSIZE)
    else $error("SLAVER AXIS DSIZE != MASTER AXIS DSIZE");
end

wire    clock,rst_n;

assign  clock   = axis_in.aclk;
assign  rst_n   = axis_in.aresetn;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_out.axis_tdata <= '0;
    else begin
        if(axis_in.axis_tvalid && axis_in.axis_tready)
                axis_out.axis_tdata <= axis_in.axis_tdata;
        else if(axis_out.axis_tvalid && axis_out.axis_tready)
                axis_out.axis_tdata <= '0;
        else    axis_out.axis_tdata <= axis_out.axis_tdata;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_out.axis_tvalid <= '0;
    else begin
        if(axis_in.axis_tvalid && axis_in.axis_tready)
                axis_out.axis_tvalid <= 1'b1;
        else if(axis_out.axis_tvalid && axis_out.axis_tready)
                axis_out.axis_tvalid <= '0;
        else    axis_out.axis_tvalid <= axis_out.axis_tvalid;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_out.axis_tlast <= '0;
    else begin
        if(axis_in.axis_tvalid && axis_in.axis_tready)
                axis_out.axis_tlast <= axis_in.axis_tlast;
        else if(axis_out.axis_tvalid && axis_out.axis_tready)
                axis_out.axis_tlast <= '0;
        else    axis_out.axis_tlast <= axis_out.axis_tlast;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_out.axis_tkeep <= '1;
    else begin
        if(axis_in.axis_tvalid && axis_in.axis_tready)
                axis_out.axis_tkeep <= axis_in.axis_tkeep;
        else if(axis_out.axis_tvalid && axis_out.axis_tready)
                axis_out.axis_tkeep <= '1;
        else    axis_out.axis_tkeep <= axis_out.axis_tkeep;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_out.axis_tuser <= '0;
    else begin
        if(axis_in.axis_tvalid && axis_in.axis_tready)
                axis_out.axis_tuser <= axis_in.axis_tuser;
        else if(axis_out.axis_tvalid && axis_out.axis_tready)
                axis_out.axis_tuser <= '0;
        else    axis_out.axis_tuser <= axis_out.axis_tuser;
    end

endmodule
