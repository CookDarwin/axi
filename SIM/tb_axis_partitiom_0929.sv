/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/9/29 
madified:
***********************************************/
`timescale 1ns/1ps
module tb_axis_partition_0929;
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


localparam DSIZE    = 8;

logic       valve;

axi_stream_inf #(DSIZE) axis_in (aclk,aresetn,1'b1);
axi_stream_inf #(DSIZE) axis_out (aclk,aresetn,1'b1);

AxiStreamMasterBfm_c #(DSIZE,"OFF") MasterBfm = new(axis_in);
AxiStreamSlaverBfm_c #(DSIZE) SlaverBfm = new(axis_out);

axi_stream_partition_A1 axi_stream_partition_A1_inst(
/*  input                 */     .valve             (valve          ),               // [1] open [0] close
/*  input [31:0]          */     .partition_len     (511            ),       //[0] mean 1 len
/*  axi_stream_inf.slaver */     .axis_in           (axis_in        ),
/*  axi_stream_inf.master */     .axis_out          (axis_out       )
);

initial begin
    forever
        SlaverBfm.get_data(50,0);
end

logic [DSIZE-1:0]     wdata_queue     [$];

initial begin
    wait(aresetn);
    wdata_queue = {1,2,3,4,5,6,7,8,9,10};
    forever begin
        MasterBfm.gen_axi_stream($urandom_range(1024,10),$urandom_range(100,30),wdata_queue);
    end
end

initial begin
    rand_valve(70);
end

task automatic rand_valve(int rate);
    valve   = 0;
    forever begin
        @(posedge aclk);
        if($urandom_range(99,0) < rate )
                valve   = 1;
        else    valve   = 0;
    end
endtask:rand_valve

//--- CHECK

mailbox mdata = new();
logic [DSIZE:0]     indata,outdata;

always@(negedge aclk)
    if(axis_in.axis_tvalid && axis_in.axis_tready)begin
        indata  = {axis_in.axis_tlast,axis_in.axis_tdata};
        mdata.put(indata);
    end

always@(negedge aclk)
    if(axis_out.axis_tvalid && axis_out.axis_tready)begin
        mdata.get(outdata);
        if(axis_out.axis_tcnt != 511)begin
            assert(outdata == {axis_out.axis_tlast,axis_out.axis_tdata})
            else begin
                $error("\nDATA ERROR EXPECT[%h] BUT[%h]\n",outdata,{axis_out.axis_tlast,axis_out.axis_tdata});
            end
        end else begin
            assert(axis_out.axis_tlast == 1)
            else begin
                $error("\nAXIS LAST should be hight\n");
            end
        end
    end

endmodule
