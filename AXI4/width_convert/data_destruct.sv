/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/16 
madified:
***********************************************/
`timescale 1ns/1ps
import DataInterfacePkg::*;
module data_destruct #(             // it dont work : 2017/12/7 
    parameter IDSIZE    = 256,
    parameter ODSIZE    = 24
)(
    input                       clock,
    input                       rst_n,
    // input [31:0]                new_len,

    input [IDSIZE-1:0]          indata,
    input                       invalid,
    output logic                inready,
    input                       inlast,

    output logic[ODSIZE-1:0]    outdata,
    output logic                outvalid,
    input                       outready,
    output logic                outlast
);
//--->> Pre Input <<-------------------
logic[IDSIZE-1:0]           pre_indata;
logic                       pre_invalid;
logic                       pre_inready;
logic                       pre_inlast;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  pre_indata  <= '0;
    else begin
        if(invalid && inready)
                pre_indata  <= indata;
        else    pre_indata  <= pre_indata;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  pre_invalid <= 1'b0;
    else        pre_invalid <= pipe_valid_func(invalid,inready,pre_invalid);

always@(posedge clock,negedge rst_n)
    if(~rst_n)  pre_inlast  <= 1'b0;
    else begin
        if(invalid && inready && inlast)
                pre_inlast  <= 1'b1;
        else    pre_inlast  <= pipe_last_func(pre_invalid,inready,pre_inlast,inlast);
    end

assign inready  = pre_inready;
//---<< Pre Input >>-------------------
localparam MM   = IDSIZE/ODSIZE;
localparam NN   = IDSIZE%ODSIZE != 0;
localparam REMAINDER = IDSIZE%ODSIZE;
// localparam

localparam LI   = $clog2(IDSIZE);

logic[LI-1:0]   r_cnt;
logic[LI:0]     l_r_cnt;
logic           record_last;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  r_cnt   <= '0;
    else begin
        if(outvalid && outready && outlast)begin
                r_cnt   <= '0;
        end else begin
            if(outready && pre_invalid && (invalid || record_last))begin
                if(r_cnt+ODSIZE>=IDSIZE)
                        r_cnt   <= r_cnt+ODSIZE-IDSIZE;
                else    r_cnt   <= r_cnt + ODSIZE;
            end else  r_cnt <= r_cnt;
        end
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  l_r_cnt <= '0;
    else begin
        if(record_last)begin
            if(outready && outvalid)
                    l_r_cnt <= l_r_cnt  + ODSIZE;
            else    l_r_cnt <= l_r_cnt;
        end else    l_r_cnt <= '0;
    end
//--->> DATA MAP <<------------------------
logic [ODSIZE-1:0]      map_data;
logic [ODSIZE-1:0]      indata_tail;
logic                   map_data_vld;
logic                   last_mask;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  map_data    <= 1'b0;
    else begin
        if(r_cnt+ODSIZE>IDSIZE)
                // map_data    <= (pre_invalid && (invalid || record_last))? (indata[IDSIZE-1-:ODSIZE]>>(IDSIZE-r_cnt)) | (pre_indata[ODSIZE-1:0] << (ODSIZE-(IDSIZE-r_cnt))) : map_data;
                map_data    <= (pre_invalid && (invalid || record_last))? (indata[IDSIZE-1-:ODSIZE]>>(IDSIZE-r_cnt)) | (indata_tail << (ODSIZE-(IDSIZE-r_cnt))) : map_data;
        else    map_data    <= (pre_invalid && (invalid || record_last))?  pre_indata[IDSIZE-1-r_cnt-:ODSIZE] : map_data;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  map_data_vld    <= 1'b0;
    else begin
        if(pre_invalid && pre_inready && pre_inlast && (r_cnt=='0) && map_data_vld && outready)begin
            map_data_vld  <= 1'b0;
        end else if(last_mask && outvalid && outready)begin
            map_data_vld  <= 1'b0;
        end else
            map_data_vld  <= pipe_valid_func((pre_invalid && (invalid || record_last)),outready,map_data_vld);
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  last_mask   <= 1'b0;
    else begin
        if(pre_invalid && pre_inready && pre_inlast && (r_cnt != '0))
                last_mask   <= 1'b1;
        else if(outvalid && outready)
                last_mask   <= 1'b0;
        else    last_mask   <= last_mask;
    end
// always@(posedge clock,negedge rst_n)
//     if(~rst_n)  indata_tail <= '0;
//     else begin
//         if(pre_invalid && pre_inready)
//                 indata_tail <= pre_indata[ODSIZE-1:0];
//         else    indata_tail <= indata_tail;
//     end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  indata_tail <= '0;
    else begin
        // if(r_cnt+2*ODSIZE>IDSIZE)begin
        //     if(invalid && inready)
        //             indata_tail <= indata_tail;
        //     else if(pre_invalid && outready && invalid)
        //             indata_tail <= pre_indata[ODSIZE-1:0];
        //     else    indata_tail <= indata_tail;
        // end else begin
        //     indata_tail <= indata_tail;
        // end
        if((r_cnt+2*ODSIZE>IDSIZE) && (r_cnt+ODSIZE<=IDSIZE))begin
            if(invalid && inready)
                    indata_tail <= indata_tail;
            else if(pre_invalid && outready && (invalid || record_last))
                    indata_tail <= pre_indata[ODSIZE-1:0];
            else    indata_tail <= indata_tail;
        end else begin
            if(invalid && inready)
                    indata_tail <= indata_tail;
            else if(!pre_invalid)
                    indata_tail <= pre_indata[ODSIZE-1:0];
            else    indata_tail <= indata_tail;
        end
    end
//---<< DATA MAP >>------------------------
//--->> CURR BIT <<------------------------
logic [LI-1:0]   r_leave;
logic [ODSIZE*(MM+NN)-1:0]      array_bits;


always@(posedge clock,negedge rst_n)
    if(~rst_n)  r_leave <= '0;
    else begin
        if(pre_invalid && pre_inready)begin
            if(r_cnt+ODSIZE>=IDSIZE)
                    r_leave <= r_cnt+ODSIZE-IDSIZE;
            else    r_leave <= r_leave;
        end else begin
            r_leave <= r_leave;
        end
    end

always_comb begin
    array_bits[ODSIZE-1:0]  = indata_tail << (ODSIZE-r_leave);
    array_bits[ODSIZE*(MM+NN)-1-r_leave-:IDSIZE]  = pre_indata;
end
//--->> READY <<---------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  pre_inready <= 1'b0;
    else begin
        if((r_cnt+2*ODSIZE>IDSIZE) && (r_cnt+ODSIZE<=IDSIZE))begin
            if(invalid && inready)
                    pre_inready <= 1'b0;
            else if(pre_invalid && outready && (invalid || record_last))
                    pre_inready <= 1'b1;
            else    pre_inready <= pre_inready;
        end else begin
            if(invalid && inready)
                    pre_inready <= 1'b0;
            else if(!pre_invalid)
                    pre_inready <= 1'b1;
            else    pre_inready <= pre_inready;
        end
    end
//---<< READY >>---------------------------
//--->> VALID <<---------------------------
// always@(posedge clock,negedge rst_n)
//     if(~rst_n)  outvalid    <= 1'b0;
//     else begin
//         outvalid    <= pipe_valid_func(pre_invalid,outready,outvalid);
//     end
assign outvalid = map_data_vld;
assign outdata  = map_data;
//---<< VALID >>---------------------------
//--->> LAST <<----------------------------

always@(posedge clock,negedge rst_n)
    if(~rst_n)  record_last <= 1'b0;
    else begin
        if(invalid && inready && inlast)
                record_last <= 1'b1;
        else if(outvalid && outready && outlast)
                record_last <= 1'b0;
        else    record_last <= record_last;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  outlast <= 1'b0;
    else begin
        if(pre_invalid && pre_inready && pre_inlast && (r_cnt != '0))
            outlast <= 1'b1;
        else if(pre_invalid && outready && record_last)begin
            if(r_cnt+ODSIZE==IDSIZE)
                    outlast <= 1'b1;
            else    outlast <= 1'b0;
        end else if(last_mask && !outlast)begin
            outlast <= 1'b1;
        end else if(outvalid && outready && outlast)
                outlast <= 1'b0;
        else    outlast <= outlast;

        // outlast <= pipe_last_func((pre_inready && (invalid || record_last)),outready,outlast,record_last);
    end
//---<< LAST >>----------------------------
//--->> Verify <<-------------------------
// logic [IDSIZE-1:0]      right_in_queue [$];
//
// always@(posedge clock)
//     if(pre_invalid && pre_inready)begin
//         right_in_queue    = {right_in_queue,pre_indata};
//         if(~pre_inlast)begin
//             @(posedge clock);
//             // in_queue    = {};
//         end
//     end
//
// logic [ODSIZE-1:0]      right_out_queue [$];
//
// always@(posedge clock)
//     right_out_queue   = {>>{right_in_queue}};
//
//
// logic [ODSIZE-1:0]      out_queue [$];
// event                   out_fsh_event;
//
// always@(posedge clock)begin
//     if(outvalid && outready)
//         out_queue   = {out_queue,outdata};
//
//     if(outvalid && outready && outlast)begin
//         // @(posedge clock);
//         @(negedge outlast);
//         // out_queue   = {};
//         @(posedge clock);
//         -> out_fsh_event;
//     end
//
// end
// logic [IDSIZE-1:0]      in_queue    [$];
// initial begin
//     if(0)begin
//         forever begin
//             // forever begin
//             //     wait(outvalid && outready);
//             //     @(posedge clock);
//             //     in_queue    = {>>{out_queue}};
//             //     if(outlast)
//             //         break;
//             // end
//             @(posedge clock);
//             wait(out_fsh_event.triggered());
//             #(1ns);
//             in_queue    = {>>{out_queue}};
//             // $stop;
//             foreach(in_queue[i])
//                 $write("->%h",in_queue[i]);
//             $write("\n");
//         end
//     end
// end



//---<< Verify >>-------------------------


endmodule
