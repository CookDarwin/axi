/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0 ###### Fri Jun 12 19:40:02 CST 2020
    just for tdl
creaded: 2017/3/21 
madified:
***********************************************/
`timescale 1ns/1ps
module axis_direct_A1 #(
    parameter   IDSIZE = 8,
    parameter   ODSIZE = 8
)(
    axi_stream_inf.slaver   slaver,
    axi_stream_inf.master   master
);

// initial begin
//     assert(slaver.DSIZE == master.DSIZE)
//     else $error("SLAVER AXIS DATA WIDTH<%d> != MASTER AXIS DATA WIDTH<%d>",slaver.DSIZE,master.DSIZE);
// end

generate 
if( IDSIZE == ODSIZE)begin 
    initial begin
        assert(slaver.DSIZE == master.DSIZE)
        else $error("SLAVER AXIS DATA WIDTH<%d> != MASTER AXIS DATA WIDTH<%d>",slaver.DSIZE,master.DSIZE);
    end
    always_comb begin 
        master.axis_tdata  = slaver.axis_tdata   ;
        master.axis_tvalid = slaver.axis_tvalid  ;
        master.axis_tkeep  = slaver.axis_tkeep   ;
        master.axis_tuser  = slaver.axis_tuser   ;
        master.axis_tlast  = slaver.axis_tlast   ;
        slaver.axis_tready = master.axis_tready  ;
    end
end else begin 
    width_convert_verb #(
        .IDSIZE      (slaver.DSIZE  ),
        .ODSIZE      (master.DSIZE )
    )width_convert_verb_inst(
    /*  input                    */     .clock          (slaver.aclk           ),
    /*  input                    */     .rst_n          (slaver.aresetn        ),
    /*  input [ISIZE-1:0]        */     .wr_data        (slaver.axis_tdata     ),
    /*  input                    */     .wr_vld         (slaver.axis_tvalid    ),
    /*  output logic             */     .wr_ready       (slaver.axis_tready    ),
    /*  input                    */     .wr_last        (slaver.axis_tlast     ),
    /*  input                    */     .wr_align_last  (1'b0),      //can be leave 1'b0
    /*  output logic[OSIZE-1:0]  */     .rd_data        (master.axis_tdata    ),
    /*  output logic             */     .rd_vld         (master.axis_tvalid   ),
    /*  input                    */     .rd_ready       (master.axis_tready   ),
    /*  output                   */     .rd_last        (master.axis_tlast    )
    );
end 
endgenerate


//--->> CheckClock <<----------------
logic cc_done;
logic cc_same;
CheckPClock CheckPClock_inst(
/*  input         */      .aclk     (slaver.aclk    ),
/*  input         */      .bclk     (master.aclk    ),
/*  output logic  */      .done     (cc_done        ),
/*  output logic  */      .same     (cc_same        )
);

initial begin
    wait(cc_done);
    assert(cc_same)
    else begin
        $error("`axis_direct` clock is not same");
        $stop;
    end
end
//---<< CheckClock >>----------------

endmodule
