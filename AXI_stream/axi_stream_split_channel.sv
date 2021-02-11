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

module axi_stream_split_channel (
    input [15:0]            split_len,
    axi_stream_inf.slaver   origin_inf,
    axi_stream_inf.master   first_inf,
    axi_stream_inf.master   end_inf
);

//==========================================================================
//-------- define ----------------------------------------------------------
logic  clock;
logic  rst_n;
logic addr;
logic new_last;
axi_stream_inf #(.DSIZE(origin_inf.DSIZE),.USIZE(1)) origin_inf_add_last (.aclk(origin_inf.aclk),.aresetn(origin_inf.aresetn),.aclken(1'b1)) ;
axi_stream_inf #(.DSIZE(origin_inf.DSIZE),.USIZE(1)) sub_origin_inf [1:0] (.aclk(origin_inf.aclk),.aresetn(origin_inf.aresetn),.aclken(1'b1)) ;
//==========================================================================
//-------- instance --------------------------------------------------------
axi_stream_interconnect_S2M #(
    .NUM   (2 )
)axi_stream_interconnect_S2M_inst(
/* input                 */.addr (addr                ),
/* axi_stream_inf.slaver */.s00  (origin_inf_add_last ),
/* axi_stream_inf.master */.m00  (sub_origin_inf      )
);
//==========================================================================
//-------- expression ------------------------------------------------------

axi_stream_inf #(.DSIZE(first_inf.DSIZE))  sub_first_inf[1-1:0](.aclk(first_inf.aclk),.aresetn(first_inf.aresetn),.aclken(1'b1));


axis_direct  axis_direct_first_inf_inst0 (
/*  axi_stream_inf.slaver*/ .slaver (sub_origin_inf[0]),
/*  axi_stream_inf.master*/ .master (sub_first_inf[0])
);


axi_stream_inf #(.DSIZE(end_inf.DSIZE))  sub_end_inf[1-1:0](.aclk(end_inf.aclk),.aresetn(end_inf.aresetn),.aclken(1'b1));


axis_direct  axis_direct_end_inf_inst0 (
/*  axi_stream_inf.slaver*/ .slaver (sub_origin_inf[1]),
/*  axi_stream_inf.master*/ .master (sub_end_inf[0])
);
//-------- CLOCKs Total 3 ----------------------
//--->> CheckClock <<----------------
logic cc_done_7,cc_same_7;
integer cc_afreq_7,cc_bfreq_7;
ClockSameDomain CheckPClock_inst_7(
/*  input         */      .aclk     (origin_inf.aclk        ),
/*  input         */      .bclk     (first_inf.aclk         ),
/*  output logic  */      .done     (cc_done_7),
/*  output logic  */      .same     (cc_same_7),
/*  output integer */     .aFreqK   (cc_afreq_7),
/*  output integer */     .bFreqK   (cc_bfreq_7)
);

initial begin
    wait(cc_done_7);
    assert(cc_same_7)
    else begin
        $error("--- Error : `axi_stream_split_channel` clock is not same, origin_inf.aclk< %0f M> != first_inf.aclk<%0f M>",1000000.0/cc_afreq_7, 1000000.0/cc_bfreq_7);
        repeat(10)begin 
            @(posedge origin_inf.aclk);
        end
        $stop;
    end
end
//---<< CheckClock >>----------------

//--->> CheckClock <<----------------
logic cc_done_8,cc_same_8;
integer cc_afreq_8,cc_bfreq_8;
ClockSameDomain CheckPClock_inst_8(
/*  input         */      .aclk     (origin_inf.aclk        ),
/*  input         */      .bclk     (end_inf.aclk           ),
/*  output logic  */      .done     (cc_done_8),
/*  output logic  */      .same     (cc_same_8),
/*  output integer */     .aFreqK   (cc_afreq_8),
/*  output integer */     .bFreqK   (cc_bfreq_8)
);

initial begin
    wait(cc_done_8);
    assert(cc_same_8)
    else begin
        $error("--- Error : `axi_stream_split_channel` clock is not same, origin_inf.aclk< %0f M> != end_inf.aclk<%0f M>",1000000.0/cc_afreq_8, 1000000.0/cc_bfreq_8);
        repeat(10)begin 
            @(posedge origin_inf.aclk);
        end
        $stop;
    end
end
//---<< CheckClock >>----------------

//======== CLOCKs Total 3 ======================
assign  clock = origin_inf.aclk;
assign  rst_n = origin_inf.aresetn;

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         addr <= 1'b0;
         new_last <= 1'b0;
    end
    else begin
         new_last <= ( origin_inf.axis_tcnt==( split_len-2)&& origin_inf.axis_tvalid && origin_inf.axis_tready);
        if(origin_inf.axis_tvalid && origin_inf.axis_tready && origin_inf.axis_tlast)begin
             addr <= 1'b0;
        end
        else if( origin_inf.axis_tcnt==( split_len-1)&& origin_inf.axis_tvalid && origin_inf.axis_tready)begin
             addr <= 1'b1;
        end
        else begin
             addr <= addr;
        end
    end
end

assign  origin_inf_add_last.axis_tdata = origin_inf.axis_tdata;
assign  origin_inf_add_last.axis_tvalid = origin_inf.axis_tvalid;
assign  origin_inf_add_last.axis_tuser = origin_inf.axis_tuser;
assign  origin_inf_add_last.axis_tkeep = origin_inf.axis_tkeep;
assign  origin_inf_add_last.axis_tlast = ( origin_inf.axis_tlast|new_last);
assign  origin_inf.axis_tready = origin_inf_add_last.axis_tready;


axis_direct  axis_direct_first_inf_instMM (
/*  axi_stream_inf.slaver*/ .slaver (sub_first_inf[0]),
/*  axi_stream_inf.master*/ .master (first_inf)
);


axis_direct  axis_direct_end_inf_instMM (
/*  axi_stream_inf.slaver*/ .slaver (sub_end_inf[0]),
/*  axi_stream_inf.master*/ .master (end_inf)
);

endmodule
