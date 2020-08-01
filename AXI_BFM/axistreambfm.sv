/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2016/8/21 
madified:
***********************************************/
`timescale 1ns / 1ps
// package AxiBfmPkg;
module AxiStreamBfm #(
    parameter DSIZE = 16
)(
    axi_stream_inf.master inf,
    axi_stream_inf.slaver sinf
);

logic   clock;
logic   rst_n;

// logic [DSIZE-1:0]   data_queue [$];
// logic               last_queue [$];

assign clock = inf.aclk;
assign rst_n = inf.aresetn;

// logic[DSIZE-1:0]       axis_tdata    ;
// logic                  axis_tvalid   ;
// logic                  axis_tready   ;
// logic                  axis_tuser    ;
// logic                  axis_tlast    ;
// logic[DSIZE/8-1:0]     axis_tkeep    ;
int cnt;

task automatic gen_axi_stream (
    int                    length,
    int                    valid_ramdon_percent,
    ref  [DSIZE-1:0] data_s [$]

);
int     index;
int     cc = 0;
int     data_len;
int     rt;
logic [DSIZE-1:0]   data_ss[$];
logic[DSIZE-1:0]    curr_data;

    data_len = data_s.size();
    cc=0;
    repeat(length)begin
        index = cc%data_len;
        data_ss[cc] = data_s[index];
        cc++;
    end
    $display("__________________________________");
    $display("GEN AXI STREAM LEN = %d",data_len);
    while(1)begin
        @(posedge clock);
        #1;
        rt = $urandom_range(99,0);
        inf.axis_tvalid = (rt < valid_ramdon_percent);
        if(inf.axis_tvalid && inf.axis_tready)
            inf.axis_tdata  = data_ss.size() != 0? data_ss.pop_front : inf.axis_tdata;
        inf.axis_tlast  = data_ss.size() == 0;
        if(inf.axis_tlast)begin
            forever begin
            @(negedge clock);
            if (inf.axis_tready)
                break;
            end
            break;
        end
    end

    $display("==================================");
endtask:gen_axi_stream

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cnt     <= 0;
    else begin
        if(inf.axis_tvalid && inf.axis_tready && inf.aclken)begin
            if(inf.axis_tlast)
                    cnt     <= 0;
            else    cnt     <= cnt + 1'b1;
        end else    cnt     <= cnt;
    end

task automatic reset_stream;
    @(posedge clock);
    fork
        inf.axis_tvalid = #1 0;
        inf.axis_tlast  = #1 0;
        inf.axis_tdata  = #1 0;
    join
endtask:reset_stream

task automatic gen_axi_stream_ready(
    int     ready_ramdon_percent
);
int rt;
    forever begin
    rt = $urandom_range(99,0);
        @(posedge clock);
        sinf.axis_tready    = #1 (rt < ready_ramdon_percent);
    end
endtask:gen_axi_stream_ready
//
// task automatic push_queue(input [DSIZE-1:0] data [$],input dlast[$]);
//     data



endmodule:AxiStreamBfm

// endpackage:AxiBfmPkg
