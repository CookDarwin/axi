/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERB.0.0 2017/12/28 
    use data_c_pipe_force_vld
creaded: 2017/4/5 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_wr_pipe_verb(
    axi_inf.slaver_wr   slaver,
    axi_inf.master_wr   master
);

initial begin
    assert(slaver.IDSIZE == master.IDSIZE)
    else begin
        $error("\n AXI4 WR PIPE IDSIZE Dont eql S[%d] M[%d]\n",slaver.IDSIZE,master.IDSIZE);
        $finish;
    end

    assert(slaver.ASIZE == master.ASIZE)
    else begin
        $error("\n AXI4 WR PIPE ASIZE Dont eql S[%d] M[%d]\n",slaver.ASIZE,master.ASIZE);
        $finish;
    end

    assert(slaver.DSIZE == master.DSIZE)
    else begin
        $error("\n AXI4 WR PIPE DSIZE Dont eql S[%d] M[%d]\n",slaver.DSIZE,master.DSIZE);
        $finish;
    end

end

logic              clock;
logic              rst_n;

assign  clock   = slaver.axi_aclk;
assign  rst_n   = slaver.axi_aresetn;

logic [slaver.IDSIZE-1:0] wr_aux_wid_data;
logic [slaver.ASIZE-1:0]  wr_aux_waddr_data;
logic [slaver.LSIZE-1:0]  wr_aux_wlen_data;

data_inf_c #(slaver.IDSIZE+slaver.ASIZE+slaver.LSIZE)  aw_master_inf (clock,rst_n);
data_inf_c #(slaver.IDSIZE+slaver.ASIZE+slaver.LSIZE)  aw_slaver_inf (clock,rst_n);

assign aw_slaver_inf.valid  = slaver.axi_awvalid;
assign aw_slaver_inf.data   = {slaver.axi_awid,slaver.axi_awaddr,slaver.axi_awlen};
assign slaver.axi_awready   = aw_slaver_inf.ready;

assign master.axi_awvalid   = aw_master_inf.valid;
assign {wr_aux_wid_data,wr_aux_waddr_data,wr_aux_wlen_data} = aw_master_inf.data;
assign aw_master_inf.ready  = master.axi_awready;

// data_connect_pipe #(
//     .DSIZE  (slaver.IDSIZE + slaver.ASIZE + slaver.LSIZE )
// )data_connect_pipe_aux(
// /*  input             */  .clock            (clock              ),
// /*  input             */  .rst_n            (rst_n              ),
// /*  input             */  .clk_en           (1'b1               ),
// /*  input             */  .from_up_vld      (slaver.axi_awvalid ),
// /*  input [DSIZE-1:0] */  .from_up_data     ({slaver.axi_awid,slaver.axi_awaddr,slaver.axi_awlen}),
// /*  output            */  .to_up_ready      (slaver.axi_awready ),
// /*  input             */  .from_down_ready  (master.axi_awready ),
// /*  output            */  .to_down_vld      (master.axi_awvalid ),
// /*  output[DSIZE-1:0] */  .to_down_data     ({wr_aux_wid_data,wr_aux_waddr_data,wr_aux_wlen_data})
// );

data_c_pipe_force_vld data_c_pipe_force_vld_inst_aw(
/*  data_inf_c.slaver  */   .slaver     (aw_slaver_inf ),
/*  data_inf_c.master  */   .master     (aw_master_inf )
);

assign  master.axi_awid     = wr_aux_wid_data;
assign  master.axi_awaddr   = wr_aux_waddr_data;
assign  master.axi_awlen    = wr_aux_wlen_data;


data_inf_c #(slaver.DSIZE+1)  w_master_inf (clock,rst_n);
data_inf_c #(slaver.DSIZE+1)  w_slaver_inf (clock,rst_n);

assign w_slaver_inf.valid   = slaver.axi_wvalid;
assign w_slaver_inf.data    = {slaver.axi_wdata,slaver.axi_wlast};
assign slaver.axi_wready    = w_slaver_inf.ready;


// data_connect_pipe #(
//     .DSIZE  (slaver.DSIZE + 1 )
// )data_connect_pipe_data(
// /*  input             */  .clock            (clock              ),
// /*  input             */  .rst_n            (rst_n              ),
// /*  input             */  .clk_en           (1'b1               ),
// /*  input             */  .from_up_vld      (slaver.axi_wvalid ),
// /*  input [DSIZE-1:0] */  .from_up_data     ({slaver.axi_wdata,slaver.axi_wlast}),
// /*  output            */  .to_up_ready      (slaver.axi_wready ),
// /*  input             */  .from_down_ready  (master.axi_wready ),
// /*  output            */  .to_down_vld      (master.axi_wvalid ),
// /*  output[DSIZE-1:0] */  .to_down_data     ({master.axi_wdata,master.axi_wlast})
// );

data_c_pipe_force_vld data_c_pipe_force_vld_inst_w(
/*  data_inf_c.slaver  */   .slaver     (w_slaver_inf ),
/*  data_inf_c.master  */   .master     (w_master_inf )
);

assign master.axi_wvalid    = w_master_inf.valid;
assign {master.axi_wdata,master.axi_wlast} = w_master_inf.data;
assign w_master_inf.ready   = master.axi_wready;

data_inf_c #(2+slaver.IDSIZE)  b_master_inf (clock,rst_n);
data_inf_c #(2+slaver.IDSIZE)  b_slaver_inf (clock,rst_n);

assign b_master_inf.valid   = master.axi_bvalid;
assign b_master_inf.data    = {master.axi_bresp,master.axi_bid};
assign master.axi_bready    = b_master_inf.ready;


// data_connect_pipe #(
//     .DSIZE  (2+slaver.IDSIZE )
// )data_connect_pipe_bresp(
// /*  input             */  .clock            (clock              ),
// /*  input             */  .rst_n            (rst_n              ),
// /*  input             */  .clk_en           (1'b1               ),
// /*  input             */  .from_up_vld      (master.axi_bvalid ),
// /*  input [DSIZE-1:0] */  .from_up_data     ({master.axi_bresp,master.axi_bid}  ),
// /*  output            */  .to_up_ready      (master.axi_bready ),
// /*  input             */  .from_down_ready  (slaver.axi_bready ),
// /*  output            */  .to_down_vld      (slaver.axi_bvalid ),
// /*  output[DSIZE-1:0] */  .to_down_data     ({slaver.axi_bresp,slaver.axi_bid}  )
// );

data_c_pipe_force_vld data_c_pipe_force_vld_inst_b(
/*  data_inf_c.slaver  */   .slaver     (b_master_inf ),
/*  data_inf_c.master  */   .master     (b_slaver_inf )
);

assign slaver.axi_bvalid    = b_slaver_inf.valid;
assign {slaver.axi_bresp,slaver.axi_bid} = b_slaver_inf.data;
assign b_slaver_inf.ready   = slaver.axi_bready;

endmodule
