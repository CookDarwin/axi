/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERB.0.0 2017/12/5 
    isize > osize*2
creaded: 2017/4/20 
madified:
***********************************************/
`timescale 1ns/1ps
module odd_width_convert_verb #(
    parameter   ISIZE = 12,
    parameter   OSIZE = 16
)(
    input                           clock,
    input                           rst_n,
    input [ISIZE-1:0]               wr_data,
    input                           wr_vld,
    output logic                    wr_ready,
    input                           wr_last,
    // input                           wr_align_last,      //can be leave 1'b0
    output logic[OSIZE-1:0]         rd_data,
    output logic                    rd_vld,
    input                           rd_ready,
    output logic                    rd_last
);

initial begin
    assert(ISIZE>OSIZE*2)
    else begin
        $error("\nISIZE[%d] must large than OSIZE[%d] 2 product\n",ISIZE,OSIZE);
        $stop;
    end
end

localparam DIV  = ISIZE/OSIZE-1;

logic[ISIZE/DIV-1:0]    Dx_rd_data;
logic                   Dx_rd_vld;
logic                   Dx_rd_ready;
logic                   Dx_rd_last;

logic[ISIZE/DIV-1:0]    fifo_rd_data;
logic                   fifo_rd_vld;
logic                   fifo_rd_ready;
logic                   fifo_rd_last;

width_convert #(
    .ISIZE      (ISIZE  ),
    .OSIZE      (ISIZE/DIV  )
)width_convert_inst(
/*  input                      */     .clock            (clock           ),
/*  input                      */     .rst_n            (rst_n           ),
/*  input [ISIZE-1:0]          */     .wr_data          (wr_data         ),
/*  input                      */     .wr_vld           (wr_vld          ),
/*  output logic               */     .wr_ready         (wr_ready        ),
/*  input                      */     .wr_last          (wr_last         ),
/*  input                      */     .wr_align_last    (1'b0            ),      //can be leave 1'b0
/*  output logic[OSIZE-1:0]    */     .rd_data          (Dx_rd_data      ),
/*  output logic               */     .rd_vld           (Dx_rd_vld       ),
/*  input                      */     .rd_ready         (Dx_rd_ready     ),
/*  output                     */     .rd_last          (Dx_rd_last      )
);

logic   common_fifo_empty;
logic   common_fifo_full;

common_fifo #(
   .DEPTH   (4  ),
   .DSIZE   (ISIZE/DIV  )
)common_fifo_inst(
/* input                   */    .clock             (clock  ),
/* input                   */    .rst_n             (rst_n  ),
/* input [DSIZE-1:0]       */    .wdata             ({Dx_rd_last,Dx_rd_data}),
/* input                   */    .wr_en             (Dx_rd_vld    ),
/* output logic[DSIZE-1:0] */    .rdata             ({fifo_rd_last,fifo_rd_data}),
/* input                   */    .rd_en             (fifo_rd_ready  ),
/* output logic[CSIZE-1:0] */    .count             (),
/* output logic            */    .empty             (common_fifo_empty  ),
/* output logic            */    .full              (common_fifo_full   )
);

assign Dx_rd_ready  = ~common_fifo_full;
assign fifo_rd_vld  = ~common_fifo_empty;


odd_width_convert #(
    .ISIZE      (ISIZE/DIV  ),
    .OSIZE      (OSIZE)
)odd_width_convert_inst(
/*  input                     */      .clock            (clock          ),
/*  input                     */      .rst_n            (rst_n          ),
/*  input [ISIZE-1:0]         */      .wr_data          (fifo_rd_data   ),
/*  input                     */      .wr_vld           (fifo_rd_vld    ),
/*  output logic              */      .wr_ready         (fifo_rd_ready  ),
/*  input                     */      .wr_last          (fifo_rd_last   ),
/*  output logic[OSIZE-1:0]   */      .rd_data          (rd_data        ),
/*  output logic              */      .rd_vld           (rd_vld         ),
/*  input                     */      .rd_ready         (rd_ready       ),
/*  output logic              */      .rd_last          (rd_last        )
);

endmodule
