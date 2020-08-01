/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2016/12/8 
madified:
***********************************************/
`timescale 1ns/1ps
`include "define_macro.sv"
(* axi_stream = "true" *)
module gen_simple_axis #(
    `parameter_string   MODE  = "RANGE"
)(
    input           trigger,
    input           gen_en,
    input [15:0]    length,
    output logic    led,
    (* down_stream = "true" *)
    axi_stream_inf.master axis_out
);

import DataInterfacePkg::*;

wire    clock,rst_n;

assign  clock   = axis_out.aclk;
assign  rst_n   = axis_out.aresetn;

assign  axis_out.axis_tuser = 1'b0;
assign  axis_out.axis_tkeep = 1'b1;

wire trigger_raising;
wire trigger_falling;

edge_generator #(
	.MODE  ("NORMAL")   // FAST NORMAL BEST
)edge_generator_inst(
/*input	    */  .clk         (clock             ),
/*input	    */  .rst_n       (rst_n             ),
/*input	    */  .in          (trigger           ),
/*output    */  .raising     (trigger_raising   ),
/*output    */  .falling     (trigger_falling   )
);

typedef enum {IDLE,SEND_DATA,FRAME_DONE}    STATUS;

STATUS  cstate,nstate;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  cstate  <= IDLE;
    else        cstate  <= nstate;

logic   data_ok;
logic   frame_ok;

always@(*)
    case(cstate)
    IDLE:
        // if(trigger_falling)
        if(trigger_falling || gen_en)
                nstate  = SEND_DATA;
        else    nstate  = IDLE;
    SEND_DATA:
        if(data_ok)
                nstate  = FRAME_DONE;
        else    nstate  = SEND_DATA;
    FRAME_DONE:
        if(frame_ok)
                nstate  = IDLE;
        else    nstate  = SEND_DATA;
    default:    nstate  = IDLE;
    endcase

reg [15:0]      cnt ;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  axis_out.axis_tdata     <= {axis_out.DSIZE{1'b0}};
    else begin
        if(axis_out.axis_tvalid && axis_out.axis_tready && axis_out.aclken)
            // if(cnt < (length-1))begin
            if(1)begin
                if(MODE=="RANGE")
                        axis_out.axis_tdata     <= axis_out.axis_tdata + 1'b1;
                else    axis_out.axis_tdata     <= {axis_out.DSIZE{1'b0}};
                // else    axis_out.axis_tdata     <= axis_out.axis_tdata;
                    // axis_out.axis_tdata     <= 'b1;
            end else    axis_out.axis_tdata     <= {axis_out.DSIZE{1'b0}};
        else    axis_out.axis_tdata     <= axis_out.axis_tdata;
    end

// assign axis_out.axis_tdata     = 'b1;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  axis_out.axis_tvalid     <= 1'b0;
    else
        case(nstate)
        SEND_DATA:  axis_out.axis_tvalid    <= 1'b1;
        default:    axis_out.axis_tvalid    <= 1'b0;
        endcase

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  cnt     <= 16'd0;
    else begin
        if(axis_out.axis_tvalid && axis_out.axis_tready && axis_out.aclken)
            if(cnt < (length-1))
                    cnt     <= cnt + 1'b1;
            else    cnt     <= 16'd0;
        else        cnt     <= cnt;
    end

//
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  axis_out.axis_tlast    <= 1'b0;
    else begin
        if(axis_out.aclken)begin
            // if(axis_out.axis_tlast)begin
            //     if(axis_out.axis_tready && axis_out.axis_tvalid)
            //             axis_out.axis_tlast     <= 1'b0;
            //     else    axis_out.axis_tlast     <= 1'b1;
            // end else begin
            //     if((cnt==length-2) && axis_out.axis_tready && axis_out.axis_tvalid)
            //             axis_out.axis_tlast     <= 1'b1;
            //     else    axis_out.axis_tlast     <= 1'b0;
            // end

            axis_out.axis_tlast <= pipe_last_func(axis_out.axis_tvalid,axis_out.axis_tready,axis_out.axis_tlast,(cnt==length-2));
        end else    axis_out.axis_tlast    <= axis_out.axis_tlast;
    end

assign  data_ok = axis_out.axis_tlast && axis_out.axis_tready && axis_out.axis_tvalid;

reg [4:0]       fcnt;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  fcnt    <= 5'd0;
    else begin
        if(axis_out.axis_tvalid && axis_out.axis_tready && axis_out.axis_tlast && axis_out.aclken)
                fcnt    <= fcnt + 1'b1;
        else    fcnt    <= fcnt;
    end

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  frame_ok    <= 1'b0;
    else  begin
        if(axis_out.aclken)
                frame_ok    <= fcnt == 5'd16;
        else    frame_ok    <= frame_ok;
    end


//
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  led     <= 1'b0;
    else begin
        if(axis_out.axis_tvalid && axis_out.axis_tready && axis_out.axis_tlast && frame_ok && axis_out.aclken)
                led     <= ~led;
        else    led     <= led ;
    end


endmodule
