/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/10/23 
madified:
***********************************************/
`timescale 1ns/1ps
module tb_axis_s2m_pipe_1023;
import AxiBfmPkg::*;

logic   aclk;
logic   aresetn;


clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(140     	)
)clock_rst_master(
	.clock			(aclk	    ),
	.rst_x			(aresetn 	)
);

logic [1:0]     addr;
logic           addr_vld;

localparam DSIZE    = 8;

axi_stream_inf #(DSIZE) axis_in (aclk,aresetn,1'b1);
axi_stream_inf #(DSIZE) axis_out [2:0] (aclk,aresetn,1'b1);

AxiStreamMasterBfm_c #(DSIZE,"OFF") MasterBfm = new(axis_in);
AxiStreamSlaverBfm_c #(DSIZE) SlaverBfm[2:0];

initial begin
    SlaverBfm[0]    = new(axis_out[0]);
    SlaverBfm[1]    = new(axis_out[1]);
    SlaverBfm[2]    = new(axis_out[2]);
end

axis_interconnect_S2M_pipe #(
    .NUM    (3)
)axi_stream_interconnect_S2M_inst(
/*  input                 */    .addr_vld   (addr_vld   ),
/*  output                */    .addr_rdy   (),
/*  input [NSIZE-1:0]     */    .addr       (addr       ),
/*  axi_stream_inf.slaver */    .s00        (axis_in    ),
/*  axi_stream_inf.master */    .m00        (axis_out   )//[NUM-1:0]
);

//mialbox list

mailbox mb_master_addr = new(100);
mailbox mb_master_len = new(100);
mailbox mb_master_rate = new(100);

mailbox mb_slaver_rate_0 = new(100);
mailbox mb_slaver_rate_1 = new(100);
mailbox mb_slaver_rate_2 = new(100);

initial begin:MB_INIT
int         index;
logic[1:0]  master_addr;
int         master_len;
int         master_rate;
int         slaver_rate [2:0];
    index = 0;
    repeat(1000)begin
        master_addr = $urandom_range(3,0);
        // master_len  = 2*($urandom_range(0,5));
        master_len  = 1;
        master_rate = $urandom_range(4,1)*25;
        slaver_rate[0] = $urandom_range(4,1)*25;
        slaver_rate[1] = $urandom_range(4,1)*25;
        slaver_rate[2] = $urandom_range(4,1)*25;

        mb_master_addr.put(master_addr);
        mb_master_len.put(master_len);
        mb_master_rate.put(master_rate);

        mb_slaver_rate_0.put(slaver_rate[0]);
        mb_slaver_rate_1.put(slaver_rate[1]);
        mb_slaver_rate_2.put(slaver_rate[2]);
        @(posedge aclk);
        index++;
        // $display("---PUSH[%d] DONE!----",index);
    end
end

//-----
int track_cnt = 0;

task automatic master_tk;
logic[7:0]  data [$];
int     length;
int     rate;
    wait(axis_in.aresetn);
    repeat(100)  @(posedge axis_in.aclk);
    data   = {>>{8'd1,8'd2,8'd3,8'd4}};
    repeat(1000) begin
        mb_master_len.get(length);
        mb_master_rate.get(rate);
        data   = {>>{track_cnt[7:0],8'd1,8'd2,8'd3,8'd4}};
        MasterBfm.gen_axi_stream(length,rate,data);
        track_cnt++;
        $display("[%d]   LEN[%d],    RATE[%d/100],    DONE !!",track_cnt,length,rate);
    end
    $display(" GEN DONE !!!");
endtask:master_tk

task automatic slaver_tk;
int     slaver_rate [2:0];
    wait(axis_in.aresetn);
    repeat(100)  @(posedge axis_in.aclk);
    fork
        repeat(100) begin
            mb_slaver_rate_0.get(slaver_rate[0]);
            SlaverBfm[0].get_data(slaver_rate[0],0);
        end
        repeat(100) begin
            mb_slaver_rate_1.get(slaver_rate[1]);
            SlaverBfm[1].get_data(slaver_rate[1],0);
        end
        repeat(100) begin
            mb_slaver_rate_2.get(slaver_rate[2]);
            SlaverBfm[2].get_data(slaver_rate[2],0);
        end
    join
endtask:slaver_tk




// initial begin
//     mb_master_addr.get(addr);
// end

always@(posedge aclk)
    if(axis_in.axis_tvalid && axis_in.axis_tready && axis_in.axis_tlast)begin
        addr_vld    <= 1'b1;
    end else begin
        addr_vld    <= 1'b0;
    end

always@(posedge aclk)
    if(axis_in.axis_tvalid && axis_in.axis_tready && axis_in.axis_tcnt == 0)begin
        mb_master_addr.get(addr);
    end

initial begin
    master_tk();
end

initial begin
    slaver_tk();
end

endmodule
