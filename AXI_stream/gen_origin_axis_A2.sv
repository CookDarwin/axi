/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.1.0
    addr start num
Version: VERA.2.0
    length can be 1
creaded: 
madified:
***********************************************/
`timescale 1ns/1ps
`include "define_macro.sv"
(* axi_stream = "true" *)
module gen_origin_axis_A2 #(
    `parameter_string MODE = "RANGE"
)(
    input                 enable,
    output logic          ready,
    input [31:0]          length,       // '1' meet 1 length
    input [31:0]          start,
    (* down_stream = "true" *)
    axi_stream_inf.master axis_out
);

import DataInterfacePkg::*;

wire    clock,rst_n;

assign  clock   = axis_out.aclk;
assign  rst_n   = axis_out.aresetn;

assign  axis_out.axis_tuser = 1'b0;
assign  axis_out.axis_tkeep = '1;

typedef enum {IDLE,SEND_DATA,FRAME_DONE}    STATUS;

STATUS  cstate,nstate;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  cstate  <= IDLE;
    else        cstate  <= nstate;

// logic   data_ok;

always@(*)
    case(cstate)
    IDLE:
        if(enable && ready)
                nstate  = SEND_DATA;
        else    nstate  = IDLE;
    SEND_DATA:
        if(axis_out.axis_tvalid && axis_out.axis_tready && axis_out.axis_tlast && axis_out.aclken)
                nstate  = IDLE;
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
            if(enable && ready)
                    axis_out.axis_tdata     <= start;
            else if(axis_out.axis_tvalid && axis_out.axis_tready && axis_out.aclken)begin 
                    // axis_out.axis_tdata     <= axis_out.axis_tdata + 1'b1;
                     if(MODE == "RANGE")
                            axis_out.axis_tdata     <= axis_out.axis_tdata + 1'b1;
                    else    axis_out.axis_tdata     <= start;
            end else    
                    axis_out.axis_tdata     <= axis_out.axis_tdata;
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


// reg [31:0]      cnt ;
// always@(posedge clock/*,negedge rst_n*/)
//     if(~rst_n)  cnt     <= '0;
//     else begin
//         if(axis_out.axis_tvalid && axis_out.axis_tready && axis_out.aclken)
//             if(cnt < (length-1))
//                     cnt     <= cnt + 1'b1;
//             else    cnt     <= '0;
//         else        cnt     <= cnt;
//     end

//
logic [31:0]    lock_length;
always@(posedge clock/*,negedge rst_n*/)begin 
    if(~rst_n)  lock_length <= '0;
    else begin 
        if(enable && ready)
                lock_length <= length;
        else    lock_length <= lock_length;
    end 
end 

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  axis_out.axis_tlast    <= 1'b0;
    else begin
        // if(axis_out.aclken)
        //     if(length > 1)
        //             axis_out.axis_tlast <= pipe_last_func(axis_out.axis_tvalid,axis_out.axis_tready,axis_out.axis_tlast,(cnt==length-2));
        //     else    axis_out.axis_tlast <= 1'b1;
        // else    axis_out.axis_tlast <= 1'b0;
        if(axis_out.aclken)begin 
            if(enable && ready)begin 
                axis_out.axis_tlast <= length < 2;
            end else if(axis_out.axis_tvalid && axis_out.axis_tready && axis_out.axis_tlast && axis_out.aclken)begin
                axis_out.axis_tlast <= 1'b0;
            end else if(axis_out.axis_tvalid && axis_out.axis_tready && axis_out.axis_tcnt==lock_length-2 && axis_out.aclken )begin 
                axis_out.axis_tlast <= 1'b1;
            end else begin 
                axis_out.axis_tlast <= axis_out.axis_tlast;
            end 
        end else begin 
            axis_out.axis_tlast <= axis_out.axis_tlast;
        end
    end

// assign  data_ok = axis_out.axis_tlast && axis_out.axis_tready && axis_out.axis_tvalid;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  ready     <= 1'b0;
    else
        case(nstate)
        IDLE:       ready    <= 1'b1;
        default:    ready    <= 1'b0;
        endcase


endmodule
