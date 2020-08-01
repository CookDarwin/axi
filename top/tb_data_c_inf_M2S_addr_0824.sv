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
module tb_data_c_inf_M2S_addr_0824;
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
data_inf_c #(3)  addr_inf          (pclk,prst_n);

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

// data_c_pipe_intc_M2S_verc #(
//     .PRIO       ("BEST_ROBIN"),   //BEST_ROBIN BEST_LAST ROBIN LAST WAIT_IDLE
//     .NUM        (NUM      )
// )data_inf_c_interconnect_M2S_inst_inst(
// /*  input [NUM-1:0]    */    .last      ('1),             //ctrl prio
// /*  data_inf_c.slaver  */    .s00       (sub_master_inf ),//[NUM-1:0],
// /*  data_inf_c.master  */    .m00       (slaver_inf     )
// );

data_c_pipe_intc_M2S_verc_with_addr #(
    .NUM        (NUM)
)data_c_pipe_intc_M2S_verc_with_addr_inst(
/*  input [NUM-1:0]     */        .last         ('1),
/*  data_inf_c.slaver   */        .addr_inf     (addr_inf       ),
/*  data_inf_c.slaver   */        .s00          (sub_master_inf ),// [NUM-1:0],
/*  data_inf_c.master   */        .m00          (slaver_inf     )
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

class RandData;

rand logic[2:0] data;

constraint data_w {
    data dist{0:=10,[1:3]:=70,4:=30};
}

endclass:RandData

RandData Rd;
initial begin
    Rd = new();
    // Rd.randomize();
end

always@(posedge pclk,negedge prst_n)begin
// int     rm;
    if(~prst_n)  addr_inf.valid  <= 1'b0;
    else begin
        addr_inf.valid <= $urandom_range(0,99) > 50;
    end
end

always@(posedge pclk,negedge prst_n)begin
    if(~prst_n)  addr_inf.data  <= '0;
    else begin
        if(addr_inf.valid && addr_inf.ready)begin
            Rd.randomize();
            addr_inf.data   <= Rd.data;
        end
    end
end

//--->> DIRECT CHECK <<---------------------
mailbox addr_box = new();
mailbox master_box [NUM-1:0];
mailbox slaver_box = new();
mailbox chk_slaver_box = new();

generate
for(KK=0;KK<NUM;KK++)begin
    initial begin
        master_box[KK] = new();
    end

    always@(posedge pclk)begin
        if(sub_master_inf[KK].valid && sub_master_inf[KK].ready)begin
            master_box[KK].put(sub_master_inf[KK].data);
        end
    end
end
endgenerate

always@(posedge pclk)begin
    if(addr_inf.valid && addr_inf.ready)begin
        addr_box.put(addr_inf.data);
    end
end

always@(posedge pclk)begin
    if(slaver_inf.valid && slaver_inf.ready)begin
        slaver_box.put(slaver_inf.data);
    end
end

always@(posedge pclk)begin
logic [7:0] addr;
logic [7:0] data;
    addr_box.get(addr);

    case(addr)
    0:  master_box[0].get(data);
    1:  master_box[1].get(data);
    2:  master_box[2].get(data);
    3:  master_box[3].get(data);
    4:  master_box[4].get(data);
    default:
        $error("ADDR ERROE [ADDR = %h]",addr);
    endcase

    chk_slaver_box.put(data);
end



endmodule
