/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript: 通用报文格式解析器
author : Cook.Darwin
Version: VERA.0.1
    add out valid signal
Version: VERA.1.0
    add enable signal
creaded: 2016/12/16 
madified:2017/1/3 
***********************************************/
`timescale 1ns/1ps
module parse_common_frame_table_A1 #(
    parameter   FIELD_TOTLE = 11,        // MAX 16 :: default IP Frame
    parameter   DSIZE       = 8,
    parameter   TRY_PARSE   = "OFF",     // just check frame, bypass data
    //Field 0
    //---------------------
    parameter   F0_LEN  = 1,
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
    input                                   enable,
    output logic [F0_LEN *DSIZE-1:0]        f0_value,
    output logic [F1_LEN *DSIZE-1:0]        f1_value,
    output logic [F2_LEN *DSIZE-1:0]        f2_value,
    output logic [F3_LEN *DSIZE-1:0]        f3_value,
    output logic [F4_LEN *DSIZE-1:0]        f4_value,
    output logic [F5_LEN *DSIZE-1:0]        f5_value,
    output logic [F6_LEN *DSIZE-1:0]        f6_value,
    output logic [F7_LEN *DSIZE-1:0]        f7_value,
    output logic [F8_LEN *DSIZE-1:0]        f8_value,
    output logic [F9_LEN *DSIZE-1:0]        f9_value,
    output logic [F10_LEN*DSIZE-1:0]        f10_value,
    output logic [F11_LEN*DSIZE-1:0]        f11_value,
    output logic [F12_LEN*DSIZE-1:0]        f12_value,
    output logic [F13_LEN*DSIZE-1:0]        f13_value,
    output logic [F14_LEN*DSIZE-1:0]        f14_value,
    output logic [F15_LEN*DSIZE-1:0]        f15_value,
    output logic                            out_valid,
    axi_stream_inf.slaver                   cm_tb_s,
    axi_stream_inf.master                   cm_tb_m,
    axi_stream_inf.mirror                   cm_mirror
);
import SystemPkg::*;
import DataInterfacePkg::*;

wire        clock,rst_n,clken;

axi_stream_inf #(.DSIZE(DSIZE)) parse_stream (.aclk(clock),.aresetn(rst_n),.aclken(clken));

generate
if(TRY_PARSE == "ON")begin

assign      clock   = cm_mirror.aclk;
assign      rst_n   = cm_mirror.aresetn;
assign      clken   = cm_mirror.aclken;

assign parse_stream.axis_tkeep = cm_mirror.axis_tkeep ;
assign parse_stream.axis_tuser = cm_mirror.axis_tuser ;
assign parse_stream.axis_tlast = cm_mirror.axis_tlast ;
assign parse_stream.axis_tdata = cm_mirror.axis_tdata ;
assign parse_stream.axis_tvalid= cm_mirror.axis_tvalid;
assign parse_stream.axis_tready= cm_mirror.axis_tready;
if(SIM=="FALSE" || SIM =="OFF")
    assign cm_tb_s.axis_tready     = cm_mirror.axis_tready;
end else begin

assign      clock   = cm_tb_s.aclk;
assign      rst_n   = cm_tb_s.aresetn;
assign      clken   = cm_tb_s.aclken;


assign parse_stream.axis_tkeep = cm_tb_s.axis_tkeep ;
assign parse_stream.axis_tuser = cm_tb_s.axis_tuser ;
assign parse_stream.axis_tlast = cm_tb_s.axis_tlast ;
assign parse_stream.axis_tdata = cm_tb_s.axis_tdata ;
assign parse_stream.axis_tvalid= cm_tb_s.axis_tvalid;
assign parse_stream.axis_tready= cm_tb_m.axis_tready;
assign cm_tb_s.axis_tready     = cm_tb_m.axis_tready;
end
endgenerate

assign cm_tb_m.axis_tkeep = {(DSIZE/8){1'b1}};
assign cm_tb_m.axis_tuser = 1'b0;

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


typedef enum {IDLE,START,F0,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12,F13,F14,F15,DONE,DLAST} STATUS;

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

logic   force_jump;

logic   last_part_ok;
logic   no_data;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cstate  <= IDLE;
    else        cstate  <= nstate;

always@(*)
    case(cstate)
    IDLE:
        if(parse_stream.axis_tvalid && enable)
        // if(parse_stream.axis_tvalid)
                nstate  = F0;
        else    nstate  = IDLE;
    F0 : if(force_jump) nstate  = (TRY_PARSE=="ON")? DLAST : IDLE ;else if(f0_pack_ok) begin  nstate  =   (FIELD_TOTLE!= 1)?  F1   : DONE;  end else    nstate  = F0;
    F1 : if(force_jump) nstate  = (TRY_PARSE=="ON")? DLAST : IDLE ;else if(f1_pack_ok) begin  nstate  =   (FIELD_TOTLE!= 2)?  F2   : DONE;  end else    nstate  = F1;
    F2 : if(force_jump) nstate  = (TRY_PARSE=="ON")? DLAST : IDLE ;else if(f2_pack_ok) begin  nstate  =   (FIELD_TOTLE!= 3)?  F3   : DONE;  end else    nstate  = F2;
    F3 : if(force_jump) nstate  = (TRY_PARSE=="ON")? DLAST : IDLE ;else if(f3_pack_ok) begin  nstate  =   (FIELD_TOTLE!= 4)?  F4   : DONE;  end else    nstate  = F3;
    F4 : if(force_jump) nstate  = (TRY_PARSE=="ON")? DLAST : IDLE ;else if(f4_pack_ok) begin  nstate  =   (FIELD_TOTLE!= 5)?  F5   : DONE;  end else    nstate  = F4;
    F5 : if(force_jump) nstate  = (TRY_PARSE=="ON")? DLAST : IDLE ;else if(f5_pack_ok) begin  nstate  =   (FIELD_TOTLE!= 6)?  F6   : DONE;  end else    nstate  = F5;
    F6 : if(force_jump) nstate  = (TRY_PARSE=="ON")? DLAST : IDLE ;else if(f6_pack_ok) begin  nstate  =   (FIELD_TOTLE!= 7)?  F7   : DONE;  end else    nstate  = F6;
    F7 : if(force_jump) nstate  = (TRY_PARSE=="ON")? DLAST : IDLE ;else if(f7_pack_ok) begin  nstate  =   (FIELD_TOTLE!= 8)?  F8   : DONE;  end else    nstate  = F7;
    F8 : if(force_jump) nstate  = (TRY_PARSE=="ON")? DLAST : IDLE ;else if(f8_pack_ok) begin  nstate  =   (FIELD_TOTLE!= 9)?  F9   : DONE;  end else    nstate  = F8;
    F9 : if(force_jump) nstate  = (TRY_PARSE=="ON")? DLAST : IDLE ;else if(f9_pack_ok) begin  nstate  =   (FIELD_TOTLE!=10)?  F10  : DONE;  end else    nstate  = F9;
    F10: if(force_jump) nstate  = (TRY_PARSE=="ON")? DLAST : IDLE ;else if(f10_pack_ok)begin  nstate  =   (FIELD_TOTLE!=11)?  F11  : DONE;  end else    nstate  = F10;
    F11: if(force_jump) nstate  = (TRY_PARSE=="ON")? DLAST : IDLE ;else if(f11_pack_ok)begin  nstate  =   (FIELD_TOTLE!=12)?  F12  : DONE;  end else    nstate  = F11;
    F12: if(force_jump) nstate  = (TRY_PARSE=="ON")? DLAST : IDLE ;else if(f12_pack_ok)begin  nstate  =   (FIELD_TOTLE!=13)?  F13  : DONE;  end else    nstate  = F12;
    F13: if(force_jump) nstate  = (TRY_PARSE=="ON")? DLAST : IDLE ;else if(f13_pack_ok)begin  nstate  =   (FIELD_TOTLE!=14)?  F14  : DONE;  end else    nstate  = F13;
    F14: if(force_jump) nstate  = (TRY_PARSE=="ON")? DLAST : IDLE ;else if(f14_pack_ok)begin  nstate  =   (FIELD_TOTLE!=15)?  F15  : DONE;  end else    nstate  = F14;
    F15: if(force_jump) nstate  = (TRY_PARSE=="ON")? DLAST : IDLE ;else if(f15_pack_ok)begin  nstate  =   DONE                           ;  end else    nstate  = F15;
    DONE:if(last_part_ok)      nstate  =   DLAST;                                else    nstate  = DONE;
    DLAST:
        if(TRY_PARSE=="ON")
                nstate  = IDLE;
        // else if(force_jump && parse_stream.aclken)
                // nstate  = IDLE;
        // else if(cm_tb_m.axis_tvalid && cm_tb_m.axis_tready && cm_tb_m.axis_tlast && cm_tb_m.aclken)
        // else if(cm_tb_m.axis_tvalid && cm_tb_m.axis_tready && cm_tb_m.aclken)
        //         nstate  = IDLE;
        else if(cm_tb_m.axis_tvalid && cm_tb_m.axis_tready && cm_tb_m.aclken )begin
            if(parse_stream.axis_tvalid)
                    nstate  = F0;
            else    nstate  = IDLE;
        end else    nstate  = DLAST;
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
reg[2:0]             subcnt;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  cnt     <= {CSIZE{1'b0}};
    else
        case(nstate)
        IDLE,DLAST:
                cnt     <= {CSIZE{1'b0}};
        default:begin
            // if(parse_stream.axis_tready && parse_stream.axis_tvalid && parse_stream.aclken && enable && cnt == '0)
            //         cnt     <= cnt + 1'b1;
            // else if(parse_stream.axis_tready && parse_stream.axis_tvalid && parse_stream.aclken && cnt != '0)
            //         cnt     <= cnt + 1'b1;
            // else    cnt     <= cnt;

            if(parse_stream.axis_tready && parse_stream.axis_tvalid && parse_stream.aclken)
                    cnt     <= cnt + 1'b1;
            else    cnt     <= cnt;
        end
        endcase

always@(posedge clock/*,negedge rst_n*/)begin
    f0_pack_ok       <= parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F0_SUM_LEN - 1;
    f1_pack_ok       <= parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F1_SUM_LEN - 1;
    f2_pack_ok       <= parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F2_SUM_LEN - 1;
    f3_pack_ok       <= parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F3_SUM_LEN - 1;
    f4_pack_ok       <= parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F4_SUM_LEN - 1;
    f5_pack_ok       <= parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F5_SUM_LEN - 1;
    f6_pack_ok       <= parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F6_SUM_LEN - 1;
    f7_pack_ok       <= parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F7_SUM_LEN - 1;
    f8_pack_ok       <= parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F8_SUM_LEN - 1;
    f9_pack_ok       <= parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F9_SUM_LEN - 1;
    f10_pack_ok      <= parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F10_SUM_LEN- 1;
    f11_pack_ok      <= parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F11_SUM_LEN- 1;
    f12_pack_ok      <= parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F12_SUM_LEN- 1;
    f13_pack_ok      <= parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F13_SUM_LEN- 1;
    f14_pack_ok      <= parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F14_SUM_LEN- 1;
    f15_pack_ok      <= parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F15_SUM_LEN- 1;
end

assign last_part_ok     = (parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && parse_stream.axis_tlast) || no_data;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  force_jump  <= 1'b0;
    else begin
        if(last_part_ok)
                force_jump  <= 1'b1;
        else if(parse_stream.aclken)
                force_jump  <= 1'b0;
        else    force_jump  <= force_jump;
    end

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  no_data   <= 1'b0;
    else
        case(nstate)
        IDLE:   no_data  <= 1'b0;
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
        F15:       no_data  <= parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && parse_stream.axis_tlast;
        default:   no_data  <= no_data;
        endcase

//----<< STATUS SEQUEN CTRL >>---------------------
//---->> SUB SEQUEN CTRL <<------------------------

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n) subcnt       <= 3'd0;
    else begin
        if( parse_stream.aclken)begin
            case(nstate)
            IDLE,DONE,DLAST:
                 subcnt  <= 3'd0;
            default:begin
                if(parse_stream.axis_tready && parse_stream.axis_tvalid)begin
                    if(~parse_stream.axis_tlast)begin
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
            end
            endcase
        end else                    subcnt  <= subcnt;
    end
//----<< SUB SEQUEN CTRL >>------------------------
//---->> RD DATA <<--------------------------------

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n) begin
        f0_value    <= '0;
        f1_value    <= '0;
        f2_value    <= '0;
        f3_value    <= '0;
        f4_value    <= '0;
        f5_value    <= '0;
        f6_value    <= '0;
        f7_value    <= '0;
        f8_value    <= '0;
        f9_value    <= '0;
        f10_value   <= '0;
        f11_value   <= '0;
        f12_value   <= '0;
        f13_value   <= '0;
        f14_value   <= '0;
        f15_value   <= '0;
    end  else
        if(parse_stream.axis_tready && parse_stream.axis_tvalid)begin
            case(nstate)
            F0 : f0_value[(F0_LEN-subcnt)*DSIZE-1-:DSIZE]       <= enable? parse_stream.axis_tdata : f0_value[(F0_LEN-subcnt)*DSIZE-1-:DSIZE]    ;
            F1 : f1_value[(  F1_LEN-0-subcnt)*DSIZE-1-:DSIZE]   <= enable? parse_stream.axis_tdata : f1_value[(  F1_LEN-0-subcnt)*DSIZE-1-:DSIZE];
            F2 : f2_value[(  F2_LEN-0-subcnt)*DSIZE-1-:DSIZE]   <= enable? parse_stream.axis_tdata : f2_value[(  F2_LEN-0-subcnt)*DSIZE-1-:DSIZE];
            F3 : f3_value[(  F3_LEN-0-subcnt)*DSIZE-1-:DSIZE]   <= enable? parse_stream.axis_tdata : f3_value[(  F3_LEN-0-subcnt)*DSIZE-1-:DSIZE];
            F4 : f4_value[(  F4_LEN-0-subcnt)*DSIZE-1-:DSIZE]   <= enable? parse_stream.axis_tdata : f4_value[(  F4_LEN-0-subcnt)*DSIZE-1-:DSIZE];
            F5 : f5_value[(  F5_LEN-0-subcnt)*DSIZE-1-:DSIZE]   <= enable? parse_stream.axis_tdata : f5_value[(  F5_LEN-0-subcnt)*DSIZE-1-:DSIZE];
            F6 : f6_value[(  F6_LEN-0-subcnt)*DSIZE-1-:DSIZE]   <= enable? parse_stream.axis_tdata : f6_value[(  F6_LEN-0-subcnt)*DSIZE-1-:DSIZE];
            F7 : f7_value[(  F7_LEN-0-subcnt)*DSIZE-1-:DSIZE]   <= enable? parse_stream.axis_tdata : f7_value[(  F7_LEN-0-subcnt)*DSIZE-1-:DSIZE];
            F8 : f8_value[(  F8_LEN-0-subcnt)*DSIZE-1-:DSIZE]   <= enable? parse_stream.axis_tdata : f8_value[(  F8_LEN-0-subcnt)*DSIZE-1-:DSIZE];
            F9 : f9_value[(  F9_LEN-0-subcnt)*DSIZE-1-:DSIZE]   <= enable? parse_stream.axis_tdata : f9_value[(  F9_LEN-0-subcnt)*DSIZE-1-:DSIZE];
            F10: f10_value[(F10_LEN-0-subcnt)*DSIZE-1-:DSIZE]   <= enable? parse_stream.axis_tdata : f10_value[(F10_LEN-0-subcnt)*DSIZE-1-:DSIZE];
            F11: f11_value[(F11_LEN-0-subcnt)*DSIZE-1-:DSIZE]   <= enable? parse_stream.axis_tdata : f11_value[(F11_LEN-0-subcnt)*DSIZE-1-:DSIZE];
            F12: f12_value[(F12_LEN-0-subcnt)*DSIZE-1-:DSIZE]   <= enable? parse_stream.axis_tdata : f12_value[(F12_LEN-0-subcnt)*DSIZE-1-:DSIZE];
            F13: f13_value[(F13_LEN-0-subcnt)*DSIZE-1-:DSIZE]   <= enable? parse_stream.axis_tdata : f13_value[(F13_LEN-0-subcnt)*DSIZE-1-:DSIZE];
            F14: f14_value[(F14_LEN-0-subcnt)*DSIZE-1-:DSIZE]   <= enable? parse_stream.axis_tdata : f14_value[(F14_LEN-0-subcnt)*DSIZE-1-:DSIZE];
            F15: f15_value[(F15_LEN-0-subcnt)*DSIZE-1-:DSIZE]   <= enable? parse_stream.axis_tdata : f15_value[(F15_LEN-0-subcnt)*DSIZE-1-:DSIZE];
            default:;
            endcase
        end else begin
            ;
        end

//----<< RD  DATA >>--------------------------------
// ---->> AXI STREAM <<-----------------------------
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  cm_tb_m.axis_tdata <= 8'd0;
    else
        case(nstate)
        DONE,DLAST:begin
            if(parse_stream.axis_tvalid && parse_stream.axis_tready && parse_stream.aclken)
                    cm_tb_m.axis_tdata <= parse_stream.axis_tdata;
            else    cm_tb_m.axis_tdata <= cm_tb_m.axis_tdata;
        end
        default:;
        endcase

//
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  cm_tb_m.axis_tlast <= 1'd0;
    else
        // if(cm_tb_m.axis_tvalid && cm_tb_m.axis_tready && cm_tb_m.aclken)
            case(nstate)
            DLAST:begin
                cm_tb_m.axis_tlast <= 1'd1;
            end
            default:cm_tb_m.axis_tlast <= 1'd0;
            endcase
        // else    cm_tb_m.axis_tlast <= cm_tb_m.axis_tlast;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  cm_tb_m.axis_tvalid <= 1'd0;
    else begin
        // if(cm_tb_m.axis_tvalid && cm_tb_m.axis_tready && cm_tb_m.aclken)begin
            case(nstate)
            DONE,DLAST:begin
                if(cm_tb_m.aclken)
                        cm_tb_m.axis_tvalid <= pipe_valid_func(parse_stream.axis_tvalid,cm_tb_m.axis_tready,cm_tb_m.axis_tvalid);
                else    cm_tb_m.axis_tvalid <= cm_tb_m.axis_tvalid;
            end
            default:cm_tb_m.axis_tvalid <= 1'd0;
            endcase
        // end else         cm_tb_m.axis_tvalid <= cm_tb_m.axis_tvalid;
    end
// ---->> AXI STREAM <<-----------------------------
//----->> OUTD VALID <<-----------------------------
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  out_valid   <= 1'b0;
    else begin
        if(parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && parse_stream.axis_tlast)
                out_valid   <= 1'b0;
        else
            case(FIELD_TOTLE)
            1 : out_valid <= (parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F0_SUM_LEN - 1) || out_valid;
            2 : out_valid <= (parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F1_SUM_LEN - 1) || out_valid;
            3 : out_valid <= (parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F2_SUM_LEN - 1) || out_valid;
            4 : out_valid <= (parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F3_SUM_LEN - 1) || out_valid;
            5 : out_valid <= (parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F4_SUM_LEN - 1) || out_valid;
            6 : out_valid <= (parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F5_SUM_LEN - 1) || out_valid;
            7 : out_valid <= (parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F6_SUM_LEN - 1) || out_valid;
            8 : out_valid <= (parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F7_SUM_LEN - 1) || out_valid;
            9 : out_valid <= (parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F8_SUM_LEN - 1) || out_valid;
            10: out_valid <= (parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F9_SUM_LEN - 1) || out_valid;
            11: out_valid <= (parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F10_SUM_LEN- 1) || out_valid;
            12: out_valid <= (parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F11_SUM_LEN- 1) || out_valid;
            13: out_valid <= (parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F12_SUM_LEN- 1) || out_valid;
            14: out_valid <= (parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F13_SUM_LEN- 1) || out_valid;
            15: out_valid <= (parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F14_SUM_LEN- 1) || out_valid;
            16: out_valid <= (parse_stream.aclken && parse_stream.axis_tready && parse_stream.axis_tvalid && cnt==F15_SUM_LEN- 1) || out_valid;
            default:;
            endcase
    end
//-----<< OUTD VALID >>-----------------------------
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
