/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/27 
madified:
***********************************************/
`timescale 1ns/1ps
(* datainf = "true" *)
module common_fifo #(
    parameter DEPTH     = 4,
    parameter DSIZE     = 8,
    //(* show = "false" *)
    parameter PSIZE     = $clog2(DEPTH),
    parameter CSIZE     = $clog2(DEPTH+1)
)(
    input                       clock,
    input                       rst_n,
    input [DSIZE-1:0]           wdata,
    input                       wr_en,
    output logic[DSIZE-1:0]     rdata,
    input                       rd_en,
    output logic[CSIZE-1:0]     count,
    output logic                empty,
    output logic                full
);
import DataInterfacePkg::*;

logic   data_array_empty;
logic   tap_req_rd_en;
//--->> WPOINT <<------------------------
logic [PSIZE-1:0]       wpoint;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  wpoint  <= '0;
    else begin
        if(!full)begin
            if(wr_en)begin
                if(wpoint < (DEPTH-1))
                        wpoint  <= wpoint + 1'b1;
                else    wpoint  <= '0;
            end else    wpoint  <= wpoint;
        end else    wpoint  <= wpoint;
    end

//---<< WPOINT >>------------------------
//--->> RPOINT <<------------------------
logic [PSIZE-1:0]       rpoint;

always@(posedge clock,negedge rst_n)
    if(~rst_n) rpoint   <= '0;
    else begin
        if(!data_array_empty)begin
            if(tap_req_rd_en)begin
                if(rpoint < (DEPTH-1))
                        rpoint  <= rpoint + 1'b1;
                else    rpoint  <= '0;
            end else    rpoint  <= rpoint;
        end else    rpoint  <= rpoint;
    end
//---<< RPOINT >>------------------------
//--->> FULL <<--------------------------
logic   wr_data_array_vld;

assign  wr_data_array_vld   = wr_en && !full;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  full    <= 1'b0;
    else begin
        if(wr_data_array_vld && !tap_req_rd_en)begin
            if((wpoint+2==rpoint) && (wpoint+2 <= (DEPTH-1) ))
                    full    <= 1'b1;
            else if((wpoint+2-(DEPTH)==rpoint) && (wpoint+2 > (DEPTH-1) ))
                    full    <= 1'b1;
            else    full    <= full;
        end else if(!wr_data_array_vld && tap_req_rd_en)begin
            if(full)
                    full    <= 1'b0;
            else    full    <= full;
        end else    full    <= full;
    end
//---<< FULL >>--------------------------
//--->> data_array_empty <<-------------------------
logic   req_data_array_vld;

assign  req_data_array_vld   = tap_req_rd_en && !data_array_empty;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  data_array_empty   <= 1'b1;
    else begin
        if(!wr_en && req_data_array_vld)begin
            if((rpoint+1==wpoint) && (rpoint+1 <= (DEPTH-1) ))
                    data_array_empty    <= 1'b1;
            else if((rpoint+1-(DEPTH)==wpoint) && (rpoint+1 > (DEPTH-1) ))
                    data_array_empty    <= 1'b1;
            else    data_array_empty    <= data_array_empty;
        end else if(wr_en && !req_data_array_vld)begin
            if(data_array_empty)
                    data_array_empty   <= 1'b0;
            else    data_array_empty   <= data_array_empty;
        end else    data_array_empty   <= data_array_empty;
    end
//---<< data_array_empty >>-------------------------
//--->> COUNTER <<-----------------------
logic   rd_data_array_vld;

assign  rd_data_array_vld   = rd_en && !empty;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  count   <= '0;
    else begin
        if(wr_data_array_vld && !rd_data_array_vld)begin
            if(count == DEPTH)
                    count   <= count;
            else    count   <= count + 1'b1;
        end else if(!wr_data_array_vld && rd_data_array_vld)begin
            if(count == '0)
                    count   <= '0;
            else    count   <= count - 1'b1;
        end else if(!wr_data_array_vld && !rd_data_array_vld)
                count   <= count;
        else    count   <= count;
    end
//---<< COUNTER >>-----------------------
//--->> DATA ARRAY <<--------------------
logic [DSIZE-1:0]   data_array [DEPTH-1:0];

always@(posedge clock,negedge rst_n)
    if(~rst_n)
        foreach(data_array[i])
            data_array[i]   <= '0;
    else begin
        if(wr_en && !full)
                data_array[wpoint]  <= wdata;
        else    data_array[wpoint]  <= data_array[wpoint];
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  rdata   <= '0;
    else begin
        if(tap_req_rd_en && !data_array_empty)
                rdata   <= data_array[rpoint];
        else    rdata   <= rdata;
    end
//---<< DATA ARRAY >>--------------------
//--->> PIPE TAP <<----------------------
// logic   tap_req_rd_en;
logic   tap_vld;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  tap_vld   <= 1'b0;
    else begin
        tap_vld <= pipe_valid_func_force(!data_array_empty,rd_en,tap_vld);
    end

assign tap_req_rd_en = !tap_vld || (rd_en && tap_vld);
//---<< PIPE TAP >>----------------------
//--->> EMPTY <<----------------------
assign empty    = !tap_vld;
//---<< EMPTY >>----------------------

endmodule
