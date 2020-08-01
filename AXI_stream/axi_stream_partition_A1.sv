/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.1.0 2017/9/29 
    rewrite
creaded: 2017/2/22 
madified:
***********************************************/
`timescale 1ns/1ps
import DataInterfacePkg::*;
(* axi_stream = "true" *)
module axi_stream_partition_A1 (
    input                      valve,               // [1] open [0] close
    input [31:0]               partition_len,       //[0] mean 1 len
    (* up_stream = "true" *)
    axi_stream_inf.slaver      axis_in,
    (* down_stream = "true" *)
    axi_stream_inf.master      axis_out
);


wire        clock,rst_n,clk_en;
assign      clock   = axis_in.aclk;
assign      rst_n   = axis_in.aresetn;
assign      clk_en  = axis_in.aclken;

axi_stream_inf #(
   .DSIZE       (axis_in.DSIZE )
)axis_valve(
   .aclk        (clock            ),
   .aresetn     (rst_n            ),
   .aclken      (clk_en           )
);

axis_valve axis_valve_inst(
/*    input                   */   .button          (valve      ),
/*    axi_stream_inf.slaver   */   .axis_in         (axis_valve ),
/*    axi_stream_inf.master   */   .axis_out        (axis_out   )
);

initial begin
    wait(rst_n);
    forever begin
        @(posedge clock);
        assert(partition_len > 1)
        else begin
            $error("\nAXIS PARTITION LENGTH MUST LARGER THAN 1\n");
            $finish;
        end
    end
end


axis_length_split axis_length_split_inst(
/*  input [31:0]          */ .length        (partition_len+1),
/*  axi_stream_inf.slaver */ .axis_in       (axis_in        ),
/*  axi_stream_inf.master */ .axis_out      (axis_valve     )
);

endmodule
