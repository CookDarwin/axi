/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/9/13 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_width_combin (
    (* up_stream = "true" *)
    axi_stream_inf.slaver   slim_axis,
    (* down_stream = "true" *)
    axi_stream_inf.master   wide_axis
);

initial begin
    assert(wide_axis.DSIZE%slim_axis.DSIZE == 0)
    else $error("Axi Stream Width Combin Error, wide_axis.DSIZE %% slim_axis.DSIZE != 0!!");
end

`define NSIZE wide_axis.DSIZE/slim_axis.DSIZE

logic                           clock;
logic                           rst_n;
logic[slim_axis.DSIZE-1:0]      wr_data;
logic[slim_axis.KSIZE-1:0]      wr_keep;
logic                           wr_vld;
logic                           wr_ready;
logic                           wr_last;

logic [wide_axis.DSIZE-1:0]     rd_data;
logic [wide_axis.KSIZE-1:0]     rd_keep;
logic                           rd_vld;
logic                           rd_ready;
logic                           rd_last;


assign clock    = slim_axis.aclk;
assign rst_n    = slim_axis.aresetn;

assign wr_data  = slim_axis.axis_tdata;
assign wr_vld   = slim_axis.axis_tvalid;
assign wr_last  = slim_axis.axis_tlast;
assign wr_keep  = slim_axis.axis_tkeep;
assign slim_axis.axis_tready    = wr_ready;

assign wide_axis.axis_tdata     = rd_data;
assign wide_axis.axis_tvalid    = rd_vld;
assign wide_axis.axis_tlast     = rd_last;
assign wide_axis.axis_tkeep     = rd_keep;
assign rd_ready = wide_axis.axis_tready;

assign wr_ready = rd_ready;

//--->> LOCK LAST STATUS <<-----------------------

logic   last_point;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  last_point <= 1'b0;
    else begin
        if(wr_vld && wr_ready && wr_last)
                last_point <= 1'b1;
        else if(rd_vld && rd_ready && last_point)
                last_point <= 1'b0;
        else    last_point <= last_point;
    end

logic [slim_axis.DSIZE-1:0]  last_data;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  last_data <= '0;
    else begin
        if(wr_vld && wr_ready && wr_last)
                last_data <= wr_data;
        else if(rd_vld && rd_ready && last_point)
                last_data <= '0;
        else    last_data <= last_data;
    end

logic [slim_axis.KSIZE-1:0]  last_keep;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  last_keep <= '0;
    else begin
        if(wr_vld && wr_ready && wr_last)
                last_keep <= wr_keep;
        else if(rd_vld && rd_ready && last_point)
                last_keep <= '0;
        else    last_keep <= last_keep;
    end

//---<< LOCK LAST STATUS >>-----------------------

reg [$clog2(`NSIZE)-1:0]    point;

always@(posedge clock/*,negedge rst_n*/)begin
    if(~rst_n)  point   <= '0;
    else begin
        if(last_point)begin
            if(wr_vld && wr_ready)
                    point   <= '0 +1'b1;
            else    point   <= '0;
        end else if(wr_vld && wr_ready)begin
            if(wr_last)
                    point   <= '0;
            else begin
                if(point == `NSIZE-1)
                        point   <= '0;
                else    point   <= point + 1'b1;
            end
        end else    point   <= point;
end end

always@(posedge clock/*,negedge rst_n*/)begin
    if(~rst_n)  rd_data <= '0;
    else begin
        if(wr_vld && wr_ready)
                rd_data[slim_axis.DSIZE*(`NSIZE-point)-1-:slim_axis.DSIZE]   <= wr_data;
        else if (last_point && !rd_vld)
                // rd_data <= {rd_data[DSIZE*NSIZE-1-DSIZE:0],rd_data[DSIZE*NSIZE-1-:DSIZE]};
                rd_data[slim_axis.DSIZE*(`NSIZE-point)-1-:slim_axis.DSIZE]   <= last_data;
        else    rd_data[slim_axis.DSIZE*(`NSIZE-point)-1-:slim_axis.DSIZE]   <= rd_data[slim_axis.DSIZE*(`NSIZE-point)-1-:slim_axis.DSIZE];
    end
end

always@(posedge clock/*,negedge rst_n*/)begin
    if(~rst_n)  rd_vld  <= 1'b0;
    else begin
        if(wr_vld && wr_ready && wr_last)
                rd_vld  <= 1'b1;
        else if(point==(`NSIZE-1) && wr_vld && wr_ready )
                rd_vld  <= 1'b1;
        else if(last_point && !rd_vld)
                rd_vld  <= 1'b1;
        else if(rd_vld && rd_ready)
                rd_vld  <= 1'b0;
        else    rd_vld  <= rd_vld;
    end
