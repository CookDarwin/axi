/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/20 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_data_combin_aflag_pipe #(
    parameter   IDSIZE  = 2,
    parameter   ASIZE   = 8,
    parameter   ILSIZE  = 8,
    parameter   OLSIZE  = 8,
    parameter   ISIZE   = 8,
    parameter   OSIZE   = 24
)(
    input                       clock,
    input                       rst_n,
    input[IDSIZE-1:0]           in_a_id      ,
    input[ASIZE-1:0]            in_a_addr    ,
    input[ILSIZE-1:0]           in_a_len     ,
    input[2:0]                  in_a_size    ,
    input[1:0]                  in_a_burst   ,
    input[0:0]                  in_a_lock    ,
    input[3:0]                  in_a_cache   ,
    input[2:0]                  in_a_prot    ,
    input[3:0]                  in_a_qos     ,
    input                       in_a_valid   ,
    output                      in_a_ready   ,
    output[IDSIZE-1:0]          out_a_id     ,
    output[ASIZE-1:0]           out_a_addr   ,
    output logic[OLSIZE-1:0]    out_a_len    ,
    output[2:0]                 out_a_size   ,
    output[1:0]                 out_a_burst  ,
    output[0:0]                 out_a_lock   ,
    output[3:0]                 out_a_cache  ,
    output[2:0]                 out_a_prot   ,
    output[3:0]                 out_a_qos    ,
    output                      out_a_valid  ,
    input                       out_a_ready

);

localparam  MODE = (ISIZE<OSIZE)? "COMBIN" : "DESTRUCT" ;

localparam REAL_DST_NSIZE = ISIZE/OSIZE + (ISIZE%OSIZE != 0);
localparam REAL_CBN_NSIZE = OSIZE/ISIZE;

simple_data_pipe #(
    .DSIZE      (ASIZE)
)addr_pipe_inst(
/*    input                   */    .clock      (clock  ),
/*    input                   */    .rst_n      (rst_n  ),
/*    input [DSIZE-1:0]       */    .indata     (in_a_addr  ),
/*    input                   */    .invalid    (in_a_valid ),
/*    output logic            */    .inready    (in_a_ready ),
/*    output logic[DSIZE-1:0] */    .outdata    (out_a_addr ),
/*    output logic            */    .outvalid   (out_a_valid),
/*    input                   */    .outready   (out_a_ready)
);

logic [OLSIZE-1:0]      wlen;

generate
if(MODE=="COMBIN")begin
    // assign wlen = (in_a_len+1)/(OSIZE/ISIZE)-1;
    assign wlen = in_a_len/(OSIZE/ISIZE);  // in_a_len/(OSIZE/ISIZE) == (in_a_len+1)/(OSIZE/ISIZE)-1
    // assign wlen = in_a_len*ISIZE/OSIZE + ISIZE/OSIZE -1;
end else begin
    assign wlen = (in_a_len+1)*(ISIZE/OSIZE)-1;
end
endgenerate

// generate
// if(MODE=="COMBIN")begin
//     assign wlen = (in_a_len+1)/REAL_CBN_NSIZE-1;
// end else begin
//     assign wlen = (in_a_len+1)/REAL_DST_NSIZE-1;
// end
// endgenerate

// simple_data_pipe_slaver #(
//     .DSIZE  (OLSIZE  )
// )len_pipe_inst(
// /*    input                    */    .clock      (clock  ),
// /*    input                    */    .rst_n      (rst_n  ),
// /*    input [DSIZE-1:0]        */    .indata     (wlen   ),
// /*    input                    */    .invalid    (in_a_valid ),
// /*    input                    */    .inready    (in_a_ready ),
// /*    output logic[DSIZE-1:0]  */    .outdata    (out_a_len  ),
// /*    input                    */    .outvalid   (out_a_valid),
// /*    input                    */    .outready   (out_a_ready)
// );

// always@(posedge clock,negedge rst_n)
//     if(~rst_n)  out_a_len   <= '0;
//     else begin
//         if(in_a_valid && out_a_ready)
//                 out_a_len   <= wlen;
//         else    out_a_len   <= out_a_len;
//     end
localparam ILG  = $clog2(ISIZE);
localparam OLG  = $clog2(OSIZE);
localparam ODD1_OSIZE = (ILG>=OLG)? OSIZE * 2**(ILG-OLG+1) : 0;

logic  [24:0]        MA;
logic  [17:0]        MB;
logic  [18+25-1:0]   MP;

generate
if(ISIZE<=OSIZE)begin:CAL_MEFF
    assign  MA = in_a_len;
    assign  out_a_len = MP >> 8;
    assign  MB = ISIZE*256/OSIZE;
end else begin
    if(ISIZE%OSIZE == 0)begin
        assign  MA = in_a_len+1;
        assign  out_a_len = (MP >> 8)-1;
        assign  MB = ISIZE*256/OSIZE;
    end else begin
        assign  MB = in_a_len+1;
        assign  out_a_len = ( MP[35:10] * ODD1_OSIZE/ OSIZE) - 1 + (|MP[9:0] * ODD1_OSIZE/ OSIZE);
        assign  MA = ISIZE*1024/ODD1_OSIZE;
    end
