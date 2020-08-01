/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/22 
madified:
***********************************************/
`timescale 1ns/1ps
import DataInterfacePkg::*;
(* axi_stream = "true" *)
module axi_stream_partition (
    input                      valve,               // [1] open [0] close
    input [31:0]               partition_len,       //[0] mean 1 len
    output logic               req_new_len,         //it is usefull, when last stream length is only one
    (* up_stream = "true" *)
    axi_stream_inf.slaver      axis_in,
    (* down_stream = "true" *)
    axi_stream_inf.master      axis_out
);


wire        clock,rst_n,clk_en;
assign      clock   = axis_in.aclk;
assign      rst_n   = axis_in.aresetn;
assign      clk_en  = axis_in.aclken;

// localparam  DSIZE = ;

axi_stream_inf #(
   .DSIZE       (axis_in.DSIZE )
)axis_valve(
   .aclk        (clock            ),
   .aresetn     (rst_n            ),
   .aclken      (clk_en           )
);


axis_valve axis_valve_inst(
/*    input                   */   .button          (valve      ),
/*    axi_stream_inf.slaver   */   .axis_in         (axis_valve ),
/*    axi_stream_inf.master   */   .axis_out        (axis_out   )
);

assign axis_in.axis_tready  = axis_valve.axis_tready;

logic [31:0]    bcnt;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  bcnt    <= '0;
    else begin
        if(axis_valve.axis_tready && axis_valve.axis_tvalid && axis_valve.aclken && axis_valve.axis_tlast)
                bcnt    <= '0;
        else if(axis_valve.axis_tready && axis_valve.axis_tvalid && axis_valve.aclken)
            if(bcnt == (partition_len-1))
                    bcnt    <= '0;
            else    bcnt    <= bcnt+1'b1;
        else
            bcnt   <= bcnt;
    end

logic body_new_last;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_valve.axis_tvalid    <= 1'b0;
    else begin
        axis_valve.axis_tvalid    <= pipe_valid_func(axis_in.axis_tvalid,axis_valve.axis_tready,axis_valve.axis_tvalid);
        // if(axis_in.axis_tvalid && axis_in.axis_tready)
        //         axis_valve.axis_tvalid  <= 1'b1;
        // else if(axis_valve.axis_tvalid && axis_valve.axis_tready)
        //         axis_valve.axis_tvalid  <= 1'b0;
        // else    axis_valve.axis_tvalid  <= axis_valve.axis_tvalid;
    end

logic   last_record;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  last_record <= 1'b0;
    else begin
        if(axis_valve.axis_tready && axis_valve.axis_tvalid && axis_valve.aclken && axis_valve.axis_tlast)
                last_record <= 1'b0;
        else if(axis_in.axis_tready && axis_in.axis_tvalid && axis_in.aclken && axis_in.axis_tlast)
                last_record <= 1'b1;
        else    last_record <= last_record;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  body_new_last   <= 1'b0;
    else begin
        // if(last_record)
        //         body_new_last   <= 1'b1;
        // else
        if(axis_in.axis_tready && axis_in.axis_tvalid && axis_in.aclken && axis_in.axis_tlast)
                body_new_last   <= 1'b1;
        else if(axis_valve.axis_tready && axis_valve.axis_tvalid && axis_valve.aclken && (bcnt == (partition_len-1)) )
                body_new_last   <= 1'b1;
        else if(axis_valve.axis_tready && axis_valve.axis_tvalid && axis_valve.aclken && body_new_last)
                body_new_last   <= 1'b0;
        else    body_new_last   <= body_new_last;
    end

assign  axis_valve.axis_tlast = body_new_last;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_valve.axis_tdata = '0;
    else begin
        if(axis_in.DSIZE>axis_valve.DSIZE)
            // axis_valve.axis_tdata[0]  <= pipe_data_func(axis_in.axis_tvalid,axis_valve.axis_tready,axis_valve.axis_tvalid,axis_valve.axis_tdata[0]);
            foreach(axis_valve.axis_tdata[i])
                axis_valve.axis_tdata[i]  <= pipe_data_func(axis_in.axis_tvalid,axis_valve.axis_tready,axis_valve.axis_tvalid,axis_in.axis_tdata[i],axis_valve.axis_tdata[i]);
        else
            // axis_valve.axis_tdata[0]  <= pipe_data_func(axis_in.axis_tvalid,axis_valve.axis_tready,axis_valve.axis_tvalid,axis_valve.axis_tdata[0]);
            foreach(axis_in.axis_tdata[i])
                axis_valve.axis_tdata[i]  <= pipe_data_func(axis_in.axis_tvalid,axis_valve.axis_tready,axis_valve.axis_tvalid,axis_in.axis_tdata[i],axis_valve.axis_tdata[i]);
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_valve.axis_tkeep = '0;
    else begin
        if(axis_in.DSIZE>axis_valve.DSIZE)
            foreach(axis_valve.axis_tkeep[i])
                axis_valve.axis_tkeep[i]  <= pipe_data_func(axis_in.axis_tvalid,axis_valve.axis_tready,axis_valve.axis_tvalid,axis_valve.axis_tkeep[i],axis_valve.axis_tkeep[i]);
        else
            foreach(axis_in.axis_tdata[i])
                axis_valve.axis_tkeep[i]  <= pipe_data_func(axis_in.axis_tvalid,axis_valve.axis_tready,axis_valve.axis_tvalid,axis_valve.axis_tkeep[i],axis_valve.axis_tkeep[i]);
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_valve.axis_tuser = '0;
    else begin
            axis_valve.axis_tuser  <= pipe_data_func(axis_in.axis_tvalid,axis_valve.axis_tready,axis_valve.axis_tvalid,axis_valve.axis_tuser,axis_valve.axis_tuser);
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  req_new_len <= 1'b0;
    else begin
        if(axis_valve.axis_tready && axis_valve.axis_tvalid && axis_valve.aclken)
            if(bcnt == (partition_len-2))
                    req_new_len <= 1'b1;
            else    req_new_len <= 1'b0;
        else
            req_new_len <= 1'b0;
    end

endmodule
