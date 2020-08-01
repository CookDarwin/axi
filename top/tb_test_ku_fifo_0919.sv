/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/9/19 
madified:
***********************************************/
`timescale 1ns/1ps
module tb_test_ku_fifo_0919;
import AxiBfmPkg::*;
logic   pclk;
logic   prst_n;


clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(148.5     	)
)clock_rst_pixel(
	.clock			(pclk   	),
	.rst_x			(prst_n  	)
);
localparam DSIZE    = 4;

axi_stream_inf #(DSIZE) in_inf (pclk,prst_n,1'b1);
axi_stream_inf #(DSIZE) out_inf (pclk,prst_n,1'b1);

AxiStreamMasterBfm_c #(DSIZE,"OFF") MasterBfm = new(in_inf);
AxiStreamSlaverBfm_c #(DSIZE)       SlaverBfm = new(out_inf);

initial begin
    #(1us);
    #(100ns);
    @(posedge pclk);
    forever begin
        SlaverBfm.get_data(0,0);
    end
end



logic   full ;
logic   empty;
bit     rd_en;

assign  rd_en    = out_inf.axis_tready;

ku_long_fifo_4bit #(
    .LENGTH  (1024*8*5+7000)
)fifo_ku_18bit_inst(
/*  input              */ .wr_clk   (pclk       ),
/*  input              */ .wr_rst   (!prst_n    ),
/*  input              */ .rd_clk   (pclk       ),
/*  input              */ .rd_rst   (!prst_n    ),
/*  input [DSIZE-1:0]  */ .din      (in_inf.axis_tdata      ),
/*  input              */ .wr_en    (in_inf.axis_tvalid     ),
/*  input              */ .rd_en    (rd_en                  ),
/*  output [DSIZE-1:0] */ .dout     (out_inf.axis_tdata     ),
/*  output             */ .full     (full                   ),
/*  output             */ .empty    (empty                  )
);
// fifo_ku #(
//     .DSIZE      (DSIZE  ),
//     .LENGTH     (1024   )
// )fifo_ku_inst(
// /*  input              */ .wr_clk   (pclk       ),
// /*  input              */ .wr_rst   (!prst_n    ),
// /*  input              */ .rd_clk   (pclk       ),
// /*  input              */ .rd_rst   (!prst_n    ),
// /*  input [DSIZE-1:0]  */ .din      (in_inf.axis_tdata      ),
// /*  input              */ .wr_en    (in_inf.axis_tvalid     ),
// /*  input              */ .rd_en    (rd_en                  ),
// /*  output [DSIZE-1:0] */ .dout     (out_inf.axis_tdata     ),
// /*  output             */ .full     (full                   ),
// /*  output             */ .empty    (empty                  ),
// /*  output [LSIZE-1:0] */ .rdcount  (),
// /*  output [LSIZE-1:0] */ .wrcount  ()
// );

assign in_inf.axis_tready   = !full;
assign out_inf.axis_tvalid  = !empty;
assign out_inf.axis_tlast   = 1'b0;

logic [DSIZE-1:0]   data [$];

initial begin
    #(1us);
    data   = {>>{8'd1,8'd2,8'd3,8'd4,'1}};
    forever
        MasterBfm.gen_axi_stream(0,30,data);
end


endmodule