end
endgenerate


MULT_MACRO #(
    .DEVICE("7SERIES"), // Target Device: "7SERIES"
    .LATENCY(1),        // Desired clock cycle latency, 0-4
    .WIDTH_A(25),       // Multiplier A-input bus width, 1-25
    .WIDTH_B(18)        // Multiplier B-input bus width, 1-18
) MULT_MACRO_inst (
    .P      (MP),     // Multiplier output bus, width determined by WIDTH_P parameter
    .A      (MA),     // Multiplier input A bus, width determined by WIDTH_A parameter
    .B      (MB),     // Multiplier input B bus, width determined by WIDTH_B parameter
    .CE     ((in_a_valid && out_a_ready)),   // 1-bit active high input clock enable
    .CLK    (clock), // 1-bit positive edge clock input
    .RST    (!rst_n)  // 1-bit input active high reset
);

// assign out_a_len = MP >> 8;

simple_data_pipe_slaver #(
    .DSIZE  (IDSIZE  )
)id_pipe_inst(
/*    input                    */    .clock      (clock  ),
/*    input                    */    .rst_n      (rst_n  ),
/*    input [DSIZE-1:0]        */    .indata     (in_a_id   ),
/*    input                    */    .invalid    (in_a_valid ),
/*    input                    */    .inready    (in_a_ready ),
/*    output logic[DSIZE-1:0]  */    .outdata    (out_a_id  ),
/*    input                    */    .outvalid   (out_a_valid),
/*    input                    */    .outready   (out_a_ready)
);

simple_data_pipe_slaver #(
    .DSIZE  (3  )
)size_pipe_inst(
/*    input                   */    .clock      (clock  ),
/*    input                   */    .rst_n      (rst_n  ),
/*    input [DSIZE-1:0]       */    .indata     (in_a_size   ),
/*    input                   */    .invalid    (in_a_valid ),
/*    input                   */    .inready    (in_a_ready ),
/*    output logic[DSIZE-1:0] */    .outdata    (out_a_size  ),
/*    input                   */    .outvalid   (out_a_valid),
/*    input                   */    .outready   (out_a_ready)
);

simple_data_pipe_slaver #(
    .DSIZE  (2  )
)burst_pipe_inst(
/*    input                   */    .clock      (clock  ),
/*    input                   */    .rst_n      (rst_n  ),
/*    input [DSIZE-1:0]       */    .indata     (in_a_burst   ),
/*    input                   */    .invalid    (in_a_valid ),
/*    input                   */    .inready    (in_a_ready ),
/*    output logic[DSIZE-1:0] */    .outdata    (out_a_burst  ),
/*    input                   */    .outvalid   (out_a_valid),
/*    input                   */    .outready   (out_a_ready)
);

simple_data_pipe_slaver #(
    .DSIZE  (1  )
)lock_pipe_inst(
/*    input                   */    .clock      (clock  ),
/*    input                   */    .rst_n      (rst_n  ),
/*    input [DSIZE-1:0]       */    .indata     (in_a_lock   ),
/*    input                   */    .invalid    (in_a_valid ),
/*    input                   */    .inready    (in_a_ready ),
/*    output logic[DSIZE-1:0] */    .outdata    (out_a_lock  ),
/*    input                   */    .outvalid   (out_a_valid),
/*    input                   */    .outready   (out_a_ready)
);

simple_data_pipe_slaver #(
    .DSIZE  (4  )
)cache_pipe_inst(
/*    input                   */    .clock      (clock  ),
/*    input                   */    .rst_n      (rst_n  ),
/*    input [DSIZE-1:0]       */    .indata     (in_a_cache   ),
/*    input                   */    .invalid    (in_a_valid ),
/*    input                   */    .inready    (in_a_ready ),
/*    output logic[DSIZE-1:0] */    .outdata    (out_a_cache  ),
/*    input                   */    .outvalid   (out_a_valid),
/*    input                   */    .outready   (out_a_ready)
);

simple_data_pipe_slaver #(
    .DSIZE  (3  )
)prot_pipe_inst(
/*    input                   */    .clock      (clock  ),
/*    input                   */    .rst_n      (rst_n  ),
/*    input [DSIZE-1:0]       */    .indata     (in_a_prot   ),
/*    input                   */    .invalid    (in_a_valid ),
/*    input                   */    .inready    (in_a_ready ),
/*    output logic[DSIZE-1:0] */    .outdata    (out_a_prot  ),
/*    input                   */    .outvalid   (out_a_valid),
/*    input                   */    .outready   (out_a_ready)
);

simple_data_pipe_slaver #(
    .DSIZE  (4  )
)qos_pipe_inst(
/*    input                   */    .clock      (clock  ),
/*    input                   */    .rst_n      (rst_n  ),
/*    input [DSIZE-1:0]       */    .indata     (in_a_qos   ),
/*    input                   */    .invalid    (in_a_valid ),
/*    input                   */    .inready    (in_a_ready ),
/*    output logic[DSIZE-1:0] */    .outdata    (out_a_qos  ),
/*    input                   */    .outvalid   (out_a_valid),
/*    input                   */    .outready   (out_a_ready)
);

endmodule
