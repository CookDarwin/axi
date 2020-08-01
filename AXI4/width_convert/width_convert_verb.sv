/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERB.0.0
    odd width can parse now
creaded: 2016/11/21 
madified:
***********************************************/
`timescale 1ns/1ps
module width_convert_verb #(
    parameter   ISIZE   = 8,
    parameter   OSIZE   = 8
)(
    input                           clock,
    input                           rst_n,
    input [ISIZE-1:0]               wr_data,
    input                           wr_vld,
    output logic                    wr_ready,
    input                           wr_last,
    input                           wr_align_last,      //can be leave 1'b0
    output logic[OSIZE-1:0]         rd_data,
    output logic                    rd_vld,
    input                           rd_ready,
    output                          rd_last
);

localparam ODI  = OSIZE/ISIZE;
localparam IDO  = ISIZE/OSIZE;
localparam ILG  = $clog2(ISIZE);
localparam OLG  = $clog2(OSIZE);
//--->>
localparam ODD0_OSIZE = (OLG>=ILG)? OSIZE/(2**(OLG-ILG)) : 0;

logic [ODD0_OSIZE-1:0]  odd0_rd_data;
logic                   odd0_rd_vld;
logic                   odd0_rd_ready;
logic                   odd0_rd_last;

//--->>
localparam ODD1_OSIZE = (ILG>=OLG)? OSIZE * 2**(ILG-OLG+1) : 0;

logic [ODD1_OSIZE-1:0]  odd1_rd_data;
logic                   odd1_rd_vld;
logic                   odd1_rd_ready;
logic                   odd1_rd_last;

logic [ODD1_OSIZE-1:0]  pipe_rd_data;
logic                   pipe_rd_vld;
logic                   pipe_rd_ready;
logic                   pipe_rd_last;

generate
if(ISIZE%OSIZE == 0 || OSIZE%ISIZE == 0)begin:IO_CORE_BLOCK0
width_convert #(
    .ISIZE      (ISIZE  ),
    .OSIZE      (OSIZE  )
)width_convert_inst(
/*  input                      */     .clock            (clock           ),
/*  input                      */     .rst_n            (rst_n           ),
/*  input [ISIZE-1:0]          */     .wr_data          (wr_data         ),
/*  input                      */     .wr_vld           (wr_vld          ),
/*  output logic               */     .wr_ready         (wr_ready        ),
/*  input                      */     .wr_last          (wr_last         ),
/*  input                      */     .wr_align_last    (wr_align_last   ),      //can be leave 1'b0
/*  output logic[OSIZE-1:0]    */     .rd_data          (rd_data         ),
/*  output logic               */     .rd_vld           (rd_vld          ),
/*  input                      */     .rd_ready         (rd_ready        ),
/*  output                     */     .rd_last          (rd_last         )
);
end else if(ISIZE < OSIZE )begin:IO_CORE_BLOCK1
odd_width_convert #(
    .ISIZE      (ISIZE  ),
    .OSIZE      (ODD0_OSIZE)
)odd_width_convert_inst(
/*  input                     */      .clock            (clock          ),
/*  input                     */      .rst_n            (rst_n          ),
/*  input [ISIZE-1:0]         */      .wr_data          (wr_data        ),
/*  input                     */      .wr_vld           (wr_vld         ),
/*  output logic              */      .wr_ready         (wr_ready       ),
/*  input                     */      .wr_last          (wr_last        ),
/*  output logic[OSIZE-1:0]   */      .rd_data          (odd0_rd_data   ),
/*  output logic              */      .rd_vld           (odd0_rd_vld    ),
/*  input                     */      .rd_ready         (odd0_rd_ready  ),
/*  output logic              */      .rd_last          (odd0_rd_last   )
);

width_convert #(
    .ISIZE      (ODD0_OSIZE  ),
    .OSIZE      (OSIZE  )
)width_convert_inst(
/*  input                      */     .clock            (clock           ),
/*  input                      */     .rst_n            (rst_n           ),
/*  input [ISIZE-1:0]          */     .wr_data          (odd0_rd_data    ),
/*  input                      */     .wr_vld           (odd0_rd_vld     ),
/*  output logic               */     .wr_ready         (odd0_rd_ready   ),
/*  input                      */     .wr_last          (odd0_rd_last    ),
/*  input                      */     .wr_align_last    (1'b0            ),      //can be leave 1'b0
/*  output logic[OSIZE-1:0]    */     .rd_data          (rd_data         ),
/*  output logic               */     .rd_vld           (rd_vld          ),
/*  input                      */     .rd_ready         (rd_ready        ),
/*  output                     */     .rd_last          (rd_last         )
);
end else if(ISIZE > OSIZE) begin:IO_CORE_BLOCK2

odd_width_convert #(
    .ISIZE      (ISIZE  ),
    .OSIZE      (ODD1_OSIZE)
)odd_width_convert_inst(
/*  input                     */      .clock            (clock          ),
/*  input                     */      .rst_n            (rst_n          ),
/*  input [ISIZE-1:0]         */      .wr_data          (wr_data        ),
/*  input                     */      .wr_vld           (wr_vld         ),
/*  output logic              */      .wr_ready         (wr_ready       ),
/*  input                     */      .wr_last          (wr_last        ),
/*  output logic[OSIZE-1:0]   */      .rd_data          (odd1_rd_data   ),
/*  output logic              */      .rd_vld           (odd1_rd_vld    ),
/*  input                     */      .rd_ready         (odd1_rd_ready  ),
/*  output logic              */      .rd_last          (odd1_rd_last   )
);

// data_connect_pipe #(
//     .DSIZE      (ODD1_OSIZE+1)
// )data_connect_pipe_inst(
// /*  input             */  .clock            (clock  ),
// /*  input             */  .rst_n            (rst_n  ),
// /*  input             */  .clk_en           (1'b1   ),
// /*  input             */  .from_up_vld      (odd1_rd_vld    ),
// /*  input [DSIZE-1:0] */  .from_up_data     ({odd1_rd_last,odd1_rd_data}),
// /*  output            */  .to_up_ready      (odd1_rd_ready  ),
// /*  input             */  .from_down_ready  (pipe_rd_ready  ),
// /*  output            */  .to_down_vld      (pipe_rd_vld    ),
// /*  output[DSIZE-1:0] */  .to_down_data     ({pipe_rd_last,pipe_rd_data})
// );

// assign pipe_rd_data     = odd1_rd_data   ;
// assign pipe_rd_vld      = odd1_rd_vld    ;
// assign odd1_rd_ready    = pipe_rd_ready  ;
// assign pipe_rd_last     = odd1_rd_last   ;

logic   common_fifo_empty;
logic   common_fifo_full;
common_fifo #(
   .DEPTH   (4  ),
   .DSIZE   (ODD1_OSIZE+1  )
)common_fifo_inst(
/* input                   */    .clock             (clock  ),
/* input                   */    .rst_n             (rst_n  ),
/* input [DSIZE-1:0]       */    .wdata             ({odd1_rd_last,odd1_rd_data}),
/* input                   */    .wr_en             (odd1_rd_vld    ),
/* output logic[DSIZE-1:0] */    .rdata             ({pipe_rd_last,pipe_rd_data}),
/* input                   */    .rd_en             (pipe_rd_ready  ),
/* output logic[CSIZE-1:0] */    .count             (),
/* output logic            */    .empty             (common_fifo_empty  ),
/* output logic            */    .full              (common_fifo_full   )
);

assign pipe_rd_vld      = ~common_fifo_empty;
assign odd1_rd_ready    = ~common_fifo_full;

// xilinx_fifo_verb #(
//     .DSIZE      (ODD1_OSIZE+1)
// )xilinx_fifo_verb_inst(
// /*  input              */ .wr_clk   (clock          ),
// /*  input              */ .wr_rst   (!rst_n         ),
// /*  input              */ .rd_clk   (clock          ),
// /*  input              */ .rd_rst   (!rst_n         ),
// /*  input [DSIZE-1:0]  */ .din      ({odd1_rd_last,odd1_rd_data}        ),
// /*  input              */ .wr_en    (odd1_rd_vld && odd1_rd_ready       ),
// /*  input              */ .rd_en    (pipe_rd_ready && pipe_rd_vld       ),
// /*  output [DSIZE-1:0] */ .dout     ({pipe_rd_last,pipe_rd_data}        ),
// /*  output             */ .full     (common_fifo_full   ),
// /*  output             */ .empty    (common_fifo_empty  ),
// /*  output [LSIZE-1:0] */ .rdcount  (),
// /*  output [LSIZE-1:0] */ .wrcount  ()
// );

width_convert #(
    .ISIZE      (ODD1_OSIZE  ),
    .OSIZE      (OSIZE  )
)width_convert_inst(
/*  input                      */     .clock            (clock           ),
/*  input                      */     .rst_n            (rst_n           ),
/*  input [ISIZE-1:0]          */     .wr_data          (pipe_rd_data         ),
/*  input                      */     .wr_vld           (pipe_rd_vld          ),
/*  output logic               */     .wr_ready         (pipe_rd_ready        ),
/*  input                      */     .wr_last          (pipe_rd_last         ),
/*  input                      */     .wr_align_last    (1'b0   ),      //can be leave 1'b0
/*  output logic[OSIZE-1:0]    */     .rd_data          (rd_data         ),
/*  output logic               */     .rd_vld           (rd_vld          ),
/*  input                      */     .rd_ready         (rd_ready        ),
/*  output                     */     .rd_last          (rd_last         )
);

// data_destruct #(
//     .IDSIZE     (ODD1_OSIZE     ),
//     .ODSIZE     (OSIZE          )
// )data_destruct_inst(
// /*  input                    */   .clock        (clock           ),
// /*  input                    */   .rst_n        (rst_n           ),
// /*  input [IDSIZE-1:0]       */   .indata       (pipe_rd_data    ),
// /*  input                    */   .invalid      (pipe_rd_vld     ),
// /*  output logic             */   .inready      (pipe_rd_ready   ),
// /*  input                    */   .inlast       (pipe_rd_last    ),
// /*  output logic[ODSIZE-1:0] */   .outdata      (rd_data         ),
// /*  output logic             */   .outvalid     (rd_vld          ),
// /*  input                    */   .outready     (rd_ready        ),
// /*  output logic             */   .outlast      (rd_last         )
// );
end else if(0)begin:IO_CORE_BLOCK3
    if(ISIZE < OSIZE*2)
        odd_width_convert #(
            .ISIZE      (ISIZE  ),
            .OSIZE      (OSIZE  )
        )odd_width_convert_inst(
        /*  input                     */      .clock            (clock          ),
        /*  input                     */      .rst_n            (rst_n          ),
        /*  input [ISIZE-1:0]         */      .wr_data          (wr_data        ),
        /*  input                     */      .wr_vld           (wr_vld         ),
        /*  output logic              */      .wr_ready         (wr_ready       ),
        /*  input                     */      .wr_last          (wr_last        ),
        /*  output logic[OSIZE-1:0]   */      .rd_data          (rd_data        ),
        /*  output logic              */      .rd_vld           (rd_vld         ),
        /*  input                     */      .rd_ready         (rd_ready       ),
        /*  output logic              */      .rd_last          (rd_last        )
        );
    else
        odd_width_convert_verb #(
            .ISIZE      (ISIZE  ),
            .OSIZE      (OSIZE  )
        )odd_width_convert_inst(
        /*  input                     */      .clock            (clock          ),
        /*  input                     */      .rst_n            (rst_n          ),
        /*  input [ISIZE-1:0]         */      .wr_data          (wr_data        ),
        /*  input                     */      .wr_vld           (wr_vld         ),
        /*  output logic              */      .wr_ready         (wr_ready       ),
        /*  input                     */      .wr_last          (wr_last        ),
        /*  output logic[OSIZE-1:0]   */      .rd_data          (rd_data        ),
        /*  output logic              */      .rd_vld           (rd_vld         ),
        /*  input                     */      .rd_ready         (rd_ready       ),
        /*  output logic              */      .rd_last          (rd_last        )
        );

end
endgenerate

endmodule
