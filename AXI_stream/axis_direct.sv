/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/21 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_direct (
    (* up_stream = "true" *)
    axi_stream_inf.slaver   slaver,
    (* down_stream = "true" *)
    axi_stream_inf.master   master
);

import SystemPkg::*;

initial begin
    assert(slaver.DSIZE == master.DSIZE)
    else $error("SLAVER AXIS DATA WIDTH<%d> != MASTER AXIS DATA WIDTH<%d>",slaver.DSIZE,master.DSIZE);
end

assign master.axis_tdata  = slaver.axis_tdata   ;
assign master.axis_tvalid = slaver.axis_tvalid  ;
assign master.axis_tkeep  = slaver.axis_tkeep   ;
assign master.axis_tuser  = slaver.axis_tuser   ;
assign master.axis_tlast  = slaver.axis_tlast   ;
assign slaver.axis_tready = master.axis_tready  ;


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
