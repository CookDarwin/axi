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

module axis_head_cut_verc #(
    parameter  BYTE_BITS = 8
)(
    input [9:0]             bytes,
    axi_stream_inf.slaver   origin_inf,
    axi_stream_inf.master   out_inf
);

//==========================================================================
//-------- define ----------------------------------------------------------
localparam  DX  =  origin_inf.DSIZE/BYTE_BITS;
logic  clock;
logic  rst_n;
logic [4-1:0]  bytes_x ;
logic [4-1:0]  bytes_x_Q ;
logic [4-1:0]  bytes_x_tmp ;
logic [4-1:0]  bytes_x_sub_nDx ;
logic [2-1:0]  route_addr ;
logic [4-1:0]  bytes_y ;
logic [10-1:0]  tmp_loop ;
logic fifo_wr_en;
logic [4-1:0]  int_cut_len ;
logic [4-1:0]  shift_sel_pre ;
logic fifo_wr_en_lat;
logic [4-1:0]  shift_sel ;
axi_stream_inf #(.DSIZE(origin_inf.DSIZE),.USIZE(1)) origin_inf_post (.aclk(origin_inf.aclk),.aresetn(origin_inf.aresetn),.aclken(1'b1)) ;
axi_stream_inf #(.DSIZE(origin_inf.DSIZE),.USIZE(1)) sub_origin_inf [2:0] (.aclk(origin_inf.aclk),.aresetn(origin_inf.aresetn),.aclken(1'b1)) ;
axi_stream_inf #(.DSIZE(origin_inf.DSIZE),.USIZE(1)) origin_inf_ss (.aclk(origin_inf.aclk),.aresetn(origin_inf.aresetn),.aclken(1'b1)) ;
axi_stream_inf #(.DSIZE(origin_inf.DSIZE),.USIZE(1)) origin_inf_cut_mix (.aclk(origin_inf.aclk),.aresetn(origin_inf.aresetn),.aclken(1'b1)) ;
axi_stream_inf #(.DSIZE(origin_inf.DSIZE),.USIZE(1)) origin_inf_ss_E0 (.aclk(origin_inf.aclk),.aresetn(origin_inf.aresetn),.aclken(1'b1)) ;
axi_stream_inf #(.DSIZE(origin_inf.DSIZE),.USIZE(1)) origin_inf_ss_E0_CH (.aclk(origin_inf.aclk),.aresetn(origin_inf.aresetn),.aclken(1'b1)) ;
axi_stream_inf #(.DSIZE(out_inf.DSIZE),.USIZE(1)) out_inf_branchR587 (.aclk(out_inf.aclk),.aresetn(out_inf.aresetn),.aclken(1'b1)) ;
//==========================================================================
//-------- instance --------------------------------------------------------
axis_slaver_pipe_A1 #(
    .DEPTH (3 )
)axis_slaver_pipe_A1_inst(
/* axi_stream_inf.slaver */.axis_in  (origin_inf      ),
/* axi_stream_inf.master */.axis_out (origin_inf_post )
);
axi_stream_interconnect_S2M #(
    .NUM   (3 )
)axi_stream_interconnect_S2M_inst(
/* input                 */.addr (route_addr      ),
/* axi_stream_inf.slaver */.s00  (origin_inf_post ),
/* axi_stream_inf.master */.m00  (sub_origin_inf  )
);
common_fifo #(
    .DEPTH (4 ),
    .DSIZE (4 )
)common_fifo_head_bytesx_inst(
/* input  */.clock (clock                                                                                            ),
/* input  */.rst_n (rst_n                                                                                            ),
/* input  */.wdata (bytes_x                                                                                          ),
/* input  */.wr_en (fifo_wr_en && (bytes_x!= '0)                                                                     ),
/* output */.rdata (int_cut_len                                                                                      ),
/* input  */.rd_en ((sub_origin_inf[1].axis_tvalid && sub_origin_inf[1].axis_tready && sub_origin_inf[1].axis_tlast) ),
/* output */.count (/*unused */                                                                                      ),
/* output */.empty (/*unused */                                                                                      ),
/* output */.full  (/*unused */                                                                                      )
);
axis_head_cut_verb axis_head_cut_verb_inst(
/* input                 */.length   ({12'd0,int_cut_len} ),
/* axi_stream_inf.slaver */.axis_in  (sub_origin_inf[1]   ),
/* axi_stream_inf.master */.axis_out (origin_inf_ss       )
);
axis_append_A1 #(
    .MODE            ("END"         ),
    .DSIZE           (out_inf.DSIZE ),
    .HEAD_FIELD_LEN  (1             ),
    .HEAD_FIELD_NAME ("HEAD Filed"  ),
    .END_FIELD_LEN   (1             ),
    .END_FIELD_NAME  ("END Filed"   )
)axis_append_A1_inst(
/* input                 */.enable     (1'b1               ),
/* input                 */.head_value (/*unused */        ),
/* input                 */.end_value  ('0                 ),
/* axi_stream_inf.slaver */.origin_in  (origin_inf_cut_mix ),
/* axi_stream_inf.master */.append_out (origin_inf_ss_E0   )
);
common_fifo #(
    .DEPTH (4 ),
    .DSIZE (4 )
)common_fifo_head_nDx_inst(
/* input  */.clock (clock                                                                                       ),
/* input  */.rst_n (rst_n                                                                                       ),
/* input  */.wdata (shift_sel_pre                                                                               ),
/* input  */.wr_en (fifo_wr_en_lat                                                                              ),
/* output */.rdata (shift_sel                                                                                   ),
/* input  */.rd_en (origin_inf_ss_E0.axis_tvalid && origin_inf_ss_E0.axis_tready && origin_inf_ss_E0.axis_tlast ),
/* output */.count (/*unused */                                                                                 ),
/* output */.empty (/*unused */                                                                                 ),
/* output */.full  (/*unused */                                                                                 )
);
axis_connect_pipe_right_shift_verb #(
    .SHIFT_BYTE_BIT (BYTE_BITS ),
    .SNUM           (DX        )
)axis_connect_pipe_right_shift_verb_inst(
/* input                 */.shift_sel (shift_sel           ),
/* axi_stream_inf.slaver */.axis_in   (origin_inf_ss_E0    ),
/* axi_stream_inf.master */.axis_out  (origin_inf_ss_E0_CH )
);
axis_head_cut_verb last_cut_inst(
/* input                 */.length   (16'd1               ),
/* axi_stream_inf.slaver */.axis_in  (origin_inf_ss_E0_CH ),
/* axi_stream_inf.master */.axis_out (out_inf_branchR587  )
);
//==========================================================================
//-------- expression ------------------------------------------------------

axi_stream_inf #(.DSIZE(out_inf.DSIZE))  sub_out_inf[2-1:0](.aclk(out_inf.aclk),.aresetn(out_inf.aresetn),.aclken(1'b1));


axis_direct  axis_direct_out_inf_inst0 (
/*  axi_stream_inf.slaver*/ .slaver (sub_origin_inf[0]),
/*  axi_stream_inf.master*/ .master (sub_out_inf[0])
);

axis_direct  axis_direct_out_inf_inst1 (
/*  axi_stream_inf.slaver*/ .slaver (out_inf_branchR587),
/*  axi_stream_inf.master*/ .master (sub_out_inf[1])
);


axi_stream_inf #(.DSIZE(origin_inf_cut_mix.DSIZE))  sub_origin_inf_cut_mix[2-1:0](.aclk(origin_inf_cut_mix.aclk),.aresetn(origin_inf_cut_mix.aresetn),.aclken(1'b1));


axis_direct  axis_direct_origin_inf_cut_mix_inst0 (
/*  axi_stream_inf.slaver*/ .slaver (origin_inf_ss),
/*  axi_stream_inf.master*/ .master (sub_origin_inf_cut_mix[0])
);

axis_direct  axis_direct_origin_inf_cut_mix_inst1 (
/*  axi_stream_inf.slaver*/ .slaver (sub_origin_inf[2]),
/*  axi_stream_inf.master*/ .master (sub_origin_inf_cut_mix[1])
);
initial begin
    assert( DX<17)else begin
         $error("param.DX<%0d> !< 17",DX);
         $stop;
    end
end

assign  clock = origin_inf.aclk;
assign  rst_n = origin_inf.aresetn;

always_comb begin 
     bytes_x_tmp = '0;
    for(integer gvar_cc_1=0;gvar_cc_1<10;gvar_cc_1=gvar_cc_1+1)begin
        if( bytes<DX*(10-gvar_cc_1))begin
             bytes_x_tmp = ( 10-1- gvar_cc_1);
        end
    end
end

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         bytes_x <= '0;
         bytes_x_Q <= '0;
         bytes_x_sub_nDx <= '0;
    end
    else begin
         bytes_x <= bytes_x_tmp;
         bytes_x_Q <= bytes_x;
         bytes_x_sub_nDx <= ( bytes-( bytes_x*DX));
    end
end

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         route_addr <= '0;
    end
    else begin
        if( bytes=='0)begin
             route_addr <= 2'd0;
        end
        else if( bytes_x=='0)begin
             route_addr <= 2'd2;
        end
        else if( bytes_x_sub_nDx=='0)begin
             route_addr <= 2'd1;
        end
        else begin
             route_addr <= 2'd1;
        end
    end
end

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         fifo_wr_en <= 1'b0;
    end
    else begin
         fifo_wr_en <= ( origin_inf.axis_tcnt=='0&& origin_inf.axis_tvalid && origin_inf.axis_tready);
    end
end

assign  shift_sel_pre = ( DX-bytes_x_sub_nDx);


//----->> fifo_wr_en LAST DELAY <<------------------
latency #(
    .LAT    (2),
    .DSIZE  (1)
)fifo_wr_en_lat2_inst(
    clock,
    rst_n,
    fifo_wr_en,
    fifo_wr_en_lat
);
//-----<< fifo_wr_en LAST DELAY >>------------------


axi_stream_interconnect_M2S_A1 #(
//axi_stream_interconnect_M2S_noaddr #(
    .NUM        (2)
 //   .DSIZE      (out_inf.DSIZE)
)out_inf_M2S_noaddr_inst(
/*  axi_stream_inf.slaver */ .s00      (sub_out_inf ), //[NUM-1:0],
/*  axi_stream_inf.master */ .m00      (out_inf) //
);


axi_stream_interconnect_M2S_A1 #(
//axi_stream_interconnect_M2S_noaddr #(
    .NUM        (2)
 //   .DSIZE      (origin_inf.DSIZE)
)origin_inf_cut_mix_M2S_noaddr_inst(
/*  axi_stream_inf.slaver */ .s00      (sub_origin_inf_cut_mix ), //[NUM-1:0],
/*  axi_stream_inf.master */ .m00      (origin_inf_cut_mix) //
);

endmodule
