/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.1.0 2018-3-22 16:45:43
    can set where pack_data at
creaded: 2017/3/16 
madified:
***********************************************/
`timescale 1ns/1ps
module data_inf_planer_A1 #(
    parameter LAT   = 3,
    parameter DSIZE = 8,
    parameter HEAD  = "ON"
)(
    input                 clock,
    input                 rst_n,
    input [DSIZE-1:0]     pack_data,
    data_inf.slaver       slaver,
    data_inf.master       master        //HEAD=="ON" : {pack_data,slaver.data}
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

localparam DEPTH = (LAT+2<5)? 4 : LAT+2;

logic   fifo_empty;
logic   fifo_full ;
logic [slaver.DSIZE+DSIZE-1:0]  hwdata;

assign hwdata = (HEAD=="ON" || HEAD=="TRUE")? {pack_data,lat_data} : {lat_data,pack_data};

common_fifo #(           //fifo can stack DEPTH+1 "DATA"
    .DEPTH      (DEPTH     ),
    .DSIZE      (slaver.DSIZE+DSIZE)
)fifo_inst(
/*    input                     */  .clock          (clock               ),
/*    input                     */  .rst_n          (rst_n               ),
/*    input [DSIZE-1:0]         */  .wdata          (hwdata              ),
/*    input                     */  .wr_en          (lat_vld             ),
/*    output logic[DSIZE-1:0]   */  .rdata          (master.data         ),
/*    input                     */  .rd_en          (master.ready        ),
/*    output logic              */  .empty          (fifo_empty          ),
/*    output logic              */  .full           (fifo_full           ),
/*    output                    */  .count          ()
);

assign slaver.ready = master.ready;
// assign slaver.ready = master.ready && !fifo_full;
assign master.valid = !fifo_empty;

endmodule
