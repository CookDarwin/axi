/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/8/23 
madified:
***********************************************/
`timescale 1ns/1ps
module tb_data_c_inf_M2S_0823;
import AxiBfmPkg::*;
logic   pclk;
logic   prst_n;

int CC;
localparam HEIGHT = 1080;

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
data_inf_c #(8)  sub_master_inf [NUM-1:0] (pclk,prst_n);
data_inf_c #(8)  slaver_inf          (pclk,prst_n);
axi_stream_inf #(8) axis_sub_master_inf[NUM-1:0] (pclk,prst_n,1'b1);
axi_stream_inf #(8) axis_slaver_inf (pclk,prst_n,1'b1);

AxiStreamMasterBfm_c #(8,"OFF") MasterBfm[NUM-1:0];
// AxiStreamMasterBfm_c #(8,"OFF") MasterBfm = new(axis_sub_master_inf[1]);
// AxiStreamMasterBfm_c #(8,"OFF") MasterBfm = new(axis_sub_master_inf[2]);
// AxiStreamMasterBfm_c #(8,"OFF") MasterBfm = new(axis_sub_master_inf[3]);
// AxiStreamMasterBfm_c #(8,"OFF") MasterBfm = new(axis_sub_master_inf[4]);

AxiStreamSlaverBfm_c #(8) SlaverBfm = new(axis_slaver_inf);

mailbox  mdata = new(10);

initial begin
    forever begin
        SlaverBfm.get_data(50,0);
    end
end



genvar KK;

generate
for(KK=0;KK<NUM;KK++)begin
    initial begin
        MasterBfm[KK] = new(axis_sub_master_inf[KK]);
    end

    assign sub_master_inf[KK].valid     = axis_sub_master_inf[KK].axis_tvalid;
    assign sub_master_inf[KK].data      = axis_sub_master_inf[KK].axis_tdata;
    assign axis_sub_master_inf[KK].axis_tready = sub_master_inf[KK].ready;
end
endgenerate

data_to_axis_inf_A1 data_to_axis_inf_A1_inst(
/*  input                 */  .last_flag        (1'b1   ),
/*  data_inf_c.slaver     */  .data_slaver      (slaver_inf      ),
/*  axi_stream_inf.master */  .axis_master      (axis_slaver_inf )
);

// data_inf_c_interconnect_M2S #(
//     .NUM    (2      ),
//     .PRIO   ("ON"   )
// )data_inf_c_interconnect_M2S_inst(
// /*  data_inf_c.slaver */  .s00      (sub_master_inf ),//[NUM-1:0],
// /*  data_inf_c.master */  .m00      (slaver_inf     )
// );

data_c_pipe_intc_M2S_verc #(
    .PRIO       ("BEST_ROBIN"),   //BEST_ROBIN BEST_LAST ROBIN LAST WAIT_IDLE
    .NUM        (NUM      )
)data_inf_c_interconnect_M2S_inst_inst(
/*  input [NUM-1:0]    */    .last      ('1),             //ctrl prio
/*  data_inf_c.slaver  */    .s00       (sub_master_inf ),//[NUM-1:0],
/*  data_inf_c.master  */    .m00       (slaver_inf     )
);

initial begin
    fork
        gen_0_tk();
        gen_1_tk(10,40);
        gen_2_tk(20,10);
        gen_3_tk(30,80);
        gen_4_tk(40,50);
    join
end

task automatic gen_0_tk();
logic [7:0]     data[$];
    data = {>>{8'd1,8'd2,8'd3,8'd4,8'd5}};
    forever
        MasterBfm[0].gen_axi_stream(0,30,data);
endtask:gen_0_tk

task automatic gen_1_tk(logic[7:0]  a = 10,int rate = 30);
logic [7:0]     data[$];
    data = {>>{8'd1+a,8'd2+a,8'd3+a,8'd4+a,8'd5+a}};
    forever
        MasterBfm[1].gen_axi_stream(0,rate,data);
endtask:gen_1_tk

task automatic gen_2_tk(logic[7:0]  a = 10,int rate = 30);
logic [7:0]     data[$];
    data = {>>{8'd1+a,8'd2+a,8'd3+a,8'd4+a,8'd5+a}};
    forever
        MasterBfm[2].gen_axi_stream(0,rate,data);
endtask:gen_2_tk

task automatic gen_3_tk(logic[7:0]  a = 10,int rate = 30);
logic [7:0]     data[$];
    data = {>>{8'd1+a,8'd2+a,8'd3+a,8'd4+a,8'd5+a}};
    forever
        MasterBfm[3].gen_axi_stream(0,rate,data);
endtask:gen_3_tk

task automatic gen_4_tk(logic[7:0]  a = 10,int rate = 30);
logic [7:0]     data[$];
    data = {>>{8'd1+a,8'd2+a,8'd3+a,8'd4+a,8'd5+a}};
    forever
        MasterBfm[4].gen_axi_stream(0,rate,data);
endtask:gen_4_tk

generate
for(KK=0;KK<NUM;KK++)begin
always@(posedge pclk)begin
    if(sub_master_inf[KK].valid && sub_master_inf[KK].ready)
            mdata.put(sub_master_inf[KK].data);
end
end
endgenerate

logic [7:0]     slaver_data;
always@(posedge pclk)begin
    if(slaver_inf.valid && slaver_inf.ready)begin
        mdata.try_get(slaver_data);
        A1:assert(slaver_inf.data == slaver_data)
        else $error("SLAVE DATA EORROR %d %d",slaver_inf.data ,slaver_data);
    end
end

endmodule
