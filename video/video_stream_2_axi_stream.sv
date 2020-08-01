/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/28 
madified:
***********************************************/
`timescale 1ns/1ps
`include "define_macro.sv"
module video_stream_2_axi_stream #(
    `parameter_string   MODE = "LINE"       //LINE FRAME
)(
    video_native_inf.compact_in         video_inf,
    axi_stream_inf.master               axis_out
);

logic       clock,rst_n;

assign      clock   = video_inf.pclk;
assign      rst_n   = video_inf.prst_n;

logic       stream_en;

generate
if(MODE == "FRAME")begin
always@(posedge clock,negedge rst_n)
    if(~rst_n)  stream_en   <= 1'b0;
    else begin
        if(video_inf.vs_falling)
                stream_en   <= 1'b1;
        else if(axis_out.axis_tvalid && axis_out.axis_tready && axis_out.axis_tlast)
                stream_en   <= 1'b0;
        else    stream_en   <= stream_en;
    end
end else begin

always@(posedge clock,negedge rst_n)
    if(~rst_n)  stream_en   <= 1'b0;
    else begin
        if(video_inf.hs_falling && video_inf.v_index < video_inf.vactive)
                stream_en   <= 1'b1;
        else if(axis_out.axis_tvalid && axis_out.axis_tready && axis_out.axis_tlast)
                stream_en   <= 1'b0;
        else    stream_en   <= stream_en;
    end
end
endgenerate

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_out.axis_tvalid    <= 1'b0;
    else begin
        axis_out.axis_tvalid    <= stream_en && video_inf.de;
    end


logic   burst_eq_1;
always@(posedge clock,negedge rst_n)
    if(~rst_n)  burst_eq_1  <= 1'b0;
    else begin
        if(MODE=="LINE")
                burst_eq_1  <= video_inf.hactive == 1;
        else if(MODE=="FRAME")
                burst_eq_1  <= video_inf.hactive == 1  && video_inf.vactive;
        else    burst_eq_1  <= burst_eq_1;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_out.axis_tlast    <= 1'b0;
    else begin
        if(burst_eq_1)
                axis_out.axis_tlast    <= 1'b1;
        else begin
            if(axis_out.axis_tvalid && axis_out.axis_tready && axis_out.axis_tlast)
                    axis_out.axis_tlast    <= 1'b0;
            else if(axis_out.axis_tvalid && axis_out.axis_tready && axis_out.axis_tcnt == (video_inf.hactive-2))
                    axis_out.axis_tlast    <= 1'b1;
            else    axis_out.axis_tlast    <= axis_out.axis_tlast;
        end
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_out.axis_tdata    <= 1'b0;
    else begin
        axis_out.axis_tdata    <= video_inf.de? video_inf.data : axis_out.axis_tdata;
    end

endmodule
