/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version:VERA.0.1 2017/1/19 
creaded: 2016/9/27 
madified:
    VD_CN_EM_BUF -> VD_CN_EM_BUF, when from_up_vld && to_up_ready && !connector_vld
***********************************************/
`timescale 1ns/1ps
(* data_inf_c = "true" *)
module data_connect_pipe_inf (
    (* data_up = "true" *)
    data_inf_c.slaver     indata,
    (* data_down = "true" *)
    data_inf_c.master     outdata
);


import SystemPkg::*;

initial begin
    assert(indata.DSIZE == outdata.DSIZE)
    else begin
        $error("SLAVER DATA WIDTH != MASTER DATA WIDTH");
        $stop;
    end
end

logic               clock;
logic               rst_n;

assign  clock   = outdata.clock;
assign  rst_n   = outdata.rst_n;

// always@(posedge clock,negedge outdata.rst_n)
//     if(~outdata.rst_n)  rst_n   <= 1'b0;
//     else                rst_n   <= 1'b1;
//
// (* dont_touch = "true" *)
// logic test;
//
// always@(posedge clock,negedge outdata.rst_n)
//     if(~outdata.rst_n)  test   <= 1'b0;
//     else                test   <= 1'b1;
//
//
// (* dont_touch = "true" *)
// logic test1;
//
// always@(posedge indata.clock,negedge indata.rst_n)
//     if(~indata.rst_n)   test1   <= 1'b0;
//     else                test1   <= 1'b1;



data_connect_pipe #(
    .DSIZE      (indata.DSIZE)
)data_connect_pipe_inst(
/*  input             */  .clock            (clock          ),
/*  input             */  .rst_n            (rst_n          ),
/*  input             */  .clk_en           (1'b1           ),
/*  input             */  .from_up_vld      (indata.valid   ),
/*  input [DSIZE-1:0] */  .from_up_data     (indata.data    ),
/*  output            */  .to_up_ready      (indata.ready   ),
/*  input             */  .from_down_ready  (outdata.ready  ),
/*  output            */  .to_down_vld      (outdata.valid  ),
/*  output[DSIZE-1:0] */  .to_down_data     (outdata.data   )
);

endmodule
