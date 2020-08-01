/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/16 
madified:
***********************************************/
`timescale 1ns/1ps
module data_inf_planer #(
    parameter LAT   = 3,
    parameter DSIZE = 8
)(
    input                 clock,
    input                 rst_n,
    input [DSIZE-1:0]     pack_data,
    data_inf.slaver       slaver,
    data_inf.master       master        //{pack_data,slaver.data}
);


logic                       lat_vld;
logic [slaver.DSIZE-1:0]    lat_data;

latency #(
	.LAT       (LAT  ),
	.DSIZE	   (1+slaver.DSIZE  )
)latency_inst(
/*	input					*/ .clk        (clock                  ),
/*	input					*/ .rst_n      (rst_n                  ),
/*	input [DSIZE-1:0]		*/ .d          ({(slaver.valid&&slaver.ready),slaver.data}         ),
/*	output[DSIZE-1:0]		*/ .q          ({lat_vld,lat_data}     )
);

localparam DEPTH = (LAT<5)? 4 : LAT;

logic   fifo_empty;
logic   fifo_full ;

common_fifo #(           //fifo can stack DEPTH+1 "DATA"
    .DEPTH      (DEPTH     ),
    .DSIZE      (slaver.DSIZE+DSIZE)
)fifo_inst(
/*    input                     */  .clock          (clock               ),
/*    input                     */  .rst_n          (rst_n               ),
/*    input [DSIZE-1:0]         */  .wdata          ({pack_data,lat_data}         ),
/*    input                     */  .wr_en          (lat_vld             ),
/*    output logic[DSIZE-1:0]   */  .rdata          (master.data         ),
/*    input                     */  .rd_en          (master.ready        ),
/*    output logic              */  .empty          (fifo_empty          ),
/*    output logic              */  .full           (fifo_full           )
);

assign slaver.ready = master.ready;
assign master.valid = !fifo_empty;

endmodule
