/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/5/18 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_uncompress #(
    parameter   ASIZE = 8,          //ASIZE + LSIZE = AXIS DATA WIDTH
    parameter   LSIZE = 8
)(
    axi_stream_inf.slaver   axis_zip,          //ASIZE+LSIZE
    axi_stream_inf.master   axis_unzip       //ASIZE
);

import DataInterfacePkg::*;

logic   ready;

wire        clock,rst_n,clken;
assign      clock   = axis_zip.aclk;
assign      rst_n   = axis_zip.aresetn;
assign      clken   = axis_zip.aclken;

wire [ASIZE-1:0]    addr ;
wire [LSIZE-1:0]    cmd_len;

assign  addr    = axis_zip.axis_tdata[ASIZE+LSIZE-1:LSIZE];
assign  cmd_len = axis_zip.axis_tdata[LSIZE-1:0];


// typedef enum {IDLE,VLD_CTRL,}

//---->> RAM ADDRESS CTRL<<--------------------------
logic[LSIZE-1:0]    cnt;
logic               incr_addr;
logic               last_addr;
logic[LSIZE-1:0]    addr_len;

always@(posedge clock,negedge rst_n)
    if(~rst_n)      cnt     <= {LSIZE{1'b0}};
    else begin
        if(axis_zip.axis_tvalid && axis_zip.axis_tready && clken)
                    cnt     <= {LSIZE{1'b0}};
        else if(ready && incr_addr && clken)
                    cnt     <= cnt + 1'b1;
        else        cnt     <= cnt;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)      addr_len     <= {LSIZE{1'b0}};
    else begin
        if(axis_zip.axis_tvalid && axis_zip.axis_tready && clken)
                    addr_len     <= cmd_len;
        else        addr_len     <= addr_len;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  incr_addr   <= 1'b0;
    else begin
        if(axis_zip.axis_tvalid && axis_zip.axis_tready && cmd_len!={LSIZE{1'b0}} && clken)
                incr_addr   <= 1'b1;
        else if(cnt == (addr_len-1) && ready  && clken)
                incr_addr   <= 1'b0;
        else    incr_addr   <= incr_addr;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  last_addr   <= 1'b0;
    else begin
        if(cnt == (addr_len-1) && ready && clken)
                last_addr   <= 1'b1;
        else if(axis_zip.axis_tvalid && axis_zip.axis_tready && cmd_len=={LSIZE{1'b0}} && clken)      //burst one addr
                last_addr   <= 1'b1;
        else if(ready && clken)
                last_addr   <= 1'b0;
        else    last_addr   <= last_addr;
    end
//----<< RAM ADDRESS CTRL>>--------------------------
//---->> CONTROL READY <<------------------------
assign  axis_zip.axis_tready   = !incr_addr && ready;
//----<< CONTROL READY >>------------------------
logic       in_last_record;
always@(posedge clock,negedge rst_n)
    if(~rst_n)  in_last_record  <= 1'b0;
    else begin
        if(axis_zip.axis_tvalid && axis_zip.axis_tready && axis_zip.axis_tlast && cmd_len!={LSIZE{1'b0}} && clken)
                in_last_record  <= 1'b1;
        else if(axis_unzip.axis_tvalid && axis_unzip.axis_tready && axis_unzip.axis_tlast && clken)
                in_last_record  <= 1'b0;
        else    in_last_record  <= in_last_record;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_unzip.axis_tlast   <= 1'b0;
    else begin
        if(cnt == (addr_len-1) && ready && clken)
                axis_unzip.axis_tlast   <= in_last_record;
        else if(axis_zip.axis_tvalid && axis_zip.axis_tready && axis_zip.axis_tlast && cmd_len=={LSIZE{1'b0}} && clken)
                axis_unzip.axis_tlast   <= 1'b1;
        else if(axis_unzip.axis_tvalid && axis_unzip.axis_tready && axis_unzip.axis_tlast && clken)
                axis_unzip.axis_tlast   <= 1'b0;
        else    axis_unzip.axis_tlast   <= axis_unzip.axis_tlast;
    end
//---->> GEN RAM ADDR <<-------------------------
logic[ASIZE-1:0]    ram_addr;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  ram_addr    <= {ASIZE{1'b0}};
    else begin
        if(axis_zip.axis_tvalid && axis_zip.axis_tready && clken)
                ram_addr    <= addr;
        else if(incr_addr && ready && clken)
                ram_addr    <= ram_addr + 1'b1;
        else    ram_addr    <= ram_addr;
    end

logic           ram_rd_en;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  ram_rd_en   <= 1'b0;
    else begin
        if(axis_zip.axis_tvalid && axis_zip.axis_tready && clken)
                ram_rd_en   <= 1'b1;
        else if(last_addr && clken && ready)
                ram_rd_en   <= 1'b0;
        else    ram_rd_en   <= ram_rd_en;
        // if(clken)
        //         ram_rd_en <= pipe_valid_func((axis_zip.axis_tvalid && axis_zip.axis_tready),ready,ram_rd_en);
        // else    ram_rd_en <= ram_rd_en;
    end
//----<< GEN RAM ADDR >>-------------------------
//---->> AXIS LAST BYTE <<-----------------------
//----<< AXIS LAST BYTE >>-----------------------
assign  axis_unzip.axis_tvalid   = ram_rd_en;
assign  axis_unzip.axis_tdata    = ram_addr;
assign  axis_unzip.axis_tuser    = 1'b0;
assign  axis_unzip.axis_tkeep    = {(ASIZE/8+(ASIZE%8 != 0)){1'b1}};
assign  ready                       = axis_unzip.axis_tready;


endmodule
