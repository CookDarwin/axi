/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
created: xxxx.xx.xx
madified:
***********************************************/
`timescale 1ns/1ps

module axi4_dpram_cache #(
    parameter  INIT_FILE = ""
)(
    axi_inf.slaver   a_inf,
    axi_inf.slaver   b_inf
);

//==========================================================================
//-------- define ----------------------------------------------------------

cm_ram_inf #(.DSIZE(a_inf.DSIZE),.RSIZE(a_inf.ASIZE),.MSIZE( a_inf.DSIZE/8)) xram_inf();
axi_stream_inf #(.DSIZE(a_inf.ASIZE+a_inf.DSIZE+1),.USIZE(1)) a_axis_inf (.aclk(a_inf.axi_aclk),.aresetn(a_inf.axi_aresetn),.aclken(1'b1)) ;
axi_stream_inf #(.DSIZE(a_inf.DSIZE),.USIZE(1)) a_axis_rd_inf (.aclk(a_inf.axi_aclk),.aresetn(a_inf.axi_aresetn),.aclken(1'b1)) ;
data_inf_c #(.DSIZE(a_inf.ASIZE+1)) a_datac_rd_inf (.clock(a_inf.axi_aclk),.rst_n(a_inf.axi_aresetn)) ;
data_inf_c #(.DSIZE(a_inf.ASIZE+a_inf.DSIZE+1)) a_datac_rd_rel_inf (.clock(a_inf.axi_aclk),.rst_n(a_inf.axi_aresetn)) ;
axi_stream_inf #(.DSIZE(b_inf.ASIZE+b_inf.DSIZE+1),.USIZE(1)) b_axis_inf (.aclk(b_inf.axi_aclk),.aresetn(b_inf.axi_aresetn),.aclken(1'b1)) ;
axi_stream_inf #(.DSIZE(b_inf.DSIZE),.USIZE(1)) b_axis_rd_inf (.aclk(b_inf.axi_aclk),.aresetn(b_inf.axi_aresetn),.aclken(1'b1)) ;
data_inf_c #(.DSIZE(b_inf.ASIZE+1)) b_datac_rd_inf (.clock(b_inf.axi_aclk),.rst_n(b_inf.axi_aresetn)) ;
data_inf_c #(.DSIZE(b_inf.ASIZE+b_inf.DSIZE+1)) b_datac_rd_rel_inf (.clock(b_inf.axi_aclk),.rst_n(b_inf.axi_aresetn)) ;
//==========================================================================
//-------- instance --------------------------------------------------------
full_axi4_to_axis full_axi4_to_axis_ainst(
/* axi_stream_inf.master */.axis_inf    (a_axis_inf    ),
/* axi_stream_inf.slaver */.axis_rd_inf (a_axis_rd_inf ),
/* axi_inf.slaver        */.xaxi4_inf   (a_inf         )
);
data_inf_c_planer_A1 #(
    .LAT   (3           ),
    .DSIZE (a_inf.DSIZE ),
    .HEAD  ("OFF"       )
)data_inf_c_planer_A1_ainst(
/* input             */.reset     (~a_inf.axi_aresetn ),
/* input             */.pack_data (xram_inf.doa       ),
/* data_inf_c.slaver */.slaver    (a_datac_rd_inf     ),
/* data_inf_c.master */.master    (a_datac_rd_rel_inf )
);
full_axi4_to_axis full_axi4_to_axis_binst(
/* axi_stream_inf.master */.axis_inf    (b_axis_inf    ),
/* axi_stream_inf.slaver */.axis_rd_inf (b_axis_rd_inf ),
/* axi_inf.slaver        */.xaxi4_inf   (b_inf         )
);
data_inf_c_planer_A1 #(
    .LAT   (3           ),
    .DSIZE (b_inf.DSIZE ),
    .HEAD  ("OFF"       )
)data_inf_c_planer_A1_binst(
/* input             */.reset     (~b_inf.axi_aresetn ),
/* input             */.pack_data (xram_inf.dob       ),
/* data_inf_c.slaver */.slaver    (b_datac_rd_inf     ),
/* data_inf_c.master */.master    (b_datac_rd_rel_inf )
);
common_ram_wrapper #(
    .INIT_FILE (INIT_FILE )
)common_ram_wrapper_inst(
/* cm_ram_inf.slaver */.ram_inf (xram_inf )
);
//==========================================================================
//-------- expression ------------------------------------------------------
initial begin
    assert( a_inf.ASIZE==b_inf.ASIZE)else begin
         $error("a_inf.ASIZE != b_inf.ASIZE");
         $stop;
    end
    assert( a_inf.DSIZE==b_inf.DSIZE)else begin
         $error("a_inf.ASIZE != b_inf.ASIZE");
         $stop;
    end
end

assign  a_axis_inf.axis_tready = a_axis_inf.axis_tdata[ a_inf.ASIZE+a_inf.DSIZE+1-1] || (a_datac_rd_inf.ready && !a_axis_inf.axis_tdata[ a_inf.ASIZE+a_inf.DSIZE+1-1]);
assign  a_datac_rd_inf.data = {a_axis_inf.axis_tlast,a_axis_inf.axis_tdata[ a_inf.ASIZE+a_inf.DSIZE+1-1- 1: a_inf.ASIZE+a_inf.DSIZE+1-a_inf.ASIZE- 1]};
assign  a_datac_rd_inf.valid = a_axis_inf.axis_tvalid && !a_axis_inf.axis_tdata[ a_inf.ASIZE+a_inf.DSIZE+1-1];

assign  a_axis_rd_inf.axis_tvalid = a_datac_rd_rel_inf.valid;
assign  a_axis_rd_inf.axis_tdata = a_datac_rd_rel_inf.data[ a_inf.DSIZE-1:0];
assign  a_axis_rd_inf.axis_tlast = a_datac_rd_rel_inf.data[ a_inf.ASIZE+a_inf.DSIZE+1-1];
assign  a_datac_rd_rel_inf.ready = a_axis_rd_inf.axis_tready;
assign  xram_inf.addra = a_axis_inf.axis_tdata[ a_inf.ASIZE+a_inf.DSIZE+1-1- 1: a_inf.ASIZE+a_inf.DSIZE+1-a_inf.ASIZE- 1];
assign  xram_inf.dia = a_axis_inf.axis_tdata[ a_inf.DSIZE-1:0];
assign  xram_inf.wea = {xram_inf.MSIZE{a_axis_inf.axis_tdata[ a_inf.ASIZE+a_inf.DSIZE+1-1]}};
assign  xram_inf.ena = 1'b1;
assign  xram_inf.clka = a_inf.axi_aclk;
assign  xram_inf.rsta = ~a_inf.axi_aresetn;

assign  b_axis_inf.axis_tready = b_axis_inf.axis_tdata[ b_inf.ASIZE+b_inf.DSIZE+1-1] || (b_datac_rd_inf.ready && !b_axis_inf.axis_tdata[ b_inf.ASIZE+b_inf.DSIZE+1-1]);
assign  b_datac_rd_inf.data = {b_axis_inf.axis_tlast,b_axis_inf.axis_tdata[ b_inf.ASIZE+b_inf.DSIZE+1-1- 1: b_inf.ASIZE+b_inf.DSIZE+1-b_inf.ASIZE- 1]};
assign  b_datac_rd_inf.valid = b_axis_inf.axis_tvalid && !b_axis_inf.axis_tdata[ b_inf.ASIZE+b_inf.DSIZE+1-1];

assign  b_axis_rd_inf.axis_tvalid = b_datac_rd_rel_inf.valid;
assign  b_axis_rd_inf.axis_tdata = b_datac_rd_rel_inf.data[ b_inf.DSIZE-1:0];
assign  b_axis_rd_inf.axis_tlast = b_datac_rd_rel_inf.data[ b_inf.ASIZE+b_inf.DSIZE+1-1];
assign  b_datac_rd_rel_inf.ready = b_axis_rd_inf.axis_tready;
assign  xram_inf.addrb = b_axis_inf.axis_tdata[ b_inf.ASIZE+b_inf.DSIZE+1-1- 1: b_inf.ASIZE+b_inf.DSIZE+1-b_inf.ASIZE- 1];
assign  xram_inf.dib = b_axis_inf.axis_tdata[ b_inf.DSIZE-1:0];
assign  xram_inf.web = {xram_inf.MSIZE{b_axis_inf.axis_tdata[ b_inf.ASIZE+b_inf.DSIZE+1-1]}};
assign  xram_inf.enb = 1'b1;
assign  xram_inf.clkb = b_inf.axi_aclk;
assign  xram_inf.rstb = ~b_inf.axi_aresetn;

endmodule
