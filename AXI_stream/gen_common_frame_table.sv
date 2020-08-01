/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript: 通用报文格式生成器
author : Cook.Darwin
Version: VERA.0.0
creaded: 2016/12/16 
madified:
***********************************************/
`timescale 1ns/1ps
module gen_common_frame_table #(
    parameter   MASTER_MODE = "OFF",
    parameter   FIELD_TOTLE = 11,        // MAX 16 :: default IP Frame
    parameter   DSIZE       = 8,
    //Field 0
    //---------------------
    parameter   F0_LEN  = 1,        //MAX 8
    parameter   F0_NAME = "version+head length",
    //Field 1
    //---------------------
    parameter   F1_LEN  = 1,
    parameter   F1_NAME = "TOS",
    //Field 2
    //---------------------
    parameter   F2_LEN  = 2,
    parameter   F2_NAME = "totle length",
    //Field 3
    //---------------------
    parameter   F3_LEN  = 2,
    parameter   F3_NAME = "identify",
    //Field 4
    //---------------------
    parameter   F4_LEN  = 1,
    parameter   F4_NAME = "flag + offset MSB",
    //Field 5
    //---------------------
    parameter   F5_LEN  = 1,
    parameter   F5_NAME = "offset LSB",
    //Field 6
    //---------------------
    parameter   F6_LEN  = 1,
    parameter   F6_NAME = "TTL",
    //Field 7
    //---------------------
    parameter   F7_LEN  = 1,
    parameter   F7_NAME = "sub protocol",
    //Field 8
    //---------------------
    parameter   F8_LEN  = 2,
    parameter   F8_NAME = "head CRC",
    //Field 9
    //---------------------
    parameter   F9_LEN  = 4,
    parameter   F9_NAME = "source ip addr",
    //Field 10
    //---------------------
    parameter   F10_LEN  = 4,
    parameter   F10_NAME = "destination ip addr",
    //Field 11
    //---------------------
    parameter   F11_LEN  = 1,
    parameter   F11_NAME = "Filed 11",
    //Field 12
    //---------------------
    parameter   F12_LEN  = 1,
    parameter   F12_NAME = "Filed 12",
    //Field 13
    //---------------------
    parameter   F13_LEN  = 1,
    parameter   F13_NAME = "Field 13",
    //Field 14
    //---------------------
    parameter   F14_LEN  = 1,
    parameter   F14_NAME = "Field 14",
    //Field 15
    //---------------------
    parameter   F15_LEN  = 1,
    parameter   F15_NAME = "Field 15"
)(
    input                            enable,
    input [F0_LEN *DSIZE-1:0]        f0_value,
    input [F1_LEN *DSIZE-1:0]        f1_value,
    input [F2_LEN *DSIZE-1:0]        f2_value,
    input [F3_LEN *DSIZE-1:0]        f3_value,
    input [F4_LEN *DSIZE-1:0]        f4_value,
    input [F5_LEN *DSIZE-1:0]        f5_value,
    input [F6_LEN *DSIZE-1:0]        f6_value,
    input [F7_LEN *DSIZE-1:0]        f7_value,
    input [F8_LEN *DSIZE-1:0]        f8_value,
    input [F9_LEN *DSIZE-1:0]        f9_value,
    input [F10_LEN*DSIZE-1:0]        f10_value,
    input [F11_LEN*DSIZE-1:0]        f11_value,
    input [F12_LEN*DSIZE-1:0]        f12_value,
    input [F13_LEN*DSIZE-1:0]        f13_value,
    input [F14_LEN*DSIZE-1:0]        f14_value,
    input [F15_LEN*DSIZE-1:0]        f15_value,
    axi_stream_inf.master            cm_tb
);

import DataInterfacePkg::*;


localparam  F0_SUM_LEN = F0_LEN;
localparam  F1_SUM_LEN = F0_SUM_LEN + F1_LEN;
localparam  F2_SUM_LEN = F1_SUM_LEN + F2_LEN;
localparam  F3_SUM_LEN = F2_SUM_LEN + F3_LEN;
localparam  F4_SUM_LEN = F3_SUM_LEN + F4_LEN;
localparam  F5_SUM_LEN = F4_SUM_LEN + F5_LEN;
localparam  F6_SUM_LEN = F5_SUM_LEN + F6_LEN;
localparam  F7_SUM_LEN = F6_SUM_LEN + F7_LEN;

localparam  F8_SUM_LEN  = F7_SUM_LEN + F8_LEN;
localparam  F9_SUM_LEN  = F8_SUM_LEN + F9_LEN;
localparam  F10_SUM_LEN = F9_SUM_LEN + F10_LEN;
localparam  F11_SUM_LEN = F10_SUM_LEN+ F11_LEN;
localparam  F12_SUM_LEN = F11_SUM_LEN+ F12_LEN;
localparam  F13_SUM_LEN = F12_SUM_LEN+ F13_LEN;
localparam  F14_SUM_LEN = F13_SUM_LEN+ F14_LEN;
localparam  F15_SUM_LEN = F14_SUM_LEN+ F15_LEN;

localparam  FIELD_LENGTH =  FIELD_TOTLE==1 ? F0_SUM_LEN :
                            FIELD_TOTLE==2 ? F1_SUM_LEN :
                            FIELD_TOTLE==3 ? F2_SUM_LEN :
                            FIELD_TOTLE==4 ? F3_SUM_LEN :
                            FIELD_TOTLE==5 ? F4_SUM_LEN :
                            FIELD_TOTLE==6 ? F5_SUM_LEN :
                            FIELD_TOTLE==7 ? F6_SUM_LEN :
                            FIELD_TOTLE==8 ? F7_SUM_LEN :
                            FIELD_TOTLE==9 ? F8_SUM_LEN :
                            FIELD_TOTLE==10? F9_SUM_LEN :
                            FIELD_TOTLE==11? F10_SUM_LEN :
                            FIELD_TOTLE==12? F11_SUM_LEN :
                            FIELD_TOTLE==13? F12_SUM_LEN :
                            FIELD_TOTLE==14? F13_SUM_LEN :
                            FIELD_TOTLE==15? F14_SUM_LEN : F15_SUM_LEN ;

wire        clock,rst_n,clken;
assign      clock   = cm_tb.aclk;
assign      rst_n   = cm_tb.aresetn;
assign      clken   = cm_tb.aclken;

typedef enum {IDLE,START,F0,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12,F13,F14,F15,DONE} STATUS;

STATUS  cstate,nstate;


logic   f0_pack_ok;
logic   f1_pack_ok;
logic   f2_pack_ok;
logic   f3_pack_ok;
logic   f4_pack_ok;
logic   f5_pack_ok;
logic   f6_pack_ok;
logic   f7_pack_ok;
logic   f8_pack_ok;
logic   f9_pack_ok;
logic   f10_pack_ok;
logic   f11_pack_ok;
logic   f12_pack_ok;
logic   f13_pack_ok;
logic   f14_pack_ok;
logic   f15_pack_ok;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cstate  <= IDLE;
    else        cstate  <= nstate;

logic   rst_n_pass;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  rst_n_pass  <= 1'b0;
    else        rst_n_pass  <= 1'b1;

always@(*)
    case(cstate)
    IDLE:begin
        if(MASTER_MODE == "OFF")begin
            if(cm_tb.axis_tready && enable)
                    nstate  = F0;
            else    nstate  = IDLE;
        end else begin
            if(enable && rst_n_pass)
                    nstate  = F0;
            else    nstate  = IDLE;
        end
    end
    F0 : if(f0_pack_ok) begin  nstate  =   (FIELD_TOTLE!= 1)?  F1   : DONE;  end else    nstate  = F0;
    F1 : if(f1_pack_ok) begin  nstate  =   (FIELD_TOTLE!= 2)?  F2   : DONE;  end else    nstate  = F1;
    F2 : if(f2_pack_ok) begin  nstate  =   (FIELD_TOTLE!= 3)?  F3   : DONE;  end else    nstate  = F2;
    F3 : if(f3_pack_ok) begin  nstate  =   (FIELD_TOTLE!= 4)?  F4   : DONE;  end else    nstate  = F3;
    F4 : if(f4_pack_ok) begin  nstate  =   (FIELD_TOTLE!= 5)?  F5   : DONE;  end else    nstate  = F4;
    F5 : if(f5_pack_ok) begin  nstate  =   (FIELD_TOTLE!= 6)?  F6   : DONE;  end else    nstate  = F5;
    F6 : if(f6_pack_ok) begin  nstate  =   (FIELD_TOTLE!= 7)?  F7   : DONE;  end else    nstate  = F6;
    F7 : if(f7_pack_ok) begin  nstate  =   (FIELD_TOTLE!= 8)?  F8   : DONE;  end else    nstate  = F7;
    F8 : if(f8_pack_ok) begin  nstate  =   (FIELD_TOTLE!= 9)?  F9   : DONE;  end else    nstate  = F8;
    F9 : if(f9_pack_ok) begin  nstate  =   (FIELD_TOTLE!=10)?  F10  : DONE;  end else    nstate  = F9;
    F10: if(f10_pack_ok)begin  nstate  =   (FIELD_TOTLE!=11)?  F11  : DONE;  end else    nstate  = F10;
    F11: if(f11_pack_ok)begin  nstate  =   (FIELD_TOTLE!=12)?  F12  : DONE;  end else    nstate  = F11;
    F12: if(f12_pack_ok)begin  nstate  =   (FIELD_TOTLE!=13)?  F13  : DONE;  end else    nstate  = F12;
    F13: if(f13_pack_ok)begin  nstate  =   (FIELD_TOTLE!=14)?  F14  : DONE;  end else    nstate  = F13;
    F14: if(f14_pack_ok)begin  nstate  =   (FIELD_TOTLE!=15)?  F15  : DONE;  end else    nstate  = F14;
    F15: if(f15_pack_ok)begin  nstate  =   DONE                           ;  end else    nstate  = F15;
    DONE:   nstate  = IDLE;
    default:nstate  = IDLE;
    endcase

//---->> STATUS SEQUEN CTRL <<---------------------
localparam CSIZE =  FIELD_LENGTH <= 8  ? 3 :
                    FIELD_LENGTH <= 16 ? 4 :
                    FIELD_LENGTH <= 32 ? 5 :
                    FIELD_LENGTH <= 64 ? 6 :
                    FIELD_LENGTH <= 128? 7 :
                    FIELD_LENGTH <= 512? 8 :
                    FIELD_LENGTH <= 1024?9 : 16;

logic[CSIZE-1:0]     cnt;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  cnt     <= {CSIZE{1'b0}};
    else
        case(nstate)
        IDLE:   cnt     <= {CSIZE{1'b0}};
        default:begin
            if(cm_tb.axis_tready && cm_tb.axis_tvalid && cm_tb.aclken)
                    cnt     <= cnt + 1'b1;
            else    cnt     <= cnt;
        end
        endcase

assign f0_pack_ok       = cm_tb.aclken && cm_tb.axis_tready && cm_tb.axis_tvalid && cnt==F0_SUM_LEN - 1;
assign f1_pack_ok       = cm_tb.aclken && cm_tb.axis_tready && cm_tb.axis_tvalid && cnt==F1_SUM_LEN - 1;
assign f2_pack_ok       = cm_tb.aclken && cm_tb.axis_tready && cm_tb.axis_tvalid && cnt==F2_SUM_LEN - 1;
assign f3_pack_ok       = cm_tb.aclken && cm_tb.axis_tready && cm_tb.axis_tvalid && cnt==F3_SUM_LEN - 1;
assign f4_pack_ok       = cm_tb.aclken && cm_tb.axis_tready && cm_tb.axis_tvalid && cnt==F4_SUM_LEN - 1;
assign f5_pack_ok       = cm_tb.aclken && cm_tb.axis_tready && cm_tb.axis_tvalid && cnt==F5_SUM_LEN - 1;
assign f6_pack_ok       = cm_tb.aclken && cm_tb.axis_tready && cm_tb.axis_tvalid && cnt==F6_SUM_LEN - 1;
assign f7_pack_ok       = cm_tb.aclken && cm_tb.axis_tready && cm_tb.axis_tvalid && cnt==F7_SUM_LEN - 1;
assign f8_pack_ok       = cm_tb.aclken && cm_tb.axis_tready && cm_tb.axis_tvalid && cnt==F8_SUM_LEN - 1;
assign f9_pack_ok       = cm_tb.aclken && cm_tb.axis_tready && cm_tb.axis_tvalid && cnt==F9_SUM_LEN - 1;
assign f10_pack_ok      = cm_tb.aclken && cm_tb.axis_tready && cm_tb.axis_tvalid && cnt==F10_SUM_LEN- 1;
assign f11_pack_ok      = cm_tb.aclken && cm_tb.axis_tready && cm_tb.axis_tvalid && cnt==F11_SUM_LEN- 1;
assign f12_pack_ok      = cm_tb.aclken && cm_tb.axis_tready && cm_tb.axis_tvalid && cnt==F12_SUM_LEN- 1;
assign f13_pack_ok      = cm_tb.aclken && cm_tb.axis_tready && cm_tb.axis_tvalid && cnt==F13_SUM_LEN- 1;
assign f14_pack_ok      = cm_tb.aclken && cm_tb.axis_tready && cm_tb.axis_tvalid && cnt==F14_SUM_LEN- 1;
assign f15_pack_ok      = cm_tb.aclken && cm_tb.axis_tready && cm_tb.axis_tvalid && cnt==F15_SUM_LEN- 1;

logic   last_data_mom;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  last_data_mom   <= 1'b0;
    else begin
        if(cm_tb.aclken)begin
                // last_data_mom   <= (cnt==20-2) && ip_head_inf.axis_tready && ip_head_inf.axis_tvalid;
            if(FIELD_LENGTH>1)
                    last_data_mom   <= pipe_last_func(cm_tb.axis_tvalid,cm_tb.axis_tready,last_data_mom,(cnt==FIELD_LENGTH-2));
            else    last_data_mom   <= 1'b1;
        end else    last_data_mom   <= last_data_mom;
    end

//----<< STATUS SEQUEN CTRL >>---------------------
//---->> SUB SEQUEN CTRL <<------------------------
reg[2:0]        subcnt;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n) subcnt       <= 3'd0;
    else begin
        if( cm_tb.aclken)begin
            if(cm_tb.axis_tready && cm_tb.axis_tvalid)begin
                if(!cm_tb.axis_tlast)begin
                    case(cnt)
                    (F0_SUM_LEN - 1),
                    (F1_SUM_LEN - 1),
                    (F2_SUM_LEN - 1),
                    (F3_SUM_LEN - 1),
                    (F4_SUM_LEN - 1),
                    (F5_SUM_LEN - 1),
                    (F6_SUM_LEN - 1),
                    (F7_SUM_LEN - 1),
                    (F8_SUM_LEN - 1),
                    (F9_SUM_LEN - 1),
                    (F10_SUM_LEN- 1),
                    (F11_SUM_LEN- 1),
                    (F12_SUM_LEN- 1),
                    (F13_SUM_LEN- 1),
                    (F14_SUM_LEN- 1),
                    (F15_SUM_LEN- 1):   subcnt  <= 3'd0;
                    default:            subcnt  <= subcnt + 1'b1;
                    endcase
                end else            subcnt  <= 3'd0;
            end else                subcnt  <= subcnt;
        end else                    subcnt  <= subcnt;
    end
//----<< SUB SEQUEN CTRL >>------------------------
//---->> WR DATA <<--------------------------------

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  cm_tb.axis_tdata     <= 8'd0;
    else
        if(cm_tb.axis_tready/* && cm_tb.axis_tvalid*/)begin
            case(nstate)
            F0 : if(!cm_tb.axis_tvalid) cm_tb.axis_tdata  <= f0_value [F0_LEN*DSIZE-1-:DSIZE];  else cm_tb.axis_tdata <= f0_value[(F0_LEN-1-subcnt)*DSIZE-1-:DSIZE];
            F1 : if(f0_pack_ok)         cm_tb.axis_tdata  <= f1_value [F1_LEN*DSIZE-1-:DSIZE];  else cm_tb.axis_tdata <= f1_value[(F1_LEN-1-subcnt)*DSIZE-1-:DSIZE];
            F2 : if(f1_pack_ok)         cm_tb.axis_tdata  <= f2_value [F2_LEN*DSIZE-1-:DSIZE];  else cm_tb.axis_tdata <= f2_value[(F2_LEN-1-subcnt)*DSIZE-1-:DSIZE];
            F3 : if(f2_pack_ok)         cm_tb.axis_tdata  <= f3_value [F3_LEN*DSIZE-1-:DSIZE];  else cm_tb.axis_tdata <= f3_value[(F3_LEN-1-subcnt)*DSIZE-1-:DSIZE];
            F4 : if(f3_pack_ok)         cm_tb.axis_tdata  <= f4_value [F4_LEN*DSIZE-1-:DSIZE];  else cm_tb.axis_tdata <= f4_value[(F4_LEN-1-subcnt)*DSIZE-1-:DSIZE];
            F5 : if(f4_pack_ok)         cm_tb.axis_tdata  <= f5_value [F5_LEN*DSIZE-1-:DSIZE];  else cm_tb.axis_tdata <= f5_value[(F5_LEN-1-subcnt)*DSIZE-1-:DSIZE];
            F6 : if(f5_pack_ok)         cm_tb.axis_tdata  <= f6_value [F6_LEN*DSIZE-1-:DSIZE];  else cm_tb.axis_tdata <= f6_value[(F6_LEN-1-subcnt)*DSIZE-1-:DSIZE];
            F7 : if(f6_pack_ok)         cm_tb.axis_tdata  <= f7_value [F7_LEN*DSIZE-1-:DSIZE];  else cm_tb.axis_tdata <= f7_value[(F7_LEN-1-subcnt)*DSIZE-1-:DSIZE];
            F8 : if(f7_pack_ok)         cm_tb.axis_tdata  <= f8_value [F8_LEN*DSIZE-1-:DSIZE];  else cm_tb.axis_tdata <= f8_value[(F8_LEN-1-subcnt)*DSIZE-1-:DSIZE];
            F9 : if(f8_pack_ok)         cm_tb.axis_tdata  <= f9_value [F9_LEN*DSIZE-1-:DSIZE];  else cm_tb.axis_tdata <= f9_value[(F9_LEN-1-subcnt)*DSIZE-1-:DSIZE];
            F10: if(f9_pack_ok)         cm_tb.axis_tdata  <= f10_value[F10_LEN*DSIZE-1-:DSIZE]; else cm_tb.axis_tdata <= f10_value[(F10_LEN-1-subcnt)*DSIZE-1-:DSIZE];
            F11: if(f10_pack_ok)        cm_tb.axis_tdata  <= f11_value[F11_LEN*DSIZE-1-:DSIZE]; else cm_tb.axis_tdata <= f11_value[(F11_LEN-1-subcnt)*DSIZE-1-:DSIZE];
            F12: if(f11_pack_ok)        cm_tb.axis_tdata  <= f12_value[F12_LEN*DSIZE-1-:DSIZE]; else cm_tb.axis_tdata <= f12_value[(F12_LEN-1-subcnt)*DSIZE-1-:DSIZE];
            F13: if(f12_pack_ok)        cm_tb.axis_tdata  <= f13_value[F13_LEN*DSIZE-1-:DSIZE]; else cm_tb.axis_tdata <= f13_value[(F13_LEN-1-subcnt)*DSIZE-1-:DSIZE];
            F14: if(f13_pack_ok)        cm_tb.axis_tdata  <= f14_value[F14_LEN*DSIZE-1-:DSIZE]; else cm_tb.axis_tdata <= f14_value[(F14_LEN-1-subcnt)*DSIZE-1-:DSIZE];
            F15: if(f14_pack_ok)        cm_tb.axis_tdata  <= f15_value[F15_LEN*DSIZE-1-:DSIZE]; else cm_tb.axis_tdata <= f15_value[(F15_LEN-1-subcnt)*DSIZE-1-:DSIZE];
            default:;
            endcase
        end else begin
            case(nstate)
            IDLE:       cm_tb.axis_tdata  <= f0_value [F0_LEN*DSIZE-1-:DSIZE];
            default:    cm_tb.axis_tdata  <= cm_tb.axis_tdata;
            endcase
        end

//
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  cm_tb.axis_tvalid   <= 1'b0;
    else
        case(nstate)
        F0 ,
        F1 ,
        F2 ,
        F3 ,
        F4 ,
        F5 ,
        F6 ,
        F7 ,
        F8 ,
        F9 ,
        F10,
        F11,
        F12,
        F13,
        F14,
        F15:       cm_tb.axis_tvalid   <= 1'b1;
        default:   cm_tb.axis_tvalid   <= 1'b0;
        endcase

//----<< WR  DATA >>--------------------------------

// assign cm_tb.axis_tkeep = {(DSIZE/8){1'b1}};
assign cm_tb.axis_tkeep = '1;
assign cm_tb.axis_tuser = 1'b0;
assign cm_tb.axis_tlast = last_data_mom;

//--->> SIM <<--------------------------------------
// string  str = "";
//
// always@(*)
//         case(cstate)
//         F0 :    str = F0_NAME;
//         F1 :    str = F1_NAME;
//         F2 :    str = F2_NAME;
//         F3 :    str = F3_NAME;
//         F4 :    str = F4_NAME;
//         F5 :    str = F5_NAME;
//         F6 :    str = F6_NAME;
//         F7 :    str = F7_NAME;
//         F8 :    str = F8_NAME;
//         F9 :    str = F9_NAME;
//         F10:    str = F10_NAME;
//         F11:    str = F11_NAME;
//         F12:    str = F12_NAME;
//         F13:    str = F13_NAME;
//         F14:    str = F14_NAME;
//         F15:    str = F15_NAME;
//         default:str = "IDLE";
//         endcase
//---<< SIM >>--------------------------------------
endmodule
