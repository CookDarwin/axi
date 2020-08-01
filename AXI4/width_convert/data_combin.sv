/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/15 
madified:
***********************************************/
`timescale 1ns/1ps
import DataInterfacePkg::*;
module data_combin_0 #(
    parameter IDSIZE    = 24,
    parameter ODSIZE    = 256
)(
    input                       clock,
    input                       rst_n,
    input [31:0]                cut_old_len,
    input [IDSIZE-1:0]          indata,
    input                       invalid,
    output                      inready,
    input                       inlast,

    output logic[ODSIZE-1:0]    outdata,
    output logic                outvalid,
    input                       outready,
    output logic                outlast
);

assign inready  = outready;


localparam MM   = ODSIZE/IDSIZE;
localparam NN   = ODSIZE%IDSIZE != 0;
// localparam
localparam PSIZE = MM+NN*2;
localparam PP    = $clog2(PSIZE);

logic[IDSIZE-1:0]   data_map_array [MM+NN*2-1:0];

//--->> DATA CONTER <<------------------
logic [31:0]    cnt;
logic           cenable;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cenable <= 1'b0;
    else begin
        if(invalid && inready && inlast)
                cenable <= 1'b1;
        else if(cnt == 0 && !(invalid && inready))
                cenable <= 1'b1;
        else if(cnt == cut_old_len)
                cenable <= 1'b0;
        else if(cnt== (cut_old_len-1) && invalid && inready)
                cenable <= 1'b0;
        else    cenable <= cenable;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cnt     <= '0;
    else begin
        if(invalid && inready && cenable)begin
            if(!inlast)
                    cnt     <= cnt + 1'b1;
            else    cnt     <= '0;
        end else    cnt     <= cnt;
    end

//---<< DATA CONTER >>------------------
//--->> WRITE POINT <<------------------
logic [PP-1:0]  wpoint;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  wpoint   <= '0;
    else begin
        if(invalid && inready && inlast)
                wpoint   <= '0;
        else if(!cenable)
                wpoint   <= '0;
        else if(invalid && inready)begin
            if(wpoint == (PSIZE-1))
                    wpoint   <= '0;
            else    wpoint   <= wpoint + 1'b1;
        end else    wpoint   <= wpoint;
    end
//---<< WRITE POINT >>------------------
//--->> WRITE TO ARRAY <<---------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)
        foreach(data_map_array[i])
            data_map_array[i]   <= '0;
    else begin
        if(invalid && inready)
                data_map_array[wpoint]   <= indata;
    end
//---<< WRITE TO ARRAY >>---------------
//--->> STACK CONTER <<-----------------
localparam  SSIZE = $clog2(ODSIZE);

logic[SSIZE-1:0]    s_cnt;
logic               s_full;//-->> data_map_array
logic               double_s_full;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  s_cnt   <= '0;
    else begin
        if(outvalid && outready && outlast)begin
            if(invalid && inready)
                    s_cnt   <= IDSIZE;
            else    s_cnt   <= '0;
        end else begin
            if(invalid && inready)begin
                if(s_cnt + IDSIZE  >= ODSIZE)
                        s_cnt   <= s_cnt + IDSIZE  - ODSIZE;
                else    s_cnt   <= s_cnt + IDSIZE;
            end else    s_cnt   <= s_cnt;
        end
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  s_full  <= 1'b0;
    else begin
        if(double_s_full && inready)
            s_full  <= 1'b1;
        else if(s_full && inready && !inlast)
            s_full  <= 1'b0;
        else if(invalid && inready)begin
            if(s_cnt >= (ODSIZE-IDSIZE) || cnt== (cut_old_len-1))
                    s_full  <= 1'b1;
            else if(inlast)
                    s_full  <= 1'b1;
            else    s_full  <= 1'b0;
        end
        else    s_full  <= s_full;
        // s_full  <= pipe_valid_func(invalid,inready,s_full);
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  double_s_full  <= 1'b0;
    else begin
        if(invalid && inready && inlast)begin
            if(s_cnt >= (ODSIZE-IDSIZE) || cnt== (cut_old_len-1))
                    double_s_full  <= 1'b1;
            else    double_s_full  <= 1'b0;
        end else begin
            if(double_s_full && inready)
                    double_s_full   <= 1'b0;
            else    double_s_full   <= double_s_full;
        end
    end
//---<< STACK CONTER >>-----------------
//--->> map  point <<-------------------
localparam  REMAINDER  = ODSIZE%IDSIZE;
localparam  NNSIZE     = $clog2(IDSIZE);

logic [NNSIZE-1:0]     r_cnt;
logic                  shift_point;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  r_cnt   <= '0;
    else begin
        if(outvalid && outready && outlast)
                r_cnt   <= '0;
        else begin
            if(s_full && inready)begin
                if(r_cnt >= IDSIZE-REMAINDER)
                        r_cnt   <= REMAINDER- (IDSIZE - r_cnt);
                else    r_cnt   <= r_cnt+REMAINDER;
            end else    r_cnt   <= r_cnt;
        end
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  shift_point <= 1'b0;
    else begin
        if(outvalid && outready && outlast)
                shift_point <= 1'b0;
        else begin
            if(invalid && inready)begin
                if(r_cnt >= IDSIZE-REMAINDER)
                        shift_point <= 1'b1;
                else    shift_point <= 1'b0;
            end else    shift_point <= 1'b0;
        end
    end
//---<< map  point >>-------------------
//--->> SHIFT array MAP <<--------------
logic [PSIZE-1:0]   array_map;
logic               array_map_vld;  //-->> array_align_bytes

always@(posedge clock,negedge rst_n)
    if(~rst_n)  array_map   <= '0;
    else begin
        if(outvalid && outready && outlast)
                    array_map   <= '0;
        else begin
            if(s_full && inready)begin
                // if(!shift_point)begin
                if(!(r_cnt >= IDSIZE-REMAINDER))begin
                    if(array_map+MM < (MM+NN*2))
                            array_map   <= array_map + MM;
                    else    array_map   <= array_map+MM - (MM+NN*2);
                end else begin
                    if(array_map+MM+1 < (MM+NN*2))
                            array_map   <= array_map + MM + 1;
                    else    array_map   <= array_map+MM+1 - (MM+NN*2);
                end
            end else
                array_map   <= array_map;
        end
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  array_map_vld   <= 1'b0;
    else begin
        array_map_vld   <= pipe_valid_func(s_full,outready,array_map_vld);
    end
//---<< SHIFT array MAP >>--------------
//--->> STATUS CTRL <<------------------
logic [IDSIZE-1:0]              array_align_bytes [(MM+NN*2)-1:0];
logic [IDSIZE*(MM+NN*2)-1:0]    array_align_bit;
logic                           byte_align_bit_vld;

always@(posedge clock,negedge rst_n)
    if(~rst_n)
        foreach(array_align_bytes[i])
            array_align_bytes[i]    <= '0;
    else begin
        if(s_full && inready)begin
            foreach(array_align_bytes[i])
                array_align_bytes[i]    <= data_map_array[(array_map+i)%(MM+NN*2)];
        end else begin
            array_align_bytes   <= array_align_bytes;
        end
    end

// always@(posedge clock,negedge rst_n)
//     if(~rst_n)  array_align_bit <= '0;
//     else begin
//         if(array_map_vld)begin
//             foreach(array_align_bytes[i])
//                 array_align_bit[IDSIZE*(MM+NN-i)-1-:IDSIZE]   <= array_align_bytes[i];
//         end else begin
//             array_align_bit <= array_align_bit;
//         end
//     end

always_comb begin
    foreach(array_align_bytes[i])
        array_align_bit[IDSIZE*(MM+NN*2-i)-1-:IDSIZE]   <= array_align_bytes[i];
end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  byte_align_bit_vld  <= 1'b0;
    else begin
        byte_align_bit_vld  <= pipe_valid_func(array_map_vld,outready,byte_align_bit_vld);
    end

logic [NNSIZE-1:0]     r_cnt_lat;
logic [ODSIZE-1:0]     byte_align_bit;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  r_cnt_lat   <= '0;
    else begin
        if(outlast && outvalid && outready)
                r_cnt_lat   <= '0;
        else if(array_map_vld && outready)
                r_cnt_lat   <= r_cnt;
        else    r_cnt_lat   <= r_cnt_lat;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)    byte_align_bit    <= '0;
    else begin
        if(array_map_vld && outready)
                byte_align_bit  <= array_align_bit[IDSIZE*(MM+NN*2)-1-r_cnt_lat-:ODSIZE];
        else    byte_align_bit  <= byte_align_bit;
    end

//---<< STATUS CTRL >>------------------
//--->> OUT LAST <<---------------------
logic stack_last;
logic array_last;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  stack_last  <= 1'b0;
    else begin
        if(invalid && inready && inlast)begin
            if(s_cnt >= (ODSIZE-IDSIZE) || cnt== (cut_old_len-1))
                    stack_last  <= 1'b0;
            else    stack_last  <= 1'b1;
        end else if(double_s_full && inready)begin
            stack_last  <= 1'b1;
        end else begin
                stack_last  <= pipe_last_func(s_full,inready,stack_last,((&cut_old_len && inlast) || (cnt==cut_old_len-1)));
        end
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  array_last  <= 1'b0;
    else begin
        if(stack_last && s_full && inready)
                array_last  <= 1'b1;
        else    array_last  <= pipe_last_func(array_map_vld,inready,array_last,stack_last);
    end


always@(posedge clock,negedge rst_n)
    if(~rst_n)  outlast <= 1'b0;
    else begin
        // if(cnt== (cut_old_len-1) && invalid && inready)
        //         outlast <= 1'b1;
        // else if(outlast && outvalid && outready)
        //         outlast <= 1'b0;
        // else    outlast <= outlast;
        if(array_last && array_map_vld && inready)
                outlast  <= 1'b1;
        else    outlast  <= pipe_last_func(byte_align_bit_vld,inready,outlast,array_last);
    end
//---<< OUT LAST >>---------------------
//--->> IO <<---------------------------
assign    outdata   = byte_align_bit;
assign    outvalid  = byte_align_bit_vld;
//---<< IO >>---------------------------
//--->> VERIFY <<-----------------------
logic [ODSIZE-1:0]   out_queue [$];

always@(posedge clock)begin
    if(byte_align_bit_vld && outready)
            out_queue   = {out_queue,byte_align_bit};
    else    out_queue   = out_queue;

    if(outlast && outvalid && outready)begin
            @(posedge clock);
            out_queue   = {};
    end
end


logic [IDSIZE-1:0]  in_queue [$];
logic [ODSIZE*6-1:0]    all_bit;

// always@(negedge outlast)begin
//
//     in_queue    = {>>{out_queue}};
//     foreach(in_queue[i])begin
//         $write("->%h",in_queue[i]);
//     end
//     $write("\n");
// end

// int index = ODSIZE;
//
// initial begin
//     repeat(4)begin
//         @(posedge  byte_align_bit_vld);
//         @(negedge  clock);
//         foreach(byte_align_bit[i])
//             all_bit[index-1-i] = byte_align_bit[i];
//         index += ODSIZE;
//     end
// end

//---<< VERIFY >>-----------------------
endmodule
