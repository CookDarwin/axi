/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/4/5 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_wr_pipe(
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

// logic [slaver.IDSIZE-1:0] wr_aux_wid_data;
// logic [slaver.ASIZE-1:0]  wr_aux_waddr_data;
// logic [slaver.LSIZE-1:0]  wr_aux_wlen_data;

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

data_inf_c #(.DSIZE(slaver.IDSIZE + slaver.ASIZE + slaver.LSIZE),.FreqM(slaver.FreqM)) slaver_aux (.clock(clock),.rst_n(rst_n));
data_inf_c #(.DSIZE(slaver.IDSIZE + slaver.ASIZE + slaver.LSIZE),.FreqM(slaver.FreqM)) master_aux (.clock(clock),.rst_n(rst_n));

assign  slaver_aux.data     = {slaver.axi_awid,slaver.axi_awaddr,slaver.axi_awlen};
assign  slaver_aux.valid    = slaver.axi_awvalid;
assign  slaver.axi_awready  = slaver_aux.ready;

assign  {master.axi_awid,master.axi_awaddr,master.axi_awlen}    = master_aux.data;
assign  master.axi_awvalid  = master_aux.valid;
assign  master_aux.ready    = master.axi_awready;

data_c_pipe_inf data_c_pipe_inf_aux_inst(
/*  data_inf_c.slaver  */ .slaver       (slaver_aux     ),
/*  data_inf_c.master  */ .master       (master_aux     )
);

// assign  master.axi_awid     = wr_aux_wid_data;
// assign  master.axi_awaddr   = wr_aux_waddr_data;
// assign  master.axi_awlen    = wr_aux_wlen_data;

data_inf_c #(.DSIZE(slaver.DSIZE + 1),.FreqM(slaver.FreqM)) slaver_data (.clock(clock),.rst_n(rst_n));
data_inf_c #(.DSIZE(slaver.DSIZE + 1),.FreqM(slaver.FreqM)) master_data (.clock(clock),.rst_n(rst_n));

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

assign  slaver_data.data    = {slaver.axi_wdata,slaver.axi_wlast};
assign  slaver_data.valid   = slaver.axi_wvalid;
assign  slaver.axi_wready   = slaver_data.ready;

data_c_pipe_inf data_c_pipe_inf_data_inst(
/*  data_inf_c.slaver  */ .slaver       (slaver_data    ),
/*  data_inf_c.master  */ .master       (master_data    )
);

assign  {master.axi_wdata,master.axi_wlast} = master_data.data;
assign  master.axi_wvalid   = master_data.valid;
assign  master_data.ready   = master.axi_wready;

data_inf_c #(.DSIZE(slaver.IDSIZE + 2),.FreqM(slaver.FreqM)) slaver_bresp (.clock(clock),.rst_n(rst_n));
data_inf_c #(.DSIZE(slaver.IDSIZE + 2),.FreqM(slaver.FreqM)) master_bresp (.clock(clock),.rst_n(rst_n));

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

assign slaver_bresp.data    = {master.axi_bresp,master.axi_bid};
assign slaver_bresp.valid   = master.axi_bvalid;
assign master.axi_bready    = slaver_bresp.ready;

data_c_pipe_inf data_c_pipe_inf_bresp_inst(
/*  data_inf_c.slaver  */ .slaver       (slaver_bresp   ),
/*  data_inf_c.master  */ .master       (master_bresp   )
);

assign slaver.axi_bvalid    = master_bresp.valid;
assign {slaver.axi_bresp,slaver.axi_bid} = master_bresp.data;
assign master_bresp.ready   = slaver.axi_bready;

endmodule
