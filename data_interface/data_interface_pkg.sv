/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version:
creaded: 2016/9/22 
madified:2017/2/24 
***********************************************/

package DataInterfacePkg;


function logic pipe_valid_func(input up_vld,input down_ready,input curr_vld);
    logic   next_vld;
    case({up_vld,down_ready,curr_vld})
    3'b000: next_vld    = 1'b0;
    3'b001: next_vld    = 1'b1;
    3'b010: next_vld    = 1'b0;
    3'b011: next_vld    = 1'b0;
    3'b100: next_vld    = 1'b0;
    3'b101: next_vld    = 1'b1;
    3'b110: next_vld    = 1'b1;
    3'b111: next_vld    = 1'b1;
    default:next_vld    = 1'b0;
    endcase
    return next_vld;
endfunction:pipe_valid_func

function logic pipe_valid_func_force(input up_vld,input down_ready,input curr_vld);
    logic   next_vld;
    case({up_vld,down_ready,curr_vld})
    3'b000: next_vld    = 1'b0;
    3'b001: next_vld    = 1'b1;
    3'b010: next_vld    = 1'b0;
    3'b011: next_vld    = 1'b0;
    3'b100: next_vld    = 1'b1;
    3'b101: next_vld    = 1'b1;
    3'b110: next_vld    = 1'b1;
    3'b111: next_vld    = 1'b1;
    default:next_vld    = 1'b0;
    endcase
    return next_vld;
endfunction:pipe_valid_func_force

function logic pipe_data_func(input up_vld,input down_ready,input curr_vld,input up_data,input curr_data);
    logic   next_data;
    case({up_vld,down_ready,curr_vld})
    3'b000: next_data    = curr_data;
    3'b001: next_data    = curr_data;
    3'b010: next_data    = curr_data;
    3'b011: next_data    = curr_data;
    3'b100: next_data    = curr_data;
    3'b101: next_data    = curr_data;
    3'b110: next_data    = up_data;
    3'b111: next_data    = up_data;
    default:next_data    = curr_data;
    endcase
    return next_data;
endfunction:pipe_data_func


function logic pipe_last_func(input vld,input ready,input curr_last,input condition);
    logic next_last;

    if(curr_last)begin
        if(ready && vld)
                next_last     = 1'b0;
        else    next_last     = 1'b1;
    end else begin
        if(condition && ready && vld)
                next_last     = 1'b1;
        else    next_last     = 1'b0;
    end
    return next_last;
endfunction:pipe_last_func

endpackage:DataInterfacePkg
