/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERB.0.0
    length is varible
creaded: 
madified: ###### Mon Sep 14 16:46:38 CST 2020
***********************************************/
`timescale 1ns/1ps
module axis_head_cut_verb (
    input[15:0]                 length,
    axi_stream_inf.slaver       axis_in,
    axi_stream_inf.master       axis_out
);

initial begin
    assert(axis_in.DSIZE == axis_out.DSIZE)
    else begin
        $error("axis_in DSIZE[%d] MUST EQL axis_out DSIZE[%d]",axis_in.DSIZE,axis_out.DSIZE);
        $stop;
    end
end

axi_stream_inf #(axis_in.DSIZE) post_slaver (axis_in.aclk,axis_in.aresetn,axis_in.aclken);

logic   ex_viliad;
always_ff@(posedge axis_in.aclk, negedge axis_in.aresetn)
    if(~axis_in.aresetn)
            ex_viliad   <= 1'b0;
    else begin 
        if(axis_in.axis_tvalid && axis_in.axis_tready)begin 
            if(axis_in.axis_tlast)
                    ex_viliad   <= 1'b0;
            else if(axis_in.axis_tcnt >= length - 1'b1)
                    ex_viliad   <= 1'b1;
            else    ex_viliad   <= ex_viliad;
        end else begin 
            ex_viliad   <= ex_viliad;
        end
    end

// assign post_slaver.axis_tdata   = axis_in.axis_tdata;
// assign post_slaver.axis_tvalid  = axis_in.axis_tvalid && axis_in.axis_tcnt >= length;
// assign axis_in.axis_tready      = post_slaver.axis_tready || axis_in.axis_tcnt < length;

assign post_slaver.axis_tdata   = axis_in.axis_tdata;
assign post_slaver.axis_tvalid  = axis_in.axis_tvalid && ex_viliad;
assign post_slaver.axis_tlast   = axis_in.axis_tlast;
assign axis_in.axis_tready      = post_slaver.axis_tready || ~ex_viliad;

axi_stream_cache axi_stream_cache_inst(
/*  axi_stream_inf.slaver  */ .axis_in      (post_slaver    ),
/*  axi_stream_inf.master  */ .axis_out     (axis_out         )
);


endmodule
