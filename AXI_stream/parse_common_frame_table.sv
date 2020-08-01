/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript: 通用报文格式解析器
author : Cook.Darwin
Version: VERA.0.0 2017/1/22 
    backup old file
    this use A1
creaded: 2016/12/16 
madified:2017/1/3 
***********************************************/
`timescale 1ns/1ps
// (* axi_stream = "true" *)
module parse_common_frame_table #(
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
    (* up_stream = "true" *)
    axi_stream_inf.slaver                   cm_tb_s,
    (* down_stream = "true" *)
    axi_stream_inf.master                   cm_tb_m,
    axi_stream_inf.mirror                   cm_mirror
);

parse_common_frame_table_A1 #(
   .FIELD_TOTLE (FIELD_TOTLE),     // MAX 16 :: default IP Frame
   .DSIZE       (DSIZE      ),
   .TRY_PARSE   (TRY_PARSE  ),     // just check frame, bypass data
   //Field 0
   //---------------------
   .F0_LEN      (F0_LEN     ),
   .F0_NAME     (F0_NAME    ),
   //Field 1
   //---------------------
   .F1_LEN      (F1_LEN     ),
   .F1_NAME     (F1_NAME    ),
   //Field 2
   //---------------------
   .F2_LEN      (F2_LEN     ),
   .F2_NAME     (F2_NAME    ),
   //Field 3
   //---------------------
   .F3_LEN      (F3_LEN     ),
   .F3_NAME     (F3_NAME    ),
   //Field 4
   //---------------------
   .F4_LEN      (F4_LEN     ),
   .F4_NAME     (F4_NAME    ),
   //Field 5
   //---------------------
   .F5_LEN      (F5_LEN     ),
   .F5_NAME     (F5_NAME    ),
   //Field 6
   //---------------------
   .F6_LEN      (F6_LEN     ),
   .F6_NAME     (F6_NAME    ),
   //Field 7
   //---------------------
   .F7_LEN      (F7_LEN     ),
   .F7_NAME     (F7_NAME    ),
   //Field 8
   //---------------------
   .F8_LEN      (F8_LEN     ),
   .F8_NAME     (F8_NAME    ),
   //Field 9
   //---------------------
   .F9_LEN      (F9_LEN     ),
   .F9_NAME     (F9_NAME    ),
   //Field 10
   //---------------------
   .F10_LEN      (F10_LEN     ),
   .F10_NAME     (F10_NAME    ),
   //Field 11
   //---------------------
   .F11_LEN      (F11_LEN     ),
   .F11_NAME     (F11_NAME    ),
   //Field 12
   //---------------------
   .F12_LEN      (F12_LEN     ),
   .F12_NAME     (F12_NAME    ),
   //Field 13
   //---------------------
   .F13_LEN      (F13_LEN     ),
   .F13_NAME     (F13_NAME    ),
   //Field 14
   //---------------------
   .F14_LEN      (F14_LEN     ),
   .F14_NAME     (F14_NAME    ),
   //Field 15
   //---------------------
   .F15_LEN      (F15_LEN     ),
   .F15_NAME     (F15_NAME    )
)parse_common_frame_table_inst(
/*   input                              */     .enable                (1'b1               ),
/*   output logic [F0_LEN *DSIZE-1:0]   */     .f0_value              (f0_value           ),
/*   output logic [F1_LEN *DSIZE-1:0]   */     .f1_value              (f1_value           ),
/*   output logic [F2_LEN *DSIZE-1:0]   */     .f2_value              (f2_value           ),
/*   output logic [F3_LEN *DSIZE-1:0]   */     .f3_value              (f3_value           ),
/*   output logic [F4_LEN *DSIZE-1:0]   */     .f4_value              (f4_value           ),
/*   output logic [F5_LEN *DSIZE-1:0]   */     .f5_value              (f5_value           ),
/*   output logic [F6_LEN *DSIZE-1:0]   */     .f6_value              (f6_value           ),
/*   output logic [F7_LEN *DSIZE-1:0]   */     .f7_value              (f7_value           ),
/*   output logic [F8_LEN *DSIZE-1:0]   */     .f8_value              (f8_value           ),
/*   output logic [F9_LEN *DSIZE-1:0]   */     .f9_value              (f9_value           ),
/*   output logic [F10_LEN*DSIZE-1:0]   */     .f10_value             (f10_value          ),
/*   output logic [F11_LEN*DSIZE-1:0]   */     .f11_value             (f11_value          ),
/*   output logic [F12_LEN*DSIZE-1:0]   */     .f12_value             (f12_value          ),
/*   output logic [F13_LEN*DSIZE-1:0]   */     .f13_value             (f13_value          ),
/*   output logic [F14_LEN*DSIZE-1:0]   */     .f14_value             (f14_value          ),
/*   output logic [F15_LEN*DSIZE-1:0]   */     .f15_value             (f15_value          ),
/*   output logic                       */     .out_valid             (out_valid          ),
/*   axi_stream_inf.slaver              */     .cm_tb_s               (cm_tb_s            ),
/*   axi_stream_inf.master              */     .cm_tb_m               (cm_tb_m            ),
/*   axi_stream_inf.mirror              */     .cm_mirror             (cm_mirror          )
);


endmodule