end


// always@(posedge clock/*,negedge rst_n*/)begin
//     if(~rst_n)  rd_last     <= 1'b0;
//     else begin
//         if(wr_vld && wr_ready )
//                 rd_last <= wr_last;
//         else if(rd_vld && rd_ready)
//                 rd_last <= 1'b0;
//         else    rd_last <= rd_last;
//     end
// end

always@(posedge clock/*,negedge rst_n*/)begin
    if(~rst_n)  rd_last     <= 1'b0;
    else begin
        if(wr_vld && wr_ready )
                rd_last <= wr_last;
        else if(last_point && !rd_last)
                rd_last  <= 1'b1;
        else if(rd_vld && rd_ready)
                rd_last <= 1'b0;
        else    rd_last <= rd_last;
    end
end

//--- >> KEEP SIGNEL <<---------
`define KSIZE  slim_axis.KSIZE
localparam WIDE_LOG8 = $clog2(wide_axis.DSIZE)%3 == 0;
localparam SLIM_LOG8 = $clog2(slim_axis.DSIZE)%3 == 0;
localparam WIDE_LOG2 = wide_axis.DSIZE == 2**$clog2(wide_axis.DSIZE);
localparam SLIM_LOG2 = slim_axis.DSIZE == 2**$clog2(slim_axis.DSIZE);
localparam SLIM_L8   = slim_axis.DSIZE >= 8;

generate
// if(($clog2(wide_axis.DSIZE)%3 == 0 && $clog2(slim_axis.DSIZE)%3 == 0) && (wide_axis.DSIZE == 2**$clog2(wide_axis.DSIZE) && slim_axis.DSIZE == 2**$clog2(slim_axis.DSIZE)))begin
if( WIDE_LOG8 && SLIM_LOG8 && WIDE_LOG2 && SLIM_LOG2 && SLIM_L8)begin
    always@(posedge clock/*,negedge rst_n*/)begin
        if(~rst_n)  rd_keep <= '0;
        else begin
            if(rd_vld && rd_ready)
                if(wr_vld && wr_ready)begin
                        rd_keep <= '0;
                        rd_keep[`KSIZE*(`NSIZE-0)-1-:`KSIZE]   <= wr_keep;
                end else begin
                        rd_keep <= '0;
                end
            else if(wr_vld && wr_ready)
                    rd_keep[`KSIZE*(`NSIZE-point)-1-:`KSIZE]   <= wr_keep;
            else if (last_point && !rd_vld)
                    // rd_data <= {rd_data[DSIZE*NSIZE-1-DSIZE:0],rd_data[DSIZE*NSIZE-1-:DSIZE]};
                    rd_keep[`KSIZE*(`NSIZE-point)-1-:`KSIZE]   <= last_keep;
            else    rd_keep[`KSIZE*(`NSIZE-point)-1-:`KSIZE]   <= rd_keep[`KSIZE*(`NSIZE-point)-1-:`KSIZE];
        end
    end
end
endgenerate
//--- << KEEP SIGNEL >>---------

endmodule
