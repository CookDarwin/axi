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

module axis_to_axi4_wr(
    input logic[31:0]       addr,
    input logic[31:0]       max_length,
    axi_stream_inf.slaver   axis_in,
    axi_inf.master_wr       axi_wr
);

//------>> EX CODE <<-------------------

//int     MAX_LENGTH;
//assign     MAX_LENGTH     =   (axis_in.DSIZE <= 8)?  2**11 :
//                                (axis_in.DSIZE <= 16)? 2**10 :
//                                (axis_in.DSIZE <= 32)? 2**9  :
//                                (axis_in.DSIZE <= 64)? 2**8  :
//                                (axis_in.DSIZE <= 128)? 2**7 :
//                                (axis_in.DSIZE <= 256)? 2**6 :
//                                (axis_in.DSIZE <= 512)? 2**5 :  2**4;

initial begin
    assert(axis_in.DSIZE == axi_wr.DSIZE)
    else begin
        $error("STREAM DSIZE should eql AXI4 DSIZE");
        $finish;
    end
//    assert(axi_wr.LSIZE >= $clog2(MAX_LENGTH))
//    else begin
//        $error("AXIS LSIZE is too smaller");
//        $finish;
//    end
end
//------<< EX CODE >>-------------------

//==========================================================================
//-------- define ----------------------------------------------------------
logic [32-1:0]  addr_cur ;
logic [axi_wr.IDSIZE-1:0]  id ;
logic [axi_wr.ASIZE-1:0]  addr_s ;
logic [axi_wr.LSIZE-1:0]  len_s ;
logic [axi_wr.IDSIZE + axi_wr.ASIZE + axi_wr.LSIZE-1:0]  fifo_rdata ;
logic rd_en;
logic fifo_empty;
logic fifo_full;
logic stream_en;
axi_stream_inf #(.DSIZE(axis_in.DSIZE),.USIZE(1)) split_out (.aclk(axis_in.aclk),.aresetn(axis_in.aresetn),.aclken(1'b1)) ;
axi_stream_inf #(.DSIZE(axis_in.DSIZE),.USIZE(1)) long_fifo_axis_out (.aclk(axi_wr.axi_aclk),.aresetn(axi_wr.axi_aresetn),.aclken(1'b1)) ;
axi_stream_inf #(.DSIZE(axi_wr.IDSIZE + axi_wr.ASIZE + axi_wr.LSIZE),.USIZE(1)) id_add_len_in (.aclk(axi_wr.axi_aclk),.aresetn(axi_wr.axi_aresetn),.aclken(1'b1)) ;
axi_inf #(.DSIZE(axi_wr.DSIZE),.IDSIZE(axi_wr.IDSIZE),.ASIZE(axi_wr.ASIZE),.LSIZE(axi_wr.LSIZE),.MODE(axi_wr.MODE),.ADDR_STEP(axi_wr.ADDR_STEP)) axi_wr_vcs_cp_R442 (.axi_aclk(axi_wr.axi_aclk),.axi_aresetn(axi_wr.axi_aresetn)) ;
axi_stream_inf #(.DSIZE(axis_in.DSIZE),.USIZE(1)) pipe_axis (.aclk(axi_wr.axi_aclk),.aresetn(axi_wr.axi_aresetn),.aclken(1'b1)) ;
//==========================================================================
//-------- instance --------------------------------------------------------
axis_length_split_with_addr #(
    .ADDR_STEP (axi_wr.ADDR_STEP )
)axis_length_split_with_addr_inst(
/* input                 */.origin_addr (addr       ),
/* input                 */.length      (max_length ),
/* output                */.band_addr   (addr_cur   ),
/* axi_stream_inf.slaver */.axis_in     (axis_in    ),
/* axi_stream_inf.master */.axis_out    (split_out  )
);
axi_stream_long_fifo #(
    .DEPTH      (8    ),
    .BYTE_DEPTH (8192 )
)axi_stream_long_fifo_inst(
/* axi_stream_inf.slaver */.axis_in  (split_out          ),
/* axi_stream_inf.master */.axis_out (long_fifo_axis_out )
);
independent_clock_fifo #(
    .DEPTH (4                                           ),
    .DSIZE (axi_wr.IDSIZE + axi_wr.ASIZE + axi_wr.LSIZE )
)independent_clock_fifo_inst(
/* input  */.wr_clk   (axis_in.aclk                                                           ),
/* input  */.wr_rst_n (axis_in.aresetn                                                        ),
/* input  */.rd_clk   (axi_wr.axi_aclk                                                        ),
/* input  */.rd_rst_n (axi_wr.axi_aresetn                                                     ),
/* input  */.wdata    ({id,addr_s,len_s}                                                      ),
/* input  */.wr_en    (split_out.axis_tvalid && split_out.axis_tready && split_out.axis_tlast ),
/* output */.rdata    (fifo_rdata                                                             ),
/* input  */.rd_en    (rd_en                                                                  ),
/* output */.empty    (fifo_empty                                                             ),
/* output */.full     (fifo_full                                                              )
);
axi4_wr_auxiliary_gen_without_resp axi4_wr_auxiliary_gen_without_resp_inst(
/* output                        */.stream_en     (stream_en          ),
/* axi_stream_inf.slaver         */.id_add_len_in (id_add_len_in      ),
/* axi_inf.master_wr_aux_no_resp */.axi_wr_aux    (axi_wr_vcs_cp_R442 )
);
vcs_axi4_comptable #(
    .ORIGIN ("master_wr_aux_no_resp" ),
    .TO     ("master_wr"             )
)vcs_axi4_comptable_axi_wr_aux_R1813_axi_wr_inst(
/* input  */.origin (axi_wr_vcs_cp_R442 ),
/* output */.to     (axi_wr             )
);
axis_valve_with_pipe #(
    .MODE ("BOTH" )
)axis_valve_with_pipe_inst(
/* input                 */.button   (stream_en          ),
/* axi_stream_inf.slaver */.axis_in  (long_fifo_axis_out ),
/* axi_stream_inf.master */.axis_out (pipe_axis          )
);
//==========================================================================
//-------- expression ------------------------------------------------------
always_ff@(posedge axis_in.aclk,negedge axis_in.aresetn) begin 
    if(~axis_in.aresetn)begin
         id <= 0;
    end
    else if(split_out.axis_tvalid && split_out.axis_tready && split_out.axis_tlast)begin
         id <= ( id+1);
    end
    else begin
         id <= id;
    end
end

assign  addr_s = addr_cur;
assign  len_s = split_out.axis_tcnt;
assign  id_add_len_in.axis_tvalid = ~fifo_empty;
assign  id_add_len_in.axis_tdata = fifo_rdata;
assign  id_add_len_in.axis_tlast = "1'b1";
assign  rd_en = id_add_len_in.axis_tready;

assign  axi_wr.axi_wdata = pipe_axis.axis_tdata;
assign  axi_wr.axi_wstrb = ~pipe_axis.axis_tkeep;
assign  axi_wr.axi_wvalid = pipe_axis.axis_tvalid;
assign  axi_wr.axi_wlast = pipe_axis.axis_tlast;
assign  axi_wr.axi_bready = 1'b1;
assign  pipe_axis.axis_tready = axi_wr.axi_wready;

endmodule
