/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018/1/11 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axi_stream_long_cache #(
    parameter DEPTH = 8192
)(
    (* up_stream = "true" *)
    axi_stream_inf.slaver      axis_in,
    (* down_stream = "true" *)
    axi_stream_inf.master      axis_out
);

initial begin
    assert(axis_in.DSIZE == axis_out.DSIZE)
    else begin
        $error("SLAVER'DSIZE[%d] != MASTER'DSIZE[%d]",axis_in.DSIZE,axis_out.DSIZE);
        $stop;
    end
end

logic   empty;
logic   full;

fifo_36kb_long #(
    .DSIZE      (axis_out.DSIZE+1 ),
    .DEPTH      (DEPTH          )
)fifo_36kb_long_inst(
/*  input              */  .wr_clk      (axis_in.aclk       ),
/*  input              */  .wr_rst      (~axis_in.aresetn   ),
/*  input              */  .rd_clk      (axis_out.aclk      ),
/*  input              */  .rd_rst      (~axis_out.aresetn  ),
/*  input [DSIZE-1:0]  */  .din         ({axis_in.axis_tlast,axis_in.axis_tdata}    ),
/*  input              */  .wr_en       ((axis_in.axis_tvalid && !full)             ),
/*  input              */  .rd_en       ((axis_out.axis_tready && !empty)           ),
/*  output [DSIZE-1:0] */  .dout        ({axis_out.axis_tlast,axis_out.axis_tdata}  ),
/*  output             */  .full        (full               ),
/*  output             */  .empty       (empty              )
);

assign  axis_in.axis_tready     = !full;
assign  axis_out.axis_tvalid    = !empty;

assign axis_out.axis_tuser      = '0;
assign axis_out.axis_tkeep      = '1;

endmodule
