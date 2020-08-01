/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/8/23 
madified:
***********************************************/
`timescale 1ns/1ps
module next_prio #(
    parameter   NUM = 8,
    parameter   NSIZE = $clog2(NUM)
)(
    input [NSIZE-1:0]               curr_addr,
    input [NUM-1:0]                 array,
    output logic[NSIZE-1:0]         next_addr
);

int CC,II;
logic [NSIZE-1:0]       index;
logic [NSIZE-1:0]       addr_t;

always_comb begin
    addr_t = '0;
    for(CC=0;CC<NUM;CC++)begin
        if(CC==curr_addr || CC == 0)begin
            for(II=NUM;II>0;II--)begin
                if((NUM-II+CC)>=NUM )
                        index = CC-II;
                 else   index = NUM-II+CC;

                addr_t  = array[index] ? index : addr_t;
            end
        end
    end
end

assign next_addr = addr_t;

endmodule
