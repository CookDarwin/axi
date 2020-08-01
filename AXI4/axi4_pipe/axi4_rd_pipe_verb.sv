/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERB.0.0 2017/12/28 
    use data_c_pipe_force_vld
creaded: 2017/11/3 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_rd_pipe_verb(
    axi_inf.slaver_rd   slaver,
    axi_inf.master_rd   master
);

initial begin
    assert(slaver.IDSIZE == master.IDSIZE)
    else begin
        $error("\n AXI4 RD PIPE IDSIZE Dont eql S[%d] M[%d]\n",slaver.IDSIZE,master.IDSIZE);
        $finish;
    end

    assert(slaver.ASIZE == master.ASIZE)
    else begin
        $error("\n AXI4 RD PIPE ASIZE Dont eql S[%d] M[%d]\n",slaver.ASIZE,master.ASIZE);
        $finish;
    end

    assert(slaver.DSIZE == master.DSIZE)
    else begin
        $error("\n AXI4 RD PIPE DSIZE Dont eql S[%d] M[%d]\n",slaver.DSIZE,master.DSIZE);
        $finish;
    end

end

logic              clock;
logic              rst_n;

assign  clock   = slaver.axi_aclk;
assign  rst_n   = slaver.axi_aresetn;

logic [slaver.IDSIZE-1:0] rd_aux_rid_data;
logic [slaver.ASIZE-1:0]  rd_aux_raddr_data;
logic [slaver.LSIZE-1:0]  rd_aux_rlen_data;

data_inf_c #(slaver.IDSIZE+slaver.ASIZE+slaver.LSIZE)  ar_master_inf (clock,rst_n);
data_inf_c #(slaver.IDSIZE+slaver.ASIZE+slaver.LSIZE)  ar_slaver_inf (clock,rst_n);

assign ar_slaver_inf.valid  = slaver.axi_arvalid;
assign ar_slaver_inf.data   = {slaver.axi_arid,slaver.axi_araddr,slaver.axi_arlen};
assign slaver.axi_arready   = ar_slaver_inf.ready;

assign master.axi_arvalid   = ar_master_inf.valid;
assign {rd_aux_wid_data,rd_aux_waddr_data,rd_aux_wlen_data} = ar_master_inf.data;
assign ar_master_inf.ready  = master.axi_arready;

// data_connect_pipe #(
//     .DSIZE  (slaver.IDSIZE + slaver.ASIZE + slaver.LSIZE )
// )data_connect_pipe_aux(
// /*  input             */  .clock            (clock              ),
// /*  input             */  .rst_n            (rst_n              ),
// /*  input             */  .clk_en           (1'b1               ),
// /*  input             */  .from_up_vld      (slaver.axi_arvalid ),
// /*  input [DSIZE-1:0] */  .from_up_data     ({slaver.axi_arid,slaver.axi_araddr,slaver.axi_arlen}),
// /*  output            */  .to_up_ready      (slaver.axi_arready ),
// /*  input             */  .from_down_ready  (master.axi_arready ),
// /*  output            */  .to_down_vld      (master.axi_arvalid ),
// /*  output[DSIZE-1:0] */  .to_down_data     ({rd_aux_rid_data,rd_aux_raddr_data,rd_aux_rlen_data})
// );

data_c_pipe_force_vld data_c_pipe_force_vld_inst_ar(
/*  data_inf_c.slaver  */   .slaver     (ar_slaver_inf ),
/*  data_inf_c.master  */   .master     (ar_master_inf )
);

assign  master.axi_arid     = rd_aux_rid_data;
assign  master.axi_araddr   = rd_aux_raddr_data;
assign  master.axi_arlen    = rd_aux_rlen_data;

data_inf_c #(slaver.DSIZE+1+slaver.IDSIZE)  r_master_inf (clock,rst_n);
data_inf_c #(slaver.DSIZE+1+slaver.IDSIZE)  r_slaver_inf (clock,rst_n);

assign r_master_inf.valid   = master.axi_rvalid;
assign r_master_inf.data    = {master.axi_rdata,master.axi_rlast,master.axi_rid};
assign master.axi_rready    = r_master_inf.ready;

// data_connect_pipe #(
//     .DSIZE  (slaver.DSIZE + 1 + slaver.IDSIZE)
// )data_connect_pipe_data(
// /*  input             */  .clock            (clock              ),
// /*  input             */  .rst_n            (rst_n              ),
// /*  input             */  .clk_en           (1'b1               ),
// /*  input             */  .from_up_vld      (master.axi_rvalid ),
// /*  input [DSIZE-1:0] */  .from_up_data     ({master.axi_rdata,master.axi_rlast,master.axi_rid}),
// /*  output            */  .to_up_ready      (master.axi_rready ),
// /*  input             */  .from_down_ready  (slaver.axi_rready ),
// /*  output            */  .to_down_vld      (slaver.axi_rvalid ),
// /*  output[DSIZE-1:0] */  .to_down_data     ({slaver.axi_rdata,slaver.axi_rlast,slaver.axi_rid})
// );

data_c_pipe_force_vld data_c_pipe_force_vld_inst_r(
/*  data_inf_c.slaver  */   .slaver     (r_master_inf ),
/*  data_inf_c.master  */   .master     (r_slaver_inf )
);

assign slaver.axi_rvalid    = r_slaver_inf.valid;
assign {slaver.axi_rdata,slaver.axi_rlast,slaver.axi_rid} = r_slaver_inf.data;
assign r_slaver_inf.ready   = slaver.axi_rready;

endmodule
