/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript: 生成大块的值域用于  common_frame_table
author : Cook.Darwin
Version: VERA.0.0
creaded: 2016/12/19 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module gen_big_field_table #(
    parameter   MASTER_MODE = "OFF",
    parameter   DSIZE         = 8,
    parameter   FIELD_LEN     = 16*8,     //MAX 16*8
    parameter   FIELD_NAME    = "Big Filed"
)(
    input                            enable,
    input [DSIZE*FIELD_LEN-1:0]      value,
    (* down_stream = "true" *)
    axi_stream_inf.master            cm_tb
);

initial begin
    assert(FIELD_LEN <= 128)
    else begin
        $error("'gen_big_field_table''FIELD_LEN[%d] MUST SMALLER THAN 129",FIELD_LEN);
        $stop;
    end
end

logic [DSIZE*16*8-1:0]   value_tmp;

// assign  value_tmp   = {value,{(16*8-FIELD_LEN){1'b0}}};
generate
if(FIELD_LEN < 128)
    assign  value_tmp[DSIZE*16*8-1-:DSIZE*FIELD_LEN]   = value;
else
    assign  value_tmp = value;
endgenerate

localparam      F0_LEN   = (FIELD_LEN>=8*1 )? 8 : (FIELD_LEN%8 != 0)? FIELD_LEN%8 : 1;
localparam      F1_LEN   = (FIELD_LEN>=8*2 )? 8 : (FIELD_LEN%8 != 0)? FIELD_LEN%8 : 1;
localparam      F2_LEN   = (FIELD_LEN>=8*3 )? 8 : (FIELD_LEN%8 != 0)? FIELD_LEN%8 : 1;
localparam      F3_LEN   = (FIELD_LEN>=8*4 )? 8 : (FIELD_LEN%8 != 0)? FIELD_LEN%8 : 1;
localparam      F4_LEN   = (FIELD_LEN>=8*5 )? 8 : (FIELD_LEN%8 != 0)? FIELD_LEN%8 : 1;
localparam      F5_LEN   = (FIELD_LEN>=8*6 )? 8 : (FIELD_LEN%8 != 0)? FIELD_LEN%8 : 1;
localparam      F6_LEN   = (FIELD_LEN>=8*7 )? 8 : (FIELD_LEN%8 != 0)? FIELD_LEN%8 : 1;
localparam      F7_LEN   = (FIELD_LEN>=8*8 )? 8 : (FIELD_LEN%8 != 0)? FIELD_LEN%8 : 1;
localparam      F8_LEN   = (FIELD_LEN>=8*9 )? 8 : (FIELD_LEN%8 != 0)? FIELD_LEN%8 : 1;
localparam      F9_LEN   = (FIELD_LEN>=8*10)? 8 : (FIELD_LEN%8 != 0)? FIELD_LEN%8 : 1;
localparam      F10_LEN  = (FIELD_LEN>=8*11)? 8 : (FIELD_LEN%8 != 0)? FIELD_LEN%8 : 1;
localparam      F11_LEN  = (FIELD_LEN>=8*12)? 8 : (FIELD_LEN%8 != 0)? FIELD_LEN%8 : 1;
localparam      F12_LEN  = (FIELD_LEN>=8*13)? 8 : (FIELD_LEN%8 != 0)? FIELD_LEN%8 : 1;
localparam      F13_LEN  = (FIELD_LEN>=8*14)? 8 : (FIELD_LEN%8 != 0)? FIELD_LEN%8 : 1;
localparam      F14_LEN  = (FIELD_LEN>=8*15)? 8 : (FIELD_LEN%8 != 0)? FIELD_LEN%8 : 1;
localparam      F15_LEN  = (FIELD_LEN>=8*16)? 8 : (FIELD_LEN%8 != 0)? FIELD_LEN%8 : 1;

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

localparam      FIELD_TOTLE = FIELD_LEN/8 + (FIELD_LEN%8 != 0);

