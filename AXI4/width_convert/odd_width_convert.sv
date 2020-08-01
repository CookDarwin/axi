/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/4/20 
madified:
***********************************************/
`timescale 1ns/1ps
module odd_width_convert #(
    parameter   ISIZE = 12,
    parameter   OSIZE = 16
)(
    input                           clock,
    input                           rst_n,
    input [ISIZE-1:0]               wr_data,
    input                           wr_vld,
    output logic                    wr_ready,
    input                           wr_last,
    // input                           wr_align_last,      //can be leave 1'b0
    output logic[OSIZE-1:0]         rd_data,
    output logic                    rd_vld,
    input                           rd_ready,
    output logic                    rd_last
);

assign wr_ready = rd_ready;

initial begin
    assert(ISIZE < OSIZE)
    else begin
        $error("ISIZE MUST BE MORE SMALLER THAN OSIZE\n");
        $stop;
    end
end

logic [OSIZE*2-1:0]         cache;
logic [$clog2(OSIZE*2)-1:0] cache_point;
// logic [$clog2(OSIZE*2)-1:0] cache_rev_point;
logic [1:0]                 cache_vld;

logic [OSIZE*2-1:0]         cache_rev;
logic [1:0]                 cache_last;

// assign cache_rev    = {cache[OSIZE-1:0],cache[2*OSIZE-1:OSIZE]};

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cache_point <= '0;
    else begin
        if(wr_vld && wr_ready)begin
            if(wr_last)
                    cache_point <= '0;
            else if(cache_point+ISIZE < OSIZE*2)
                    cache_point <= cache_point + ISIZE;
            else    cache_point <= (cache_point + ISIZE)-OSIZE*2;
        end else begin
        /*
            if(rd_vld && rd_ready && rd_last)
                    cache_point <= '0;
            else */ cache_point <= cache_point;
        end
    end

// always@(posedge clock,negedge rst_n)
//     if(~rst_n)  cache_rev_point <= OSIZE;
//     else begin
//         if(wr_vld && wr_ready)begin
//             if(cache_rev+ISIZE+OSIZE< OSIZE*2)
//                     cache_rev_point <= cache_point + ISIZE + OSIZE;
//             else    cache_rev_point <= (cache_point + ISIZE + OSIZE)-OSIZE*2;
//         end else begin
//             cache_rev_point <= cache_rev_point;
//         end
//     end

// logic [OSIZE*2-1:0]     tmp_cache;

always_comb begin
    cache_rev[OSIZE*2-1-(cache_point+ISIZE - OSIZE*2)-:ISIZE]   = wr_data;
end

logic [ISIZE-1:0]   rev_wr_data;

always_comb begin
    foreach(wr_data[i])
        rev_wr_data[ISIZE-1-i] = wr_data[i];
end

logic       flag;
always@(posedge clock,negedge rst_n)
    if(~rst_n)  cache   <= '0;
    else begin
        if(wr_vld && wr_ready)begin
            if(cache_point+ISIZE < OSIZE*2)begin
                    cache[OSIZE*2-1-cache_point-:ISIZE] <= wr_data;
                    flag    <= 0;
            // else    cache <= {cache_rev[OSIZE-1:0],cache_rev[2*OSIZE-1:OSIZE]};
            end else begin
                flag <= 1;
            //    {cache[OSIZE-1:0],cache[2*OSIZE-1:OSIZE]}[OSIZE*2-1-(cache_point+ISIZE - OSIZE*2)-:ISIZE] <= wr_data;
                foreach(rev_wr_data[i])begin
                    if(cache_point+i<OSIZE*2)
                            cache[OSIZE*2-1-(cache_point+i)]          <= rev_wr_data[i];
                    else    cache[OSIZE*2-1-(cache_point+i-2*OSIZE)]  <= rev_wr_data[i];
                end
            end
        end else    cache <= cache;
    end

// logic       last_record;
//
// always@(posedge clock,negedge rst_n)
//     if(~rst_n)  last_record <= 1'b0;
//     else begin
//         if(wr_vld && wr_ready && wr_last)
//                 last_record  <= 1'b1;
//         else if(last_record && wr_ready)
//                 last_record  <= 1'b0;
//         else    last_record  <= last_record;
//     end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cache_vld[0]    <= 1'b0;
    else begin
        if(wr_vld && wr_ready)begin
            if(cache_point+ISIZE >= OSIZE && cache_point<OSIZE)
                    cache_vld[0]    <= 1'b1;
            else if(wr_last && (cache_point+ISIZE>2*OSIZE || cache_point+ISIZE <= OSIZE))
                    cache_vld[0]    <= 1'b1;
            else begin
                    cache_vld[0]    <= 1'b0;
            end
        end else if(cache_vld[0] && rd_ready && (!(cache_vld[1]&&cache_last[0])))
                cache_vld[0]    <= 1'b0;
        else    cache_vld[0]    <= cache_vld[0];
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cache_vld[1]    <= 1'b0;
    else begin
        if(wr_vld && wr_ready)begin
            if(cache_point+ISIZE >= 2*OSIZE && cache_point>=OSIZE)
                    cache_vld[1]    <= 1'b1;
            else if(wr_last && cache_point+ISIZE > OSIZE)
                    cache_vld[1]    <= 1'b1;
            else    cache_vld[1]    <= 1'b0;
        end else if(cache_vld[1] && rd_ready && (!(cache_vld[0]&&cache_last[1])) )
                cache_vld[1]    <= 1'b0;
        else    cache_vld[1]    <= cache_vld[1];
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cache_last[0]   <= 1'b0;
    else begin
        if(wr_vld && wr_ready)begin
            if(wr_last && (cache_point+ISIZE>2*OSIZE || cache_point+ISIZE <= OSIZE))
                    cache_last[0]    <= 1'b1;
            else    cache_last[0]    <= 1'b0;
        end else if(cache_vld[0] && rd_ready && cache_last[0] && !cache_vld[1])
                cache_last[0]    <= 1'b0;
        else if(cache_last == 2'b11)
                cache_last[0]    <= 1'b0;
        else    cache_last[0]    <= cache_last[0];
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cache_last[1]   <= 1'b0;
    else begin
        if(wr_vld && wr_ready)begin
            if(wr_last && cache_point+ISIZE>OSIZE)
                    cache_last[1]    <= 1'b1;
            else    cache_last[1]    <= 1'b0;
        end else if(cache_vld[1] && rd_ready && cache_last[1] && !cache_vld[0])
                cache_last[1]    <= 1'b0;
        else    cache_last[1]    <= cache_last[1];
    end

//--->> MEDUIM LEVEL <<----------------------------------
logic               in_m_vld;
logic [OSIZE-1:0]   in_m_data;
logic               in_m_last;

assign in_m_vld     = |cache_vld;
assign in_m_last    = |cache_last && ^cache_vld;

always_comb begin
    if(&cache_vld)begin
        if(cache_last[0])
                in_m_data   = cache[OSIZE-1:0];
        else    in_m_data   = cache[2*OSIZE-1:OSIZE];
    end else begin
        if(cache_vld[1])
                in_m_data   = cache[OSIZE-1:0];
        else    in_m_data   = cache[2*OSIZE-1:OSIZE];
    end
end

//---<< MEDUIM LEVEL >>----------------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  rd_vld  <= 1'b0;
    else begin
        if(in_m_vld && rd_ready)
                rd_vld  <= 1'b1;
        else if(rd_vld && rd_ready)
                rd_vld  <= 1'b0;
        else    rd_vld  <= rd_vld;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  rd_data <= '0;
    else begin
        if(in_m_vld && rd_ready)
                rd_data <= in_m_data;
        else    rd_data <= rd_data;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  rd_last <= 1'b0;
    else begin
        if(in_m_vld && rd_ready && in_m_last)
                rd_last <= 1'b1;
        else if(rd_vld && rd_ready && rd_last)
                rd_last <= 1'b0;
        else    rd_last <= rd_last;
    end

endmodule
