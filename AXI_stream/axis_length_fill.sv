/**********************************************
______________   ______________
______________ X ______________
______________  ______________

descript:
author : Cook.Darwin
Version: VERA.0.1 2018/1/25 
    add axis_tuser
creaded: 2017/4/28 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_length_fill (
    input [15:0]           length,
    (* up_stream = "true" *)
    axi_stream_inf.slaver  axis_in,
    (* down_stream = "true" *)
    axi_stream_inf.master  axis_out
);

import DataInterfacePkg::*;

wire        clock,rst_n;

assign  clock   = axis_in.aclk;
assign  rst_n   = axis_in.aresetn;

axi_stream_inf #(axis_in.DSIZE) pre_axis_out (clock,rst_n,1'b1);

enum {IDLE,AXIS_STREAM,EX_STREAM} cstate,nstate;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cstate  <= IDLE;
    else        cstate  <= nstate;

always_comb begin
    case(cstate)
    IDLE:
        if(axis_in.axis_tvalid && axis_in.axis_tready)
                nstate  = AXIS_STREAM ;
        else    nstate  = IDLE;
    AXIS_STREAM:
        if(axis_in.axis_tvalid && axis_in.axis_tready && axis_in.axis_tlast)
            if(axis_in.axis_tcnt < length - 1 )
                    nstate  = EX_STREAM;
            else    nstate  = AXIS_STREAM;
        else    nstate  = AXIS_STREAM;
    EX_STREAM:
        if(pre_axis_out.axis_tvalid && pre_axis_out.axis_tready && pre_axis_out.axis_tlast)
                nstate  = AXIS_STREAM;
        else    nstate  = EX_STREAM;
    default:    nstate  = IDLE;
    endcase
end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  pre_axis_out.axis_tvalid <= 1'b0;
    else
        case(nstate)
        IDLE,AXIS_STREAM:
            if(axis_in.axis_tvalid && axis_in.axis_tready)
                    pre_axis_out.axis_tvalid <= 1'b1;
            else if(pre_axis_out.axis_tvalid && pre_axis_out.axis_tready)
                    pre_axis_out.axis_tvalid <= 1'b0;
            else    pre_axis_out.axis_tvalid <= pre_axis_out.axis_tvalid;
        EX_STREAM:  pre_axis_out.axis_tvalid <= 1'b1;
        default:begin
            if(pre_axis_out.axis_tvalid && pre_axis_out.axis_tready)
                    pre_axis_out.axis_tvalid <= 1'b0;
            else    pre_axis_out.axis_tvalid <= pre_axis_out.axis_tvalid;
        end
        endcase

always@(posedge clock,negedge rst_n)
    if(~rst_n)  pre_axis_out.axis_tdata <= '0;
    else
        case(nstate)
        IDLE,AXIS_STREAM:
            if(axis_in.axis_tvalid && axis_in.axis_tready)
                    pre_axis_out.axis_tdata <= axis_in.axis_tdata;
            else    pre_axis_out.axis_tdata <= pre_axis_out.axis_tdata;
        EX_STREAM:begin
            if(axis_in.axis_tvalid && axis_in.axis_tready)
                    pre_axis_out.axis_tdata <= axis_in.axis_tdata;
            // else    pre_axis_out.axis_tdata <= '0;
            else    pre_axis_out.axis_tdata <= pre_axis_out.axis_tdata;
        end
        default:begin
            // if(pre_axis_out.axis_tvalid && pre_axis_out.axis_tready)
            //         pre_axis_out.axis_tvalid <= 1'b0;
            // else    pre_axis_out.axis_tvalid <= pre_axis_out.axis_tvalid;
        end
        endcase

// always@(posedge clock,negedge rst_n)
//     if(~rst_n)  pre_axis_out.axis_tlast <= 1'b0;
//     else
//         case(nstate)
//         AXIS_STREAM:
//             if(axis_in.axis_tvalid && axis_in.axis_tready)
//                 if(axis_in.axis_tcnt >= length-1)
//                         pre_axis_out.axis_tlast <= axis_in.axis_tlast;
//                 else    pre_axis_out.axis_tlast <= 1'b0;
//             else    pre_axis_out.axis_tlast <= 1'b0;
//         EX_STREAM:  pre_axis_out.axis_tvalid <= 1'b1;
//         default:begin
//             if(pre_axis_out.axis_tvalid && pre_axis_out.axis_tready)
//                     pre_axis_out.axis_tvalid <= 1'b0;
//             else    pre_axis_out.axis_tvalid <= pre_axis_out.axis_tvalid;
//         end
//         endcase

logic [15:0]    axis_len;
always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_len    <= '0;
    else begin
        if(axis_in.axis_tvalid && axis_in.axis_tready && axis_in.axis_tlast)
                axis_len    <= axis_in.axis_tcnt;
        else    axis_len    <= axis_len;
    end



always@(posedge clock,negedge rst_n)
    if(~rst_n)   pre_axis_out.axis_tlast <= 1'b0;
    else begin
        case(nstate)
        IDLE,AXIS_STREAM:
            if(axis_in.axis_tvalid && axis_in.axis_tready && axis_in.axis_tlast)
                    pre_axis_out.axis_tlast <= axis_in.axis_tcnt >= length - 16'd1;
            // if(pre_axis_out.axis_tvalid && pre_axis_out.axis_tready && pre_axis_out.axis_tcnt >= (axis_len-1))
            //         pre_axis_out.axis_tlast <= 1'b1;
            else if(pre_axis_out.axis_tvalid && pre_axis_out.axis_tready && pre_axis_out.axis_tlast)
                    pre_axis_out.axis_tlast <= 1'b0;
            else    pre_axis_out.axis_tlast <= pre_axis_out.axis_tlast;
        EX_STREAM:begin
            if(pre_axis_out.axis_tvalid && pre_axis_out.axis_tready && pre_axis_out.axis_tcnt == length-16'd2)
                    pre_axis_out.axis_tlast <= 1'b1;
            else if(pre_axis_out.axis_tvalid && pre_axis_out.axis_tready && pre_axis_out.axis_tlast)
                    pre_axis_out.axis_tlast <= 1'b0;
            else    pre_axis_out.axis_tlast <= pre_axis_out.axis_tlast;
        end
        default:begin
            if(pre_axis_out.axis_tvalid && pre_axis_out.axis_tready && pre_axis_out.axis_tlast)
                    pre_axis_out.axis_tlast <= 1'b0;
            else    pre_axis_out.axis_tlast <= pre_axis_out.axis_tlast;
        end
        endcase
    end
// -- user
always@(posedge clock,negedge rst_n)
    if(~rst_n)  pre_axis_out.axis_tuser <= '0;
    else
        case(nstate)
        IDLE,AXIS_STREAM:
            if(axis_in.axis_tvalid && axis_in.axis_tready)
                    pre_axis_out.axis_tuser <= axis_in.axis_tuser;
            else    pre_axis_out.axis_tuser <= pre_axis_out.axis_tuser;
        EX_STREAM:begin
            if(axis_in.axis_tvalid && axis_in.axis_tready)
                    pre_axis_out.axis_tuser <= axis_in.axis_tuser;
            else    pre_axis_out.axis_tuser <= '0;
        end
        default:begin
            // if(pre_axis_out.axis_tvalid && pre_axis_out.axis_tready)
            //         pre_axis_out.axis_tvalid <= 1'b0;
            // else    pre_axis_out.axis_tvalid <= pre_axis_out.axis_tvalid;
        end
        endcase

assign pre_axis_out.axis_tkeep  = '1;

logic   en_up_stream;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  en_up_stream    <= 1'b0;
    else
        case(nstate)
        EX_STREAM:  en_up_stream    <= 1'b0;
        default:    en_up_stream    <= 1'b1;
        endcase

assign axis_in.axis_tready  = en_up_stream && pre_axis_out.axis_tready;
//----<< >>------------
axis_connect_pipe axis_connect_pipe_inst(
/*  axi_stream_inf.slaver */  .axis_in      (pre_axis_out   ),
/*  axi_stream_inf.master */  .axis_out     (axis_out       )
);

//----<< DATA INTERCONNECT >>------------------------------

endmodule
