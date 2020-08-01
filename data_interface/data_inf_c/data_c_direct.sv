/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:   covert A to B
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/16 
madified:
***********************************************/
`timescale 1ns/1ps
(* data_inf_c = "true" *)
module data_c_direct (
    (* data_up = "true" *)
    data_inf_c.slaver     slaver,
    (* data_down = "true" *)
    data_inf_c.master     master
);

//--->> CheckClock <<----------------
logic cc_done;
logic cc_same;
CheckPClock CheckPClock_inst(
/*  input         */      .aclk     (slaver.clock    ),
/*  input         */      .bclk     (master.clock    ),
/*  output logic  */      .done     (cc_done        ),
/*  output logic  */      .same     (cc_same        )
);

initial begin
    wait(cc_done);
    assert(cc_same)
    else begin
        $error("`data_c_direct` clock is not same");
        $stop;
    end
end
//---<< CheckClock >>----------------
initial begin
    assert(slaver.DSIZE == master.DSIZE)
    else begin
        $error("`data_c_direct` slaver.DSIZE[%d] != master.DSIZE[%d]",slaver.DSIZE,master.DSIZE);
        $stop;
    end
end

assign slaver.ready     = master.ready;
assign master.valid     = slaver.valid;
assign master.data      = slaver.data;

endmodule
