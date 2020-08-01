/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERB.0.0 2017/9/28 
    use fifo
    compatible ku
    keep valid
creaded: 2017/2/28 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axi_stream_cache_verb (
    (* up_stream = "true" *)
    axi_stream_inf.slaver      axis_in,
    (* down_stream = "true" *)
    axi_stream_inf.master      axis_out
);


initial begin
    assert(axis_in.DSIZE == axis_out.DSIZE)
    else begin
        $error("\nSLAVER DSIZE[%d] MUST EQL MASTER DSIZE[%d]\n",axis_in.DSIZE,axis_out.DSIZE);
        $finish;
    end
end

logic   empty;
logic   full;


xilinx_fifo_verb #(
    .DSIZE      (axis_in.DSIZE+1+axis_in.KSIZE    ),
    .LENGTH     (2**(11 -  (axis_in.DSIZE/24+(axis_in.DSIZE%24 != 0)) )   )
)xilinx_fifo_verb_inst(
/*  input              */ .wr_clk       (axis_in.aclk       ),
/*  input              */ .wr_rst       (!axis_in.aresetn   ),
/*  input              */ .rd_clk       (axis_out.aclk      ),
/*  input              */ .rd_rst       (!axis_out.aresetn  ),
/*  input [DSIZE-1:0]  */ .din          ({axis_in.axis_tkeep,axis_in.axis_tlast,axis_in.axis_tdata}    ),
/*  input              */ .wr_en        ((axis_in.axis_tvalid && !full)             ),
/*  input              */ .rd_en        ((axis_out.axis_tready && !empty)           ),
/*  output [DSIZE-1:0] */ .dout         ({axis_out.axis_tkeep,axis_out.axis_tlast,axis_out.axis_tdata}  ),
/*  output             */ .full         (full               ),
/*  output             */ .empty        (empty              )
);

assign  axis_in.axis_tready     = !full;
assign  axis_out.axis_tvalid    = !empty;

assign axis_out.axis_tuser      = '0;
// assign axis_out.axis_tkeep      = '1;

endmodule
