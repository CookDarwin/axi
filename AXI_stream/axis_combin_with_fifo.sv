/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/23 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_combin_with_fifo #(
    parameter   MODE = "BOTH",      //HEAD END
    parameter   CUT_OR_COMBIN_BODY  = "ON" //ON OFF
)(
    input [15:0]               new_body_len,
    axi_stream_inf.slaver      head_inf,
    (* up_stream = "true" *)
    axi_stream_inf.slaver      body_inf,
    axi_stream_inf.slaver      end_inf,
    (* down_stream = "true" *)
    axi_stream_inf.master      m00
);


axi_stream_inf #(.DSIZE(head_inf.DSIZE)) head_buf_inf      (.aclk(head_inf.aclk),.aresetn(head_inf.aresetn),.aclken(head_inf.aclken));
axi_stream_inf #(.DSIZE(body_inf.DSIZE)) body_buf_inf      (.aclk(body_inf.aclk),.aresetn(body_inf.aresetn),.aclken(body_inf.aclken));
axi_stream_inf #(.DSIZE(end_inf.DSIZE))  end_buf_inf       (.aclk( end_inf.aclk),.aresetn( end_inf.aresetn),.aclken(end_inf.aclken));

generate
if(MODE=="BOTH"||MODE=="HEAD")
axi_stream_packet_fifo #(
    .DEPTH      (2      )   //2-4
)axi_stream_packet_fifo_head_inst(
/* axi_stream_inf.slaver */ .axis_in        (head_inf       ),
/* axi_stream_inf.master */ .axis_out       (head_buf_inf   )
);
endgenerate

axi_stream_packet_fifo #(
    .DEPTH      (2      )   //2-4
)axi_stream_packet_fifo_body_inst(
/* axi_stream_inf.slaver */ .axis_in        (body_inf       ),
/* axi_stream_inf.master */ .axis_out       (body_buf_inf   )
);

generate
if(MODE=="BOTH"||MODE=="END")
axi_stream_packet_fifo #(
    .DEPTH      (2      )   //2-4
)axi_stream_packet_fifo_end_inst(
/* axi_stream_inf.slaver */ .axis_in        (end_inf       ),
/* axi_stream_inf.master */ .axis_out       (end_buf_inf   )
);
endgenerate

axi_streams_scaler #(
    .MODE                  (MODE                 ),
    .CUT_OR_COMBIN_BODY    (CUT_OR_COMBIN_BODY   ),
    .DSIZE                 (body_inf.DSIZE       )
)axi_streams_scaler_inst(
/*  input [15:0]          */ .new_body_len      (new_body_len    ),
/*  axi_stream_inf.slaver */ .head_inf          (head_buf_inf    ),
/*  axi_stream_inf.slaver */ .body_inf          (body_buf_inf    ),
/*  axi_stream_inf.slaver */ .end_inf           (end_buf_inf     ),
/*  axi_stream_inf.master */ .m00               (m00             )
);

endmodule
