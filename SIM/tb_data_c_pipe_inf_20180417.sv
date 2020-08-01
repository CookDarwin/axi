/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018-4-17 10:24:55
madified:
***********************************************/
`timescale 1ns/1ps

module tb_data_c_pipe_inf_20180417;

import AxiBfmPkg::*;
localparam  DSIZE = 8;
logic   clock;
logic   rst_n;

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(100     	)
)clock_rst_pixel(
	.clock			(clock   	),
	.rst_x			(rst_n  	)
);

axi_stream_inf #(DSIZE) axis_slaver_inf (clock,rst_n,1'b1);
axi_stream_inf #(DSIZE) axis_master_inf (clock,rst_n,1'b1);

data_inf_c #(DSIZE+1) slaver_inf (clock,rst_n);
data_inf_c #(DSIZE+1) master_inf (clock,rst_n);

axis_to_data_inf #(
    .CONTAIN_LAST   ("ON")
)axis_to_data_inf_head_inst(
/*  axi_stream_inf.slaver */ .axis_in        (axis_slaver_inf  ),
/*  data_inf_c.master     */ .data_out_inf   (slaver_inf       )
);

data_c_pipe_inf data_c_pipe_inf_inst(
/*  data_inf_c.slaver   */  .slaver     (slaver_inf ),
/*  data_inf_c.master   */  .master     (master_inf )
);

data_to_axis_inf_A1 data_to_axis_inf_A1_inst(
/*  input                 */  .last_flag        (1'b0    ),
/*  data_inf_c.slaver     */  .data_slaver      (master_inf                ),
/*  axi_stream_inf.master */  .axis_master      (axis_master_inf           )
);

AxiStreamMasterBfm_c #(DSIZE) master_bfm  = new(axis_slaver_inf);
AxiStreamSlaverBfm_c #(DSIZE) slaver_bfm  = new(axis_master_inf);

initial begin
    repeat(1000)
        slaver_bfm.get_data($urandom_range(10,100));
end

initial begin
    repeat(1000)
        rand_stream_tk($urandom_range(10,100),1+$urandom_range(1,10)*$urandom_range(0,4));
end

task automatic rand_stream_tk(int send_rate,int len);
logic [7:0]     s00_data [$];
    // #(10us);
    for(int CC=0;CC<len;CC++)
        s00_data[CC]    = $urandom_range(0,255);
    master_bfm.gen_axi_stream(0,send_rate,s00_data);
endtask:rand_stream_tk

//--->> TRACK <<------------------------
typedef struct {
    logic [7:0]     data;
    logic           last;
} DataS;

mailbox   PreM   = new(100);
mailbox   PostM  = new(100);

DataS     Pre_s;
DataS     Post_s;
DataS     Cmp_s;

always@(negedge clock)begin
    if(axis_slaver_inf.axis_tvalid && axis_slaver_inf.axis_tready)begin
        Pre_s.data = axis_slaver_inf.axis_tdata;
        Pre_s.last = axis_slaver_inf.axis_tlast;
        PreM.put(Pre_s);
    end
end


always@(negedge clock)begin
    if(axis_master_inf.axis_tvalid && axis_master_inf.axis_tready)begin
        Post_s.data = axis_master_inf.axis_tdata;
        Post_s.last = axis_master_inf.axis_tlast;

        PreM.try_get(Cmp_s);

        if((Cmp_s.data != Post_s.data) || (Cmp_s.last != Post_s.last))begin
            $error("\n## ERROR IN STREAM ##\n");
            repeat(3)
                @(posedge clock);
            $stop;
        end

    end
end
//---<< TRACK >>------------------------
endmodule
