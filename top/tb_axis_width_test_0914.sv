/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/9/13 
madified:
***********************************************/
`timescale 1ns/1ps
module tb_axis_width_test_0914;
import AxiBfmPkg::*;
logic   pclk;
logic   prst_n;


clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(10			),
	.FreqM			(148.5     	)
)clock_rst_pixel(
	.clock			(pclk   	),
	.rst_x			(prst_n  	)
);

localparam  DSIZE = 8,
            NDSIZE = DSIZE * 3;

axi_stream_inf #(DSIZE) slim_inf (pclk,prst_n,1'b1);
axi_stream_inf #(NDSIZE) wide_inf (pclk,prst_n,1'b1);
axi_stream_inf #(NDSIZE) q_wide_inf (pclk,prst_n,1'b1);
axi_stream_inf #(DSIZE) out_slim_inf (pclk,prst_n,1'b1);
axi_stream_inf #(DSIZE) pre_out_slim_inf (pclk,prst_n,1'b1);


AxiStreamMasterBfm_c #(DSIZE,"OFF") MasterBfm = new(slim_inf);
AxiStreamSlaverBfm_c #(DSIZE)       SlaverBfm = new(out_slim_inf);

axis_width_combin axis_width_combin_inst(
/*  axi_stream_inf.slaver  */ .slim_axis        (slim_inf   ),
/*  axi_stream_inf.master  */ .wide_axis        (wide_inf   )
);

axis_pkt_fifo_filter_keep #(
    .DEPTH  (4  )   //2-4
)axi_stream_packet_fifo_inst(
/*  axi_stream_inf.slaver */     .axis_in       (wide_inf   ),
/*  axi_stream_inf.master */     .axis_out      (q_wide_inf )
);

axis_width_destruct axis_width_destruct_inst(
/*  axi_stream_inf.slaver */  .wide_axis        (q_wide_inf     ),
/*  axi_stream_inf.master */  .slim_axis        (pre_out_slim_inf   )
);

axis_pkt_fifo_filter_keep #(
    .DEPTH  (4  )   //2-4
)slim_fifo_inst(
/*  axi_stream_inf.slaver */     .axis_in       (pre_out_slim_inf   ),
/*  axi_stream_inf.master */     .axis_out      (out_slim_inf       )
);

initial begin
    forever begin
        SlaverBfm.get_data(100,0);
        SlaverBfm.get_data(80,0);
        SlaverBfm.get_data(60,0);
        SlaverBfm.get_data(40,0);
        SlaverBfm.get_data(20,0);
        SlaverBfm.get_data(10,0);
    end
end

logic [DSIZE-1:0]   data [$];

initial begin
    #(1us);
    @(posedge pclk);
    data   = {>>{8'd1,8'd2,8'd3,8'd4}};
    forever begin
        data   = {>>{8'd1,8'd2,8'd3,8'd4}};
        MasterBfm.gen_axi_stream(10,100,data);
        data = {>>{8'd11,8'd21,8'd31,8'd41,8'd9}};
        MasterBfm.gen_axi_stream(20,60,data);
        data = {>>{8'd1,8'd2,8'd3,8'd4,8'd91}};
        MasterBfm.gen_axi_stream(30,30,data);
        data = {>>{8'd111,8'd121,8'd131,8'd141,8'd19}};
        MasterBfm.gen_axi_stream(40,15,data);
    end
end


//--->> TEST <<----------------
mailbox  mdata = new();
always@(negedge pclk)begin
int data;
    if(slim_inf.axis_tvalid && slim_inf.axis_tready)begin
        data = {slim_inf.axis_tlast,slim_inf.axis_tkeep,slim_inf.axis_tdata};
        mdata.put(data);
        // $display("====%h=====",data);
    end
end

always@(negedge pclk)begin
int data;
    if(out_slim_inf.axis_tvalid && out_slim_inf.axis_tready)begin
        mdata.get(data);
        assert({out_slim_inf.axis_tlast,out_slim_inf.axis_tkeep,out_slim_inf.axis_tdata} == data )
        else $error("OUT SLIM DATA ERROR Origin %h != Out %h",{out_slim_inf.axis_tlast,out_slim_inf.axis_tkeep,out_slim_inf.axis_tdata},data);
    end
end
//---<< TEST >>----------------
endmodule
