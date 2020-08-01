/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
    create from axis_uncompress
creaded: 2017/7/27 
madified:
***********************************************/
`timescale 1ns/1ps
(* data_inf_c = "true" *)
module data_uncompress #(
    parameter   ASIZE = 8,          //ASIZE + LSIZE = DATA WIDTH
    parameter   LSIZE = 8
)(
    (* data_up = "true" *)
    data_inf_c.slaver   data_zip,          //ASIZE+LSIZE
    (* data_down = "true" *)
    data_inf_c.master   data_unzip       //ASIZE
);

import DataInterfacePkg::*;

logic               clock;
logic               rst_n;

assign  clock   = data_zip.clock;
assign  rst_n   = data_zip.rst_n;

logic   ready;


wire [ASIZE-1:0]    addr ;
wire [LSIZE-1:0]    cmd_len;

assign  addr    = data_zip.data[ASIZE+LSIZE-1:LSIZE];
assign  cmd_len = data_zip.data[LSIZE-1:0];


// typedef enum {IDLE,VLD_CTRL,}

//---->> RAM ADDRESS CTRL<<--------------------------
logic[LSIZE-1:0]    cnt;
logic               incr_addr;
logic               last_addr;
logic[LSIZE-1:0]    addr_len;

always@(posedge clock,negedge rst_n)
    if(~rst_n)      cnt     <= {LSIZE{1'b0}};
    else begin
        if(data_zip.valid && data_zip.ready)
                    cnt     <= {LSIZE{1'b0}};
        else if(ready && incr_addr)
                    cnt     <= cnt + 1'b1;
        else        cnt     <= cnt;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)      addr_len     <= {LSIZE{1'b0}};
    else begin
        if(data_zip.valid && data_zip.ready)
                    addr_len     <= cmd_len;
        else        addr_len     <= addr_len;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  incr_addr   <= 1'b0;
    else begin
        if(data_zip.valid && data_zip.ready && cmd_len!={LSIZE{1'b0}})
                incr_addr   <= 1'b1;
        else if(cnt == (addr_len-1) && ready)
                incr_addr   <= 1'b0;
        else    incr_addr   <= incr_addr;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  last_addr   <= 1'b0;
    else begin
        if(cnt == (addr_len-1) && ready)
                last_addr   <= 1'b1;
        else if(data_zip.valid && data_zip.ready && cmd_len=={LSIZE{1'b0}})      //burst one addr
                last_addr   <= 1'b1;
        else if(ready)
                last_addr   <= 1'b0;
        else    last_addr   <= last_addr;
    end
//----<< RAM ADDRESS CTRL>>--------------------------
//---->> CONTROL READY <<------------------------
assign  data_zip.ready   = !incr_addr && ready;
//----<< CONTROL READY >>------------------------
// logic       in_last_record;
// always@(posedge clock,negedge rst_n)
//     if(~rst_n)  in_last_record  <= 1'b0;
//     else begin
//         if(axis_zip.axis_tvalid && axis_zip.axis_tready && axis_zip.axis_tlast && cmd_len!={LSIZE{1'b0}} && clken)
//                 in_last_record  <= 1'b1;
//         else if(axis_unzip.axis_tvalid && axis_unzip.axis_tready && axis_unzip.axis_tlast && clken)
//                 in_last_record  <= 1'b0;
//         else    in_last_record  <= in_last_record;
//     end
//
// always@(posedge clock,negedge rst_n)
//     if(~rst_n)  axis_unzip.axis_tlast   <= 1'b0;
//     else begin
//         if(cnt == (addr_len-1) && ready && clken)
//                 axis_unzip.axis_tlast   <= in_last_record;
//         else if(axis_zip.axis_tvalid && axis_zip.axis_tready && axis_zip.axis_tlast && cmd_len=={LSIZE{1'b0}} && clken)
//                 axis_unzip.axis_tlast   <= 1'b1;
//         else if(axis_unzip.axis_tvalid && axis_unzip.axis_tready && axis_unzip.axis_tlast && clken)
//                 axis_unzip.axis_tlast   <= 1'b0;
//         else    axis_unzip.axis_tlast   <= axis_unzip.axis_tlast;
//     end
//---->> GEN RAM ADDR <<-------------------------
logic[ASIZE-1:0]    ram_addr;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  ram_addr    <= {ASIZE{1'b0}};
    else begin
        if(data_zip.valid && data_zip.ready)
                ram_addr    <= addr;
        else if(incr_addr && ready )
                ram_addr    <= ram_addr + 1'b1;
        else    ram_addr    <= ram_addr;
    end

logic           ram_rd_en;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  ram_rd_en   <= 1'b0;
    else begin
        if(data_zip.valid && data_zip.ready)
                ram_rd_en   <= 1'b1;
        else if(last_addr && ready)
                ram_rd_en   <= 1'b0;
        else    ram_rd_en   <= ram_rd_en;
        // if(clken)
        //         ram_rd_en <= pipe_valid_func((axis_zip.axis_tvalid && axis_zip.axis_tready),ready,ram_rd_en);
        // else    ram_rd_en <= ram_rd_en;
    end
//----<< GEN RAM ADDR >>-------------------------
//---->> LAST BYTE <<-----------------------
//----<< LAST BYTE >>-----------------------
assign  data_unzip.valid   = ram_rd_en;
assign  data_unzip.data    = ram_addr;
assign  ready              = data_unzip.ready;


endmodule
