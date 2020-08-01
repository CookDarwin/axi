/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version:
creaded: ###### Fri May 1 12:59:50 CST 2020
madified:
***********************************************/
`timescale 1ns/1ps
(* data_inf_c = "true" *)
module data_c_pipe_latency #(
    parameter LAT  = 4
)(
    (* data_up = "true" *)
    data_inf_c.slaver     slaver,
    (* data_down = "true" *)
    data_inf_c.master     master
);

logic   clock,rst_n;
assign  clock = master.clock;
assign  rst_n = master.rst_n;


assign  slaver.ready    = master.ready; 

// initial begin
//     assert(LAT > 1)else begin 
//         $error("LAT must be larger than 1");
//         $stop;
//     end
// end


logic[LAT-1:0]              vld_array;
logic[slaver.DSIZE-1:0]     data_array [LAT-1:0];

// FIRST
always@(posedge clock,negedge rst_n )begin 
    if(~rst_n)  vld_array[0]    <= 1'b0;
    else begin 
        if(slaver.ready)
                vld_array[0]    <= slaver.valid;
        else    vld_array[0]    <= vld_array[0];
    end 
end

generate
for(genvar KK=1;KK<LAT;KK++)begin 
    always@(posedge clock,negedge rst_n )begin 
        if(~rst_n)  vld_array[KK]    <= 1'b0;
        else begin 
            if(slaver.ready)
                    vld_array[KK]    <= vld_array[KK-1];
            else    vld_array[KK]    <= vld_array[KK];
        end 
    end
end 
endgenerate


assign master.valid     = vld_array[LAT-1];
assign master.data      = data_array[LAT-1];


endmodule