gen_common_frame_table #(
   .MASTER_MODE         (MASTER_MODE  ),
   .FIELD_TOTLE         (FIELD_TOTLE  ),        // MAX 16 :: default IP Frame
   .DSIZE               (DSIZE        ),
   //Field 0
   //---------------------
  .F0_LEN               (F0_LEN    ),
  .F0_NAME              (FIELD_NAME),
   //Field 1
   //---------------------
   .F1_LEN              (F1_LEN    ),
   .F1_NAME             (FIELD_NAME),
   //Field 2
   //---------------------
   .F2_LEN              (F2_LEN    ),
   .F2_NAME             (FIELD_NAME),
   //Field 3
   //---------------------
   .F3_LEN              (F3_LEN    ),
   .F3_NAME             (FIELD_NAME),
   //Field 4
   //---------------------
   .F4_LEN              (F4_LEN   ),
   .F4_NAME             (FIELD_NAME),
   //Field 5
   //---------------------
   .F5_LEN              (F5_LEN   ),
   .F5_NAME             (FIELD_NAME),
   //Field 6
   //---------------------
   .F6_LEN              (F6_LEN   ),
   .F6_NAME             (FIELD_NAME  ),
   //Field 7
   //---------------------
   .F7_LEN              (F7_LEN   ),
   .F7_NAME             (FIELD_NAME),
   //Field 8
   //---------------------
   .F8_LEN              (F8_LEN   ),
   .F8_NAME             (FIELD_NAME),
   //Field 9
   //---------------------
   .F9_LEN              (F9_LEN   ),
   .F9_NAME             (FIELD_NAME),
   //Field 10
   //---------------------
   .F10_LEN             (F10_LEN   ),
   .F10_NAME            (FIELD_NAME),
   //Field 11
   //---------------------
   .F11_LEN             (F11_LEN   ),
   .F11_NAME            (FIELD_NAME),
   //Field 12
   //---------------------
   .F12_LEN             (F12_LEN   ),
   .F12_NAME            (FIELD_NAME),
   //Field 13
   //---------------------
   .F13_LEN             (F13_LEN   ),
   .F13_NAME            (FIELD_NAME),
   //Field 14
   //---------------------
   .F14_LEN             (F14_LEN   ),
   .F14_NAME            (FIELD_NAME),
   //Field 15
   //---------------------
   .F15_LEN             (F15_LEN   ),
   .F15_NAME            (FIELD_NAME)

)common_frame_table_0(
/*   input                     */       .enable             (enable                                                     ),
/*   input [F0_LEN *DSIZE-1:0] */       .f0_value           (value_tmp[DSIZE*16*8-1-:F0_LEN*DSIZE]                      ),
/*   input [F1_LEN *DSIZE-1:0] */       .f1_value           (value_tmp[DSIZE*16*8-1-F0_SUM_LEN*DSIZE-:F1_LEN*DSIZE]     ),
/*   input [F2_LEN *DSIZE-1:0] */       .f2_value           (value_tmp[DSIZE*16*8-1-F1_SUM_LEN*DSIZE-:F2_LEN*DSIZE]     ),
/*   input [F3_LEN *DSIZE-1:0] */       .f3_value           (value_tmp[DSIZE*16*8-1-F2_SUM_LEN*DSIZE-:F3_LEN*DSIZE]     ),
/*   input [F4_LEN *DSIZE-1:0] */       .f4_value           (value_tmp[DSIZE*16*8-1-F3_SUM_LEN*DSIZE-:F4_LEN*DSIZE]     ),
/*   input [F5_LEN *DSIZE-1:0] */       .f5_value           (value_tmp[DSIZE*16*8-1-F4_SUM_LEN*DSIZE-:F5_LEN*DSIZE]     ),
/*   input [F6_LEN *DSIZE-1:0] */       .f6_value           (value_tmp[DSIZE*16*8-1-F5_SUM_LEN*DSIZE-:F6_LEN*DSIZE]     ),
/*   input [F7_LEN *DSIZE-1:0] */       .f7_value           (value_tmp[DSIZE*16*8-1-F6_SUM_LEN*DSIZE-:F7_LEN*DSIZE]     ),
/*   input [F8_LEN *DSIZE-1:0] */       .f8_value           (value_tmp[DSIZE*16*8-1-F7_SUM_LEN*DSIZE-:F8_LEN*DSIZE]     ),
/*   input [F9_LEN *DSIZE-1:0] */       .f9_value           (value_tmp[DSIZE*16*8-1-F8_SUM_LEN*DSIZE-:F9_LEN*DSIZE]     ),
/*   input [F10_LEN*DSIZE-1:0] */       .f10_value          (value_tmp[DSIZE*16*8-1-F9_SUM_LEN*DSIZE-:F10_LEN*DSIZE]    ),
/*   input [F11_LEN*DSIZE-1:0] */       .f11_value          (value_tmp[DSIZE*16*8-1-F10_SUM_LEN*DSIZE-:F11_LEN*DSIZE]   ),
/*   input [F12_LEN*DSIZE-1:0] */       .f12_value          (value_tmp[DSIZE*16*8-1-F11_SUM_LEN*DSIZE-:F12_LEN*DSIZE]   ),
/*   input [F13_LEN*DSIZE-1:0] */       .f13_value          (value_tmp[DSIZE*16*8-1-F12_SUM_LEN*DSIZE-:F13_LEN*DSIZE]   ),
/*   input [F14_LEN*DSIZE-1:0] */       .f14_value          (value_tmp[DSIZE*16*8-1-F13_SUM_LEN*DSIZE-:F14_LEN*DSIZE]   ),
/*   input [F15_LEN*DSIZE-1:0] */       .f15_value          (value_tmp[DSIZE*16*8-1-F14_SUM_LEN*DSIZE-:F15_LEN*DSIZE]   ),
/*   axi_stream_inf.master     */       .cm_tb              (cm_tb  )
);

endmodule
