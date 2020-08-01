/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/8/7 
madified:
***********************************************/
`timescale 1ns/1ps
module tb_data_intc_S2M_0807;
import AxiBfmPkg::*;
logic   pclk;
logic   prst_n;

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(50			),
	.FreqM			(148.5     	)
)clock_rst_pixel(
	.clock			(pclk   	),
	.rst_x			(prst_n  	)
);

localparam NUM = 5;
logic [$clog2(NUM)-1:0]     addr;


axi_stream_inf #(8)    axis_s00   (pclk,prst_n,1'b1);
axi_stream_inf #(8)    axis_m00   [NUM-1:0] (pclk,prst_n,1'b1);
data_inf #(8)          s00    ();
data_inf #(8)          m00   [NUM-1:0] ();

data_inf_c #(8)          s00_c    (pclk,prst_n);
data_inf_c #(8)          m00_c   [NUM-1:0] (pclk,prst_n);


data_pipe_interconnect_S2M_verb #(
    .NUM    (NUM)
)inst(
/*  input             */  .clock        (pclk   ),
/*  input             */  .rst_n        (prst_n ),
/*  input             */  .clk_en       (1'b1   ),
/*  input [NSIZE-1:0] */  .addr         (addr   ),       // sync to s00.valid
/*  data_inf.master   */  .m00          (m00    ),//[NUM-1:0],
/*  data_inf.slaver   */  .s00          (s00    )
);

axis_to_data_inf axis_to_data_inf_inst(
/*  axi_stream_inf.slaver*/  .axis_in           (axis_s00   ),
/*  data_inf_c.master    */  .data_out_inf      (s00_c      )
);

data_inf_B2A data_inf_B2A_inst(
/*  data_inf_c.slaver */    .slaver     (s00_c  ),
/*  data_inf.master   */    .master     (s00    )
);

AxiStreamMasterBfm_c #(8) MasterBfm = new(axis_s00);
AxiStreamSlaverBfm_c #(8) SlaverBfm [NUM-1:0];
event   erate;
int     ready_rate = 100;
logic [NUM-1:0] rd_en;
logic [7:0]     chk_data [NUM-1:0];
mailbox         data_box [NUM-1:0];

genvar KK;
generate
for(KK=0;KK<NUM;KK++)begin
data_inf_A2B data_inf_A2B_inst(
/*  data_inf.slaver   */  .slaver   (m00[KK]    ),
/*  data_inf_c.master */  .master   (m00_c[KK]  )
);

data_to_axis_inf_A1 data_to_axis_inf_A1_inst(
/*  input                */   .last_flag        (1'b0           ),
/*  data_inf_c.slaver    */   .data_slaver      (m00_c[KK]      ),
/*  axi_stream_inf.master*/   .axis_master      (axis_m00[KK]   )
);
initial begin
    data_box[KK]    = new(100);
    SlaverBfm[KK]   = new(axis_m00[KK]);
    wait(erate.triggered());
    repeat(10)
        SlaverBfm[KK].get_data(ready_rate);
end

// xilinx_fifo #(
//     .ENABLE_SIM ("TRUE"),
//     .DSIZE      (8      )
// )xilinx_fifo_inst(
// /*   input              */ .wr_clk  (pclk       ),
// /*   input              */ .wr_rst  (!prst_n    ),
// /*   input              */ .rd_clk  (pclk       ),
// /*   input              */ .rd_rst  (!prst_n    ),
// /*   input [DSIZE-1:0]  */ .din     (s00.data   ),
// /*   input              */ .wr_en   ((s00.valid && s00.ready && (addr == KK))),
// /*   input              */ .rd_en   (rd_en[KK]  ),
// /*   output [DSIZE-1:0] */ .dout    (chk_data[KK]),
// /*   output             */ .full    (),
// /*   output             */ .empty   ()
// );

always@(posedge pclk)begin
    if(s00.valid && s00.ready && (addr == KK))
            data_box[KK].put(s00.data);
end

// assign rd_en[KK]    = m00[KK].valid && m00[KK].ready;

always@(posedge pclk)
    if(m00[KK].valid && m00[KK].ready)begin
        data_box[KK].try_get(chk_data[KK]);
        if(m00[KK].data != chk_data[KK])begin
            $display("DATA,Error @ %d,Expect %h,But %h",KK,chk_data[KK],m00[KK].data);
            $stop;
        end
    end


end
endgenerate

int CC;

task automatic simple_test_tk(int send_rate,int get_rate);
logic [7:0]     s00_data [$];
    #(10us);
    for(CC=0;CC<100;CC++)
        s00_data[CC]    = CC%10;
    fork
        MasterBfm.gen_axi_stream(0,send_rate,s00_data);
        // addr_flow_data();
        addr_random();
        set_rate_tk(get_rate);
    join
endtask:simple_test_tk

task automatic addr_flow_data();
    addr = 0;
    forever begin
        @(posedge axis_s00.aclk)
            addr = axis_s00.axis_tdata % 8;
    end
endtask:addr_flow_data

task automatic addr_random();
    addr = 0;
    forever begin
        @(posedge axis_s00.aclk)
            addr = $urandom_range(8-1,0);
    end
endtask:addr_random

task automatic set_rate_tk(int rate);
    ready_rate = rate;
    -> erate;
endtask:set_rate_tk


initial begin
    simple_test_tk(50,50);
end


endmodule
