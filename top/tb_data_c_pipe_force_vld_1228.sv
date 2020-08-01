/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/12/28 
madified:
***********************************************/
`timescale 1ns/1ps
import AxiBfmPkg::*;
module tb_data_c_pipe_force_vld_1228;

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

data_inf_c #(8)  master_inf (pclk,prst_n);
data_inf_c #(8)  slaver_inf (pclk,prst_n);
axi_stream_inf #(8) axis_master_inf (pclk,prst_n,1'b1);
axi_stream_inf #(8) axis_slaver_inf (pclk,prst_n,1'b1);

AxiStreamMasterBfm_c #(8,"OFF") MasterBfm = new(axis_master_inf);

AxiStreamSlaverBfm_c #(8) SlaverBfm = new(axis_slaver_inf);

logic [axis_master_inf.DSIZE-1:0] ds_data [$];

initial begin
    wait(axis_master_inf.aresetn);
    repeat(30)
        @(posedge axis_master_inf.aclk);
    repeat(20)begin
        repeat($urandom_range(100,0))begin
            ds_data = {ds_data,$urandom_range(100,0)};
        end
        MasterBfm.gen_axi_stream(ds_data.size(),$urandom_range(100,0),ds_data);
    end
end

initial begin
    forever begin
        SlaverBfm.get_data(50,0);
    end
end

axis_to_data_inf axis_to_data_inf_inst(
/*  axi_stream_inf.slaver*/  .axis_in           (axis_master_inf   ),
/*  data_inf_c.master    */  .data_out_inf      (master_inf        )
);

data_c_pipe_force_vld data_c_pipe_force_vld_inst(
/*  data_inf_c.slaver  */   .slaver     (master_inf ),
/*  data_inf_c.master  */   .master     (slaver_inf )
);

data_to_axis_inf_A1 data_to_axis_inf_A1_inst(
/*  input                 */  .last_flag        (1'b0            ),
/*  data_inf_c.slaver     */  .data_slaver      (slaver_inf      ),
/*  axi_stream_inf.master */  .axis_master      (axis_slaver_inf )
);

//--->> TEST <<----------------
mailbox  mdata = new();
always@(negedge pclk)begin
int data;
    if(axis_master_inf.axis_tvalid && axis_master_inf.axis_tready)begin
        data = axis_master_inf.axis_tdata;
        mdata.put(data);
        // $display("====%h=====",data);
    end
end

always@(negedge pclk)begin
int data;
    if(axis_slaver_inf.axis_tvalid && axis_slaver_inf.axis_tready)begin
        mdata.get(data);
        assert(axis_slaver_inf.axis_tdata == data )
        else $error("OUT SLAVER DATA ERROR Origin %h != Out %h",axis_slaver_inf.axis_tdata ,data);
    end
end
//---<< TEST >>----------------


endmodule
