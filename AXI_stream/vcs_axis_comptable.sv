/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
created: ###### Tue Sep 10 16:34:17 CST 2019
madified:
***********************************************/
`timescale 1ns/1ps
`include "define_macro.sv"
module vcs_axis_comptable #(
    `parameter_string   ORIGIN = "master",
    `parameter_string   TO     = "slaver"
)(
    axi_stream_inf         origin,
    axi_stream_inf         to
);

generate 
if(TO=="mirror")begin 
    if(TO=="mirror")begin 
        assign    to.axis_tdata   = origin.axis_tdata ;
        assign    to.axis_tvalid  = origin.axis_tvalid;
        assign    to.axis_tready  = origin.axis_tready;
        assign    to.axis_tuser   = origin.axis_tuser ;
        assign    to.axis_tlast   = origin.axis_tlast ;
        assign    to.axis_tkeep   = origin.axis_tkeep ;
    end else begin 
        initial begin
            $error("vcs_axis_comptable ORIGIN[%s] => [%s] ERROR",ORIGIN,TO);
            $stop;
        end
    end 
end else if(ORIGIN=="out_mirror")begin 
    if(TO=="master")begin 
        assign    origin.axis_tdata   = to.axis_tdata ;
        assign    origin.axis_tvalid  = to.axis_tvalid;
        assign    origin.axis_tready  = to.axis_tready;
        assign    origin.axis_tuser   = to.axis_tuser ;
        assign    origin.axis_tlast   = to.axis_tlast ;
        assign    origin.axis_tkeep   = to.axis_tkeep ;
    end else begin 
        initial begin
            $error("vcs_axis_comptable ORIGIN[%s] => [%s] ERROR",ORIGIN,TO);
            $stop;
        end
    end 
end else if(ORIGIN == "mirror")begin 
    if(TO=="slaver")begin 
        assign    to.axis_tdata   = origin.axis_tdata ;
        assign    to.axis_tvalid  = origin.axis_tvalid;
        // assign    to.axis_tready  = origin.axis_tready;
        assign    to.axis_tuser   = origin.axis_tuser ;
        assign    to.axis_tlast   = origin.axis_tlast ;
        assign    to.axis_tkeep   = origin.axis_tkeep ;
    end else begin 
        initial begin
            $error("vcs_axis_comptable ORIGIN[%s] => [%s] ERROR",ORIGIN,TO);
            $stop;
        end
    end
end else begin 
    initial begin
        $error("vcs_axis_comptable ORIGIN[%s] => [%s] ERROR",ORIGIN,TO);
        $stop;
    end
end
endgenerate


endmodule