/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.1.0
    can set init value
creaded: 2017/2/28 
madified:
***********************************************/
`timescale 1ns/1ps
(* datainf = "true" *)
module independent_clock_fifo_a1 #(
    parameter DEPTH     = 4,
    parameter DSIZE     = 8,
    parameter [DSIZE-1:0] INIT_VALUE = 0,
    //(* show = "false" *)
    parameter PSIZE     = $clog2(DEPTH)
)(
    input                       wr_clk,
    input                       wr_rst_n,
    input                       rd_clk,
    input                       rd_rst_n,
    input [DSIZE-1:0]           wdata,
    input                       wr_en,
    output logic[DSIZE-1:0]     rdata,
    input                       rd_en,
    output logic                empty,
    output logic                full
);

logic       rst_n;

assign  rst_n   = wr_rst_n && rd_rst_n;

import DataInterfacePkg::*;

logic   data_array_empty;
logic   tap_req_rd_en;

logic   wr_data_array_vld;
assign  wr_data_array_vld   = wr_en && !full;

logic   req_data_array_vld;
assign  req_data_array_vld   = tap_req_rd_en && !data_array_empty;
//--->> WPOINT <<------------------------
logic [PSIZE-1:0]       wpoint;
logic [PSIZE-1:0]       wpoint_pre2;
logic [PSIZE-1:0]       wpoint_pre1;

always@(posedge wr_clk,negedge rst_n)
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

always@(posedge wr_clk,negedge rst_n)
    if(~rst_n)  wpoint_pre2  <= 2;
    else begin
        if(!full)begin
            if(wr_en)begin
                if(wpoint+2 < (DEPTH-1))
                        wpoint_pre2  <= wpoint + 2'd3;
                else    wpoint_pre2  <= wpoint + 2'd3-DEPTH;
            end else    wpoint_pre2  <= wpoint_pre2;
        end else    wpoint_pre2  <= wpoint_pre2;
    end

always@(posedge wr_clk,negedge rst_n)
    if(~rst_n)  wpoint_pre1  <= 1;
    else begin
        if(!full)begin
            if(wr_en)begin
                if(wpoint+1< (DEPTH-1))
                        wpoint_pre1  <= wpoint + 2'd2;
                else    wpoint_pre1  <= wpoint + 2'd2-DEPTH;
            end else    wpoint_pre1  <= wpoint_pre1;
        end else    wpoint_pre1  <= wpoint_pre1;
    end
//---<< WPOINT >>------------------------
//--->> RPOINT <<------------------------
logic [PSIZE-1:0]       rpoint;
logic [PSIZE-1:0]       rpoint_pre1;

always@(posedge rd_clk,negedge rst_n)
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

always@(posedge rd_clk,negedge rst_n)
    if(~rst_n)  rpoint_pre1  <= 1;
    else begin
        if(!data_array_empty)begin
            if(tap_req_rd_en)begin
                if(rpoint+1 < (DEPTH-1))
                        rpoint_pre1  <= rpoint + 2'd2;
                else    rpoint_pre1  <= rpoint + 2'd2 - DEPTH;
            end else    rpoint_pre1  <= rpoint_pre1;
        end else    rpoint_pre1  <= rpoint_pre1;
    end

//---<< RPOINT >>------------------------
//--->> FLAG    <<-----------------------
logic [DEPTH-1:0]       wr_flag;
logic [DEPTH-1:0]       rd_flag;

always@(posedge wr_clk,negedge rst_n)
    if(~rst_n)  wr_flag <= '0;
    else begin
        if(wr_data_array_vld)
                wr_flag[wpoint] <= ~wr_flag[wpoint];
        else    wr_flag[wpoint] <= wr_flag[wpoint];
    end

always@(posedge rd_clk,negedge rst_n)
    if(~rst_n)  rd_flag <= '0;
    else begin
        if(req_data_array_vld)
                rd_flag[rpoint] <= ~rd_flag[rpoint];
        else    rd_flag[rpoint] <=  rd_flag[rpoint];
    end
//---<< FLAG    >>-----------------------
//--->> FULL <<--------------------------

always@(posedge wr_clk,negedge rst_n)
    // if(~rst_n)  full    <= 1'b0;
    if(~rst_n)  full    <= 1'b1;
    else begin
        if(wr_data_array_vld)begin
            if(wr_flag[wpoint_pre1] != rd_flag[wpoint_pre1])
                    full    <= 1'b1;
            else    full    <= 1'b0;
        end else if(wr_flag[wpoint] != rd_flag[wpoint])begin
                    full    <= 1'b1;
        end else    full    <= 1'b0;
    end
//---<< FULL >>--------------------------
//--->> data_array_empty <<-------------------------
always@(posedge rd_clk,negedge rst_n)
    if(~rst_n)  data_array_empty   <= 1'b1;
    else begin
        if(req_data_array_vld)begin
            if(wr_flag[rpoint_pre1] == rd_flag[rpoint_pre1])
                    data_array_empty    <= 1'b1;
            else    data_array_empty    <= 1'b0;
        end else if(wr_flag[rpoint] == rd_flag[rpoint])begin
                    data_array_empty   <= 1'b1;
        end else    data_array_empty   <= 1'b0;
    end
//---<< data_array_empty >>-------------------------
//--->> DATA ARRAY <<--------------------
logic [DSIZE-1:0]   data_array [DEPTH-1:0];

always@(posedge wr_clk,negedge rst_n)
    if(~rst_n)
        foreach(data_array[i])
            data_array[i]   <= INIT_VALUE[DSIZE-1:0];
    else begin
        if(wr_en && !full)
                data_array[wpoint]  <= wdata;
        else    data_array[wpoint]  <= data_array[wpoint];
    end

always@(posedge rd_clk,negedge rst_n)
    if(~rst_n)  rdata   <= INIT_VALUE[DSIZE-1:0];
    else begin
        if(tap_req_rd_en && !data_array_empty)
                rdata   <= data_array[rpoint];
        else    rdata   <= rdata;
    end
//---<< DATA ARRAY >>--------------------
//--->> PIPE TAP <<----------------------
// logic   tap_req_rd_en;
logic   tap_vld;

always@(posedge rd_clk,negedge rst_n)
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
