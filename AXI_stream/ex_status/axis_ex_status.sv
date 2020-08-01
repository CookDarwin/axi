/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.1 2018/1/25 
    add axis_tuser
creaded: 2017/9/14 
madified:
***********************************************/
`timescale 1ns/1ps
module axis_ex_status #(
    parameter ESIZE = 1
)(
    input [ESIZE-1:0]          origin_status,
    output logic[ESIZE-1:0]    binding_status,
    (* up_stream = "true" *)
    axi_stream_inf.slaver      axis_in,
    (* down_stream = "true" *)
    axi_stream_inf.master      axis_out
);

assign axis_in.axis_tready  = axis_out.axis_tready;

initial begin
    assert(axis_out.DSIZE == axis_in.DSIZE)
    else $error("AXIS_EX_STATUS stream dsize is not same\n");
end

logic       clock;
logic       rst_n;

assign  clock   = axis_in.aclk;
assign  rst_n   = axis_in.aresetn;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_out.axis_tdata <='0;
    else begin
        if(axis_in.axis_tvalid && axis_in.axis_tready)
                axis_out.axis_tdata <= axis_in.axis_tdata;
        else if(axis_out.axis_tvalid && axis_out.axis_tready)
                axis_out.axis_tdata <= '0;
        else    axis_out.axis_tdata <= axis_out.axis_tdata;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_out.axis_tkeep <='0;
    else begin
        if(axis_in.axis_tvalid && axis_in.axis_tready)
                axis_out.axis_tkeep <= axis_in.axis_tkeep;
        else if(axis_out.axis_tvalid && axis_out.axis_tready)
                axis_out.axis_tkeep <= '0;
        else    axis_out.axis_tkeep <= axis_out.axis_tkeep;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_out.axis_tvalid <='0;
    else begin
        if(axis_in.axis_tvalid && axis_in.axis_tready)
                axis_out.axis_tvalid <= 1'b1;
        else if(axis_out.axis_tvalid && axis_out.axis_tready)
                axis_out.axis_tvalid <= '0;
        else    axis_out.axis_tvalid <= axis_out.axis_tvalid;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_out.axis_tlast <='0;
    else begin
        if(axis_in.axis_tvalid && axis_in.axis_tready)
                axis_out.axis_tlast <= axis_in.axis_tlast;
        else if(axis_out.axis_tvalid && axis_out.axis_tready && axis_out.axis_tlast)
                axis_out.axis_tlast <= '0;
        else    axis_out.axis_tlast <= axis_out.axis_tlast;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_out.axis_tuser <='0;
    else begin
        if(axis_in.axis_tvalid && axis_in.axis_tready)
                axis_out.axis_tuser <= axis_in.axis_tuser;
        else if(axis_out.axis_tvalid && axis_out.axis_tready)
                axis_out.axis_tuser <= '0;
        else    axis_out.axis_tuser <= axis_out.axis_tuser;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  binding_status <='0;
    else begin
        if(axis_in.axis_tvalid && axis_in.axis_tready)
                binding_status <= origin_status;
        else if(axis_out.axis_tvalid && axis_out.axis_tready)
                binding_status <= '0;
        else    binding_status <= binding_status;
    end

endmodule
