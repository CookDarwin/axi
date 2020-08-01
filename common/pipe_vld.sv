/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018-5-18 16:20:24
madified:
***********************************************/
`timescale 1ns/1ps
module pipe_vld #(
    parameter   LAT = 4
)(
    input           clock,
    input           rst_n,
    input           in_valid,
    input           in_ready,
    output logic    out_valid
);

initial begin
    assert(LAT > 1)
    else begin
        $error("pipe_vld.LAT MUST be larger then 1",LAT);
        $stop();
    end
end



logic [LAT-1:0]     vld_vector;

always@(posedge clock,negedge rst_n)
    if(~rst_n) vld_vector   <= '0;
    else begin
        if(in_ready)
                vld_vector  <= {vld_vector[LAT-2:0],in_valid};
        else    vld_vector  <= vld_vector;
    end


assign out_valid = vld_vector[LAT-1];

endmodule
