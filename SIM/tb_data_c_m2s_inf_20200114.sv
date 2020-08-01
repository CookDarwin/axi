/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: ###### Tue Jan 14 18:55:26 CST 2020
madified:
***********************************************/
`timescale 1ns/1ps

module tb_data_c_m2s_inf_20200114;

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

axi_stream_inf #(DSIZE) axis_slaver_inf [7:0](clock,rst_n,1'b1);
axi_stream_inf #(DSIZE) axis_master_inf (clock,rst_n,1'b1);

data_inf_c #(DSIZE+1) slaver_inf[7:0] (clock,rst_n);
data_inf_c #(DSIZE+1) master_inf (clock,rst_n);

generate 
for(genvar KK=0;KK<8;KK++)begin 
axis_to_data_inf #(
    .CONTAIN_LAST   ("ON")
)axis_to_data_inf_head_inst(
/*  axi_stream_inf.slaver */ .axis_in        (axis_slaver_inf[KK]  ),
/*  data_inf_c.master     */ .data_out_inf   (slaver_inf[KK]       )
);
end 
endgenerate

// data_c_pipe_inf data_c_pipe_inf_inst(
// /*  data_inf_c.slaver   */  .slaver     (slaver_inf ),
// /*  data_inf_c.master   */  .master     (master_inf )
// );

data_c_intc_M2S_force_robin#(
    .NUM    (8)
)data_c_intc_M2S_force_robin_inst(
/*  data_inf_c.slaver */  .s00      (slaver_inf ),//[NUM-1:0],
/*  data_inf_c.master */  .m00      (master_inf )
);

data_to_axis_inf_A1 data_to_axis_inf_A1_inst(
/*  input                 */  .last_flag        (master_inf.data[DSIZE]    ),
/*  data_inf_c.slaver     */  .data_slaver      (master_inf                ),
/*  axi_stream_inf.master */  .axis_master      (axis_master_inf           )
);

AxiStreamMasterBfm_c #(DSIZE) master_bfm0  = new(axis_slaver_inf[0]);
AxiStreamMasterBfm_c #(DSIZE) master_bfm1  = new(axis_slaver_inf[1]);
AxiStreamMasterBfm_c #(DSIZE) master_bfm2  = new(axis_slaver_inf[2]);
AxiStreamMasterBfm_c #(DSIZE) master_bfm3  = new(axis_slaver_inf[3]);
AxiStreamMasterBfm_c #(DSIZE) master_bfm4  = new(axis_slaver_inf[4]);
AxiStreamMasterBfm_c #(DSIZE) master_bfm5  = new(axis_slaver_inf[5]);
AxiStreamMasterBfm_c #(DSIZE) master_bfm6  = new(axis_slaver_inf[6]);
AxiStreamMasterBfm_c #(DSIZE) master_bfm7  = new(axis_slaver_inf[7]);

AxiStreamSlaverBfm_c #(DSIZE) slaver_bfm  = new(axis_master_inf);

initial begin
    repeat(1000)
        slaver_bfm.get_data($urandom_range(10,100));
end

initial begin
    repeat(1000) begin
        rand_stream_tk0($urandom_range(10,100),1+$urandom_range(1,10)*$urandom_range(0,4));
    end
end

initial begin
    repeat(1000) begin
        rand_stream_tk1($urandom_range(10,100),1+$urandom_range(1,10)*$urandom_range(0,4));
    end
end

initial begin
    repeat(1000) begin
        rand_stream_tk2($urandom_range(10,100),1+$urandom_range(1,10)*$urandom_range(0,4));
    end
end

initial begin
    repeat(1000) begin
        rand_stream_tk3($urandom_range(10,100),1+$urandom_range(1,10)*$urandom_range(0,4));
    end
end

initial begin
    repeat(1000) begin
        rand_stream_tk4($urandom_range(10,100),1+$urandom_range(1,10)*$urandom_range(0,4));
    end
end

initial begin
    repeat(1000) begin
        rand_stream_tk5($urandom_range(10,100),1+$urandom_range(1,10)*$urandom_range(0,4));
    end
end

initial begin
    repeat(1000) begin
        rand_stream_tk6($urandom_range(10,100),1+$urandom_range(1,10)*$urandom_range(0,4));
    end
end

initial begin
    repeat(1000) begin
        rand_stream_tk7($urandom_range(10,100),1+$urandom_range(1,10)*$urandom_range(0,4));
    end
end

task automatic rand_stream_tk0(int send_rate,int len);
logic [7:0]     s00_data [$];
    // #(10us);
    for(int CC=0;CC<len;CC++)
        s00_data[CC]    = $urandom_range(0,9);
    master_bfm0.gen_axi_stream(0,send_rate,s00_data);
endtask:rand_stream_tk0

task automatic rand_stream_tk1(int send_rate,int len);
logic [7:0]     s00_data [$];
    // #(10us);
    for(int CC=0;CC<len;CC++)
        s00_data[CC]    = $urandom_range(10,19);
    master_bfm1.gen_axi_stream(0,send_rate,s00_data);
endtask:rand_stream_tk1

task automatic rand_stream_tk2(int send_rate,int len);
logic [7:0]     s00_data [$];
    // #(10us);
    for(int CC=0;CC<len;CC++)
        s00_data[CC]    = $urandom_range(20,29);
    master_bfm2.gen_axi_stream(0,send_rate,s00_data);
endtask:rand_stream_tk2

task automatic rand_stream_tk3(int send_rate,int len);
logic [7:0]     s00_data [$];
    // #(10us);
    for(int CC=0;CC<len;CC++)
        s00_data[CC]    = $urandom_range(30,39);
    master_bfm3.gen_axi_stream(0,send_rate,s00_data);
endtask:rand_stream_tk3

task automatic rand_stream_tk4(int send_rate,int len);
logic [7:0]     s00_data [$];
    // #(10us);
    for(int CC=0;CC<len;CC++)
        s00_data[CC]    = $urandom_range(40,49);
    master_bfm4.gen_axi_stream(0,send_rate,s00_data);
endtask:rand_stream_tk4

task automatic rand_stream_tk5(int send_rate,int len);
logic [7:0]     s00_data [$];
    // #(10us);
    for(int CC=0;CC<len;CC++)
        s00_data[CC]    = $urandom_range(50,59);
    master_bfm5.gen_axi_stream(0,send_rate,s00_data);
endtask:rand_stream_tk5

task automatic rand_stream_tk6(int send_rate,int len);
logic [7:0]     s00_data [$];
    // #(10us);
    for(int CC=0;CC<len;CC++)
        s00_data[CC]    = $urandom_range(60,69);
    master_bfm6.gen_axi_stream(0,send_rate,s00_data);
endtask:rand_stream_tk6

task automatic rand_stream_tk7(int send_rate,int len);
logic [7:0]     s00_data [$];
    // #(10us);
    for(int CC=0;CC<len;CC++)
        s00_data[CC]    = $urandom_range(70,79);
    master_bfm7.gen_axi_stream(0,send_rate,s00_data);
endtask:rand_stream_tk7

//--->> TRACK <<------------------------
logic[7:0]  last_data;
logic[7:0]  curr_data;

assign  curr_data   = axis_master_inf.axis_tdata;

always@(posedge clock,negedge rst_n)begin 
    if(~rst_n)  last_data   <= 8'd70;
    else begin 
        if(axis_master_inf.axis_tvalid && axis_master_inf.axis_tready)
                last_data   <= curr_data;
        else    last_data   <= last_data;
    end 
end

always@(posedge clock) begin 
    if(axis_master_inf.axis_tvalid && axis_master_inf.axis_tready)begin 
        if(last_data>= 70 && last_data < 80)begin 
            if(!(curr_data>=0 && curr_data<10))
                $stop();
        end else begin 
            if(!( (curr_data - last_data)>0 && (curr_data - last_data)<20) )
                $stop();
        end 
    end 
end


// //---<< TRACK >>------------------------
endmodule
