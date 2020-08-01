/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
    build from rpu_ram
creaded: 2017/1/18 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_ram_buffer #(
    parameter   LENGTH = 4096
)(
        input                       wr_en,
        input                       gen_en,
        output                      gen_ready,
        (* up_stream = "true" *)
        axi_stream_inf.slaver       axis_wr_inf,
        (* down_stream = "true" *)
        axi_stream_inf.master       axis_data_inf
);

localparam   ASIZE = 12;

axi_stream_inf #(.DSIZE(ASIZE)) axis_raddr_inf     (.aclk(axis_data_inf.aclk),.aresetn(axis_data_inf.aresetn),.aclken(axis_data_inf.aclken));

logic [ASIZE-1:0]   waddr;
logic               wren;
logic [8-1:0]   wdata;
logic [8-1:0]   rdata;

assign axis_wr_inf.axis_tready  = wr_en;

rpu_Dual_Port_RAM rpu_Dual_Port_RAM (
  .clka     (axis_wr_inf.aclk           ),    // input wire clka
  .ena      (wr_en                      ),      // input wire ena
  .wea      (wren                       ),      // input wire [0 : 0] wea
  .addra    (waddr                      ),  // input wire [11 : 0] addra
  .dina     (wdata                      ),    // input wire [7 : 0] dina
  .clkb     (axis_raddr_inf.aclk        ),    // input wire clkb
  .enb      (axis_raddr_inf.axis_tvalid ),      // input wire enb
  .addrb    (axis_raddr_inf.axis_tdata  ),  // input wire [11 : 0] addrb
  .doutb    (rdata                      )  // output wire [7 : 0] doutb
);

//---->> WRITE  CTRL <<------------------
always@(posedge axis_wr_inf.aclk)
    if(~axis_wr_inf.aresetn)
            waddr   <= {ASIZE{1'b0}};
    else begin
        if(axis_wr_inf.axis_tvalid && axis_wr_inf.axis_tready && axis_wr_inf.axis_tlast)
                waddr   <= {ASIZE{1'b0}};
        else if(axis_wr_inf.axis_tvalid && axis_wr_inf.axis_tready)
                waddr   <= waddr + 1'b1;
        else    waddr   <= waddr;
    end

assign  wren    = axis_wr_inf.axis_tvalid && axis_wr_inf.axis_tready;
assign  wdata   = axis_wr_inf.axis_tdata;
//----<< WRITE  CTRL >>------------------

gen_origin_axis gen_origin_axis_inst(
/*    input                 */  .enable         (gen_en         ),
/*    output logic          */  .ready          (gen_ready      ),
/*    input [15:0]          */  .length         (LENGTH         ),
/*    axi_stream_inf.master */  .axis_out       (axis_raddr_inf )
);
//---->> READ CTRL <<--------------------
wire        rd_en_lat;
wire        rd_last_lat;
//--- ram latency 1 clock
latency #(
	.LAT       (1  ),
	.DSIZE	   (2  )
)latency_inst(
/*	input					*/ .clk        (axis_raddr_inf.aclk    ),
/*	input					*/ .rst_n      (axis_raddr_inf.aresetn ),
/*	input [DSIZE-1:0]		*/ .d          ({(axis_raddr_inf.axis_tvalid && axis_raddr_inf.axis_tready),
                                             (axis_raddr_inf.axis_tvalid && axis_raddr_inf.axis_tready && axis_raddr_inf.axis_tlast)}),
/*	output[DSIZE-1:0]		*/ .q          ({rd_en_lat,rd_last_lat})
);

wire            fifo_empty;
wire [10:0]     fifo_dout;

axi_stream_inf #(.DSIZE(8)) axis_data_pipe_inf     (.aclk(axis_data_inf.aclk),.aresetn(axis_data_inf.aresetn),.aclken(axis_data_inf.aclken));

mac_fifo fifo_inst(
    .clk         (axis_data_inf.aclk          ),     //: IN STD_LOGIC;
    .srst        (!axis_data_inf.aresetn      ),     //: IN STD_LOGIC;
    .din         ({2'b00,rd_last_lat,rdata}   ),//: IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    .wr_en       (rd_en_lat                   ),//: IN STD_LOGIC;
    .rd_en       (axis_data_pipe_inf.axis_tready   ),//: IN STD_LOGIC;
    .dout        (fifo_dout[10:0]             ),//: OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
    .full        (                            ),//: OUT STD_LOGIC;
    .empty       (fifo_empty                  )//: OUT STD_LOGIC;
);


 assign axis_data_pipe_inf.axis_tvalid  = !fifo_empty;
 assign axis_data_pipe_inf.axis_tdata   = fifo_dout[axis_data_pipe_inf.DSIZE-1:0];
 assign axis_data_pipe_inf.axis_tlast   = fifo_dout[axis_data_pipe_inf.DSIZE];
 assign axis_data_pipe_inf.axis_tuser   = 1'b0;
 assign axis_data_pipe_inf.axis_tkeep   = {axis_data_pipe_inf.KSIZE{1'b1}};

 assign axis_raddr_inf.axis_tready = axis_data_pipe_inf.axis_tready;

 //----<< READ CTRL >>--------------------

 axis_connect_pipe axis_connect_pipe_inst(
 /*    axi_stream_inf.slaver   */   .axis_in         (axis_data_pipe_inf ),
 /*    axi_stream_inf.master   */   .axis_out        (axis_data_inf      )
 );

 endmodule
