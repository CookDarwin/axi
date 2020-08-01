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
class MailBox #(
    parameter DSIZE = 8
);

mailbox  master_box;
mailbox  slaver_box;

logic[DSIZE:0]  mdata;
logic[DSIZE:0]  sdata;
int             cnt;
// virtual logic   clock;

function new(int num = 0);
    // clock = clk;
    cnt = 0;
    master_box = new(num);
    slaver_box = new(num);
endfunction

task automatic master_put(logic [DSIZE-1:0]    data);
    master_box.put(data);
endtask:master_put

task automatic slaver_put(logic [DSIZE-1:0]    data);
    slaver_box.put(data);
endtask:slaver_put

task automatic master_get(ref logic[DSIZE-1:0]  data);
    master_box.get(data);
endtask:master_get

task automatic slaver_get(ref logic[DSIZE-1:0]  data);
    slaver_box.get(data);
endtask:slaver_get

task automatic incr();
    cnt = cnt + 1;
endtask:incr


endclass:MailBox

module tb_axis_m2s_A1_0115;
import AxiBfmPkg::*;
logic   pclk;
logic   prst_n;

localparam NUM = 8;

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(50			),
	.FreqM			(148.5     	)
)clock_rst_pixel(
	.clock			(pclk   	),
	.rst_x			(prst_n  	)
);

// axi_stream_inf #(8) axis_slaver_inf_tmp[3:0][3:0] (pclk,prst_n,1'b1);
axi_stream_inf #(8) axis_sub_master_inf[1:0][NUM-1:0] (pclk,prst_n,1'b1);
axi_stream_inf #(8) axis_slaver_inf (pclk,prst_n,1'b1);

AxiStreamMasterBfm_c #(8,"OFF") MasterBfm[NUM-1:0];
AxiStreamSlaverBfm_c #(8) SlaverBfm = new(axis_slaver_inf);

MailBox #(4)    mbox [NUM-1:0];
logic [3:0]     mdata [NUM-1:0];
logic [3:0]     sdata [NUM-1:0];

initial begin
    forever begin
        SlaverBfm.get_data(100,0);
    end
end

genvar KK;

generate
for(KK=0;KK<NUM;KK++)begin
    initial begin
        mbox[KK]        = new();
        MasterBfm[KK]   = new(axis_sub_master_inf[0][KK]);
    end
end
endgenerate

axi_stream_interconnect_M2S_A1 #(
    .NUM        (NUM)
)master_1_axis_M2S_noaddr_inst(
/*  axi_stream_inf.slaver */ .s00      (axis_sub_master_inf[0]     ), //[NUM-1:0],
/*  axi_stream_inf.master */ .m00      (axis_slaver_inf         ) //
);



task automatic gen_m_tk(AxiStreamMasterBfm_c bfm,logic[7:0]  a = 10,int rate = 30);
logic [7:0]     data[$];
    data = {>>{8'd1+a,8'd2+a,8'd3+a,8'd4+a,8'd5+a}};
    forever
        bfm.gen_axi_stream(0,rate,data);
endtask:gen_m_tk

// task automatic push_mail_box(input logic[3:0]  data,ref mailbox mb);
//     mb.put(data);
// endtask:push_mail_box
//
// task automatic get_mail_box(ref mailbox mb,ref logic[3:0] data);
//     mb.get(data);
// endtask:get_mail_box

generate
for(KK=0;KK<NUM;KK++)begin
    initial begin
        if(KK%2 == 0)
            gen_m_tk(MasterBfm[KK],KK*16,$urandom_range(80,10));
        // gen_m_tk(MasterBfm[KK],KK*16,100);
    end

    always@(posedge pclk)begin
        if(axis_sub_master_inf[0][KK].axis_tvalid && axis_sub_master_inf[0][KK].axis_tready)begin
            mbox[KK].master_put(axis_sub_master_inf[0][KK].axis_tdata[3:0]);
        end
    end

    always@(posedge pclk)begin
        if(axis_slaver_inf.axis_tvalid && axis_slaver_inf.axis_tready)begin
            if(axis_slaver_inf.axis_tdata[7:4] == KK)begin
                mbox[KK].slaver_put(axis_slaver_inf.axis_tdata[3:0]);
            end
        end
    end

    always@(*)begin
        mbox[KK].master_get(mdata[KK]);
        mbox[KK].slaver_get(sdata[KK]);
        assert(mdata[KK] == sdata[KK])
        else begin
            $display(" :%d: [%d] MDATA[%h] != SDATA[%h]",KK,mbox[KK].cnt,mdata[KK],sdata[KK]);
        end
        mbox[KK].incr();
    end
end
endgenerate


endmodule
