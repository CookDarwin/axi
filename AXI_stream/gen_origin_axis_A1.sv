/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.1.0
    addr start num
creaded: 2017/1/18 
madified:
***********************************************/
`timescale 1ns/1ps
`include "define_macro.sv"
(* axi_stream = "true" *)
module gen_origin_axis_A1 #(
    `parameter_string MODE = "RANGE"
)(
    input                 enable,
    output logic          ready,
    input [31:0]          length,
    input [31:0]          start,
    (* down_stream = "true" *)
    axi_stream_inf.master axis_out
);

import DataInterfacePkg::*;

wire    clock,rst_n;

assign  clock   = axis_out.aclk;
assign  rst_n   = axis_out.aresetn;

assign  axis_out.axis_tuser = 1'b0;
assign  axis_out.axis_tkeep = 1'b1;

typedef enum {IDLE,SEND_DATA,FRAME_DONE}    STATUS;

STATUS  cstate,nstate;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  cstate  <= IDLE;
    else        cstate  <= nstate;

logic   data_ok;

always@(*)
    case(cstate)
    IDLE:
        if(enable && ready)
                nstate  = SEND_DATA;
        else    nstate  = IDLE;
    SEND_DATA:
        if(data_ok)
                nstate  = FRAME_DONE;
        else    nstate  = SEND_DATA;
    FRAME_DONE:
        // if(!enable)
                nstate  = IDLE;
        // else    nstate  = FRAME_DONE;
    default:    nstate  = IDLE;
    endcase

// always@(posedge clock/*,negedge rst_n*/)
//     if(~rst_n)  axis_out.axis_tdata     <= start;
//     else begin
//         if(axis_out.axis_tvalid && axis_out.axis_tready && axis_out.aclken)
//             if(axis_out.axis_tdata < (start+length-1))begin
//                 if(MODE == "RANGE")
//                         axis_out.axis_tdata     <= axis_out.axis_tdata + 1'b1;
//                 else    axis_out.axis_tdata     <= start;
//             end
//             else    axis_out.axis_tdata     <= start;
//         else    axis_out.axis_tdata     <= axis_out.axis_tdata;
//     end

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  axis_out.axis_tdata     <= start;
    else
        case(nstate)
        IDLE:       axis_out.axis_tdata     <= start;
        SEND_DATA:begin
            if(axis_out.axis_tvalid && axis_out.axis_tready && axis_out.aclken)
                    axis_out.axis_tdata     <= axis_out.axis_tdata + 1'b1;
            else    axis_out.axis_tdata     <= axis_out.axis_tdata;
        end
        default:;
        endcase

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  axis_out.axis_tvalid     <= 1'b0;
    else
        case(nstate)
        SEND_DATA:  axis_out.axis_tvalid    <= 1'b1;
        default:    axis_out.axis_tvalid    <= 1'b0;
        endcase


reg [31:0]      cnt ;
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  cnt     <= '0;
    else begin
        if(axis_out.axis_tvalid && axis_out.axis_tready && axis_out.aclken)
            if(cnt < (length-1))
                    cnt     <= cnt + 1'b1;
            else    cnt     <= '0;
        else        cnt     <= cnt;
    end

//
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  axis_out.axis_tlast    <= 1'b0;
    else begin
        if(axis_out.aclken)
                axis_out.axis_tlast <= pipe_last_func(axis_out.axis_tvalid,axis_out.axis_tready,axis_out.axis_tlast,(cnt==length-2));
        else    axis_out.axis_tlast <= 1'b0;
    end

assign  data_ok = axis_out.axis_tlast && axis_out.axis_tready && axis_out.axis_tvalid;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  ready     <= 1'b0;
    else
        case(nstate)
        IDLE:       ready    <= 1'b1;
        default:    ready    <= 1'b0;
        endcase


endmodule
