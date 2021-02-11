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

module axis_split_channel_verb (
    input [15:0]            split_len,
    axi_stream_inf.slaver   origin_inf,
    axi_stream_inf.master   first_inf,
    axi_stream_inf.master   end_inf
);

//==========================================================================
//-------- define ----------------------------------------------------------
logic  clock;
logic  rst_n;
logic [16-1:0]  insert_seed ;
logic [16-1:0]  next_split_len ;
axi_stream_inf #(.DSIZE(origin_inf.DSIZE),.USIZE(1)) origin_inf_insert (.aclk(origin_inf.aclk),.aresetn(origin_inf.aresetn),.aclken(1'b1)) ;
//==========================================================================
//-------- instance --------------------------------------------------------
axis_insert_copy axis_insert_copy_inst(
/* input                 */.insert_seed (insert_seed       ),
/* input                 */.insert_len  (8'd1              ),
/* axi_stream_inf.slaver */.in_inf      (origin_inf        ),
/* axi_stream_inf.master */.out_inf     (origin_inf_insert )
);
common_fifo #(
    .DEPTH (4  ),
    .DSIZE (16 )
)common_fifo_head_bytesx_inst(
/* input  */.clock (clock                                                                                          ),
/* input  */.rst_n (rst_n                                                                                          ),
/* input  */.wdata (split_len                                                                                      ),
/* input  */.wr_en ((origin_inf.axis_tcnt == '0) && origin_inf.axis_tvalid && origin_inf.axis_tready               ),
/* output */.rdata (next_split_len                                                                                 ),
/* input  */.rd_en (origin_inf_insert.axis_tvalid && origin_inf_insert.axis_tready && origin_inf_insert.axis_tlast ),
/* output */.count (/*unused */                                                                                    ),
/* output */.empty (/*unused */                                                                                    ),
/* output */.full  (/*unused */                                                                                    )
);
axi_stream_split_channel axi_stream_split_channel_inst(
/* input                 */.split_len  (next_split_len    ),
/* axi_stream_inf.slaver */.origin_inf (origin_inf_insert ),
/* axi_stream_inf.master */.first_inf  (first_inf         ),
/* axi_stream_inf.master */.end_inf    (end_inf           )
);
//==========================================================================
//-------- expression ------------------------------------------------------
assign  clock = origin_inf.aclk;
assign  rst_n = origin_inf.aresetn;

assign  insert_seed = ( split_len-1'b1);

endmodule
