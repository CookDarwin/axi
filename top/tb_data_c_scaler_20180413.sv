/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018-4-13 16:27:28
madified:
***********************************************/
`timescale 1ns/1ps
module tb_data_c_scaler_20180413;
import AxiBfmPkg::*;
logic   clock;
logic   rst_n;
localparam  DSIZE = 8;
localparam  MODE = "END";


clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(100     	)
)clock_rst_pixel(
	.clock			(clock   	),
	.rst_x			(rst_n  	)
);

axi_stream_inf #(DSIZE) axis_head_inf (clock,rst_n,1'b1);
axi_stream_inf #(DSIZE) axis_body_inf (clock,rst_n,1'b1);
axi_stream_inf #(DSIZE) axis_end_inf  (clock,rst_n,1'b1);
axi_stream_inf #(DSIZE) axis_m00_inf  (clock,rst_n,1'b1);

data_inf_c #(DSIZE+1) head_inf (clock,rst_n);
data_inf_c #(DSIZE+1) body_inf (clock,rst_n);
data_inf_c #(DSIZE+1) end_inf  (clock,rst_n);
data_inf_c #(DSIZE+1) m00_inf  (clock,rst_n);

AxiStreamMasterBfm_c #(DSIZE) head_bfm = new(axis_head_inf);
AxiStreamMasterBfm_c #(DSIZE) body_bfm = new(axis_body_inf);
AxiStreamMasterBfm_c #(DSIZE) end_bfm  = new(axis_end_inf);
AxiStreamSlaverBfm_c #(DSIZE) m00_bfm  = new(axis_m00_inf);

data_c_scaler #(
    .MODE       (MODE)
)data_c_scaler_inst(
/*  input               */    .head_last        (axis_head_inf.axis_tlast ),
/*  input               */    .body_last        (axis_body_inf.axis_tlast ),
/*  input               */    .end_last         (axis_end_inf.axis_tlast  ),
/*  data_inf_c.slaver   */    .head_inf         (head_inf   ),
/*  data_inf_c.slaver   */    .body_inf         (body_inf   ),
/*  data_inf_c.slaver   */    .end_inf          (end_inf    ),
/*  data_inf_c.master   */    .m00              (m00_inf    )
);

axis_to_data_inf #(
    .CONTAIN_LAST   ("ON")
)axis_to_data_inf_head_inst(
/*  axi_stream_inf.slaver */ .axis_in        (axis_head_inf  ),
/*  data_inf_c.master     */ .data_out_inf   (head_inf       )
);

axis_to_data_inf #(
    .CONTAIN_LAST   ("ON")
)axis_to_data_inf_body_inst(
/*  axi_stream_inf.slaver */ .axis_in        (axis_body_inf  ),
/*  data_inf_c.master     */ .data_out_inf   (body_inf       )
);

axis_to_data_inf #(
    .CONTAIN_LAST   ("ON")
)axis_to_data_inf_end_inst(
/*  axi_stream_inf.slaver */ .axis_in        (axis_end_inf  ),
/*  data_inf_c.master     */ .data_out_inf   (end_inf       )
);

data_to_axis_inf_A1 data_to_axis_inf_A1_inst(
/*  input                 */  .last_flag        (m00_inf.data[DSIZE]    ),
/*  data_inf_c.slaver     */  .data_slaver      (m00_inf                ),
/*  axi_stream_inf.master */  .axis_master      (axis_m00_inf           )
);

// assign axis_m00_inf.axis_tvalid = m00_inf.valid;
// assign axis_m00_inf.axis_tdata  = m00_inf.data[DSIZE-1:0];

//--->> TEST SET <<------------------------------------

initial begin
    wait(rst_n);
    repeat(100)
        fork
            heah_stream_tk($urandom_range(10,100),1+$urandom_range(0,4));
            body_stream_tk($urandom_range(10,100),1+$urandom_range(0,40));
             end_stream_tk($urandom_range(10,100),1+$urandom_range(0,10));
        join
end

initial begin
    repeat(10000)
        m00_get_tk($urandom_range(10,100));
end

task automatic heah_stream_tk(int send_rate,int len);
logic [7:0]     s00_data [$];
    // #(10us);
    if(MODE=="HEAD" || MODE=="BOTH")begin
        for(int CC=0;CC<len;CC++)
            s00_data[CC]    = CC%10;
        head_bfm.gen_axi_stream(0,send_rate,s00_data);
    end
endtask:heah_stream_tk

task automatic body_stream_tk(int send_rate,int len);
logic [7:0]     s00_data [$];
    // #(10us);
    for(int CC=0;CC<len;CC++)
        s00_data[CC]    = CC%10+8'h10;
    body_bfm.gen_axi_stream(0,send_rate,s00_data);
endtask:body_stream_tk

task automatic end_stream_tk(int send_rate,int len);
logic [7:0]     s00_data [$];
    // #(10us);
    if(MODE=="END" || MODE=="BOTH")begin
        for(int CC=0;CC<len;CC++)
            s00_data[CC]    = CC%10+8'h20;
        end_bfm.gen_axi_stream(0,send_rate,s00_data);
    end
endtask:end_stream_tk

task automatic m00_get_tk(int rate);
    m00_bfm.get_data(rate);
endtask:m00_get_tk
//---<< TEST SET >>------------------------------------
//--->> TRACK <<---------------------------------------
// mailbox         data_box [NUM-1:0];
typedef struct {
    logic [7:0]     data;
    logic           last;
} DataS;

mailbox   PreM   = new(100);
mailbox   PostM  = new(100);
mailbox   endS   = new(100);

DataS     Pre_s;
DataS     Post_s;
DataS     Cmp_s;

always@(negedge clock)begin
    if(axis_head_inf.axis_tvalid && axis_head_inf.axis_tready)begin
        Pre_s.data = axis_head_inf.axis_tdata;
        Pre_s.last = axis_head_inf.axis_tlast;
        PreM.put(Pre_s);
    end if(axis_body_inf.axis_tvalid && axis_body_inf.axis_tready)begin
        Pre_s.data = axis_body_inf.axis_tdata;
        Pre_s.last = axis_body_inf.axis_tlast;
        PreM.put(Pre_s);
    end if(axis_end_inf.axis_tvalid && axis_end_inf.axis_tready)begin
        Pre_s.data = axis_end_inf.axis_tdata;
        Pre_s.last = axis_end_inf.axis_tlast;
        PreM.put(Pre_s);
    end
end


always@(negedge clock)begin
    if(axis_m00_inf.axis_tvalid && axis_m00_inf.axis_tready)begin
        Post_s.data = axis_m00_inf.axis_tdata;
        Post_s.last = axis_m00_inf.axis_tlast;

        PreM.try_get(Cmp_s);

        if((Cmp_s.data != Post_s.data) || (Cmp_s.last != Post_s.last))begin
            $error("\n## ERROR IN STREAM ##\n");
            repeat(3)
                @(posedge clock);
            $stop;
        end

    end
end



endmodule
