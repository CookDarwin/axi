/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2016/11/21 
madified:
***********************************************/
`timescale 1ns/1ps
module width_destruct #(
    parameter   DSIZE   = 1,
    parameter   NSIZE   = 8
)(
    input                           clock,
    input                           rst_n,
    input [DSIZE*NSIZE-1:0]         wr_data,
    input                           wr_vld,
    output logic                    wr_ready,
    input                           wr_last,
    output logic[DSIZE-1:0]         rd_data,
    output logic                    rd_vld,
    output logic                    rd_last,
    input                           rd_ready
);

// assign rd_vld   = wr_vld;

localparam	RSIZE	= 	(NSIZE<16)?  4 : $clog2(NSIZE+1);

//
reg [RSIZE-1:0]     point;

logic [DSIZE-1:0]   overflow_data;
logic               overflow;
logic               overflow_last;

always@(posedge clock/*,negedge rst_n*/)begin
    if(~rst_n)  point   <= {RSIZE{1'b0}};
    else begin
        // if(rd_vld && rd_ready && rd_last)
        //         point   <= {RSIZE{1'b0}};
        if(wr_vld && wr_ready && wr_last)
                point   <= {RSIZE{1'b0}};
        else if(overflow && rd_ready)
                point   <= {RSIZE{1'b0}};
        else if(wr_vld && rd_ready)begin
            if(point == NSIZE-1)
                    point   <= {RSIZE{1'b0}};
            else    point   <= point + 1'b1;
        end else    point   <= point;
end end

always@(posedge clock/*,negedge rst_n*/)begin
    if(~rst_n)  wr_ready  <= 1'b0;
    else begin
        if(point==(NSIZE-2) && wr_vld && rd_ready)
                wr_ready <= 1'b1;
        else if(wr_ready && wr_vld)
                wr_ready <= 1'b0;
        else    wr_ready <= wr_ready;
    end
end


always@(posedge clock/*,negedge rst_n*/)begin
    if(~rst_n)  overflow_data   <= '0;
    else begin
        if((wr_ready & wr_vld) && (!rd_ready & rd_vld) )
                overflow_data   <= wr_data[DSIZE-1:0];
        else    overflow_data   <= overflow_data;
    end
end

always@(posedge clock/*,negedge rst_n*/)begin
    if(~rst_n)  overflow   <= '0;
    else begin
        if((wr_ready & wr_vld) && (!rd_ready & rd_vld) )
                overflow   <= 1'b1;
        else if(overflow && rd_ready)
                overflow   <= 1'b0;
        else    overflow   <= overflow;
    end
end

always@(posedge clock/*,negedge rst_n*/)begin
    if(~rst_n)  overflow_last   <= '0;
    else begin
        if((wr_ready & wr_vld) && (!rd_ready & rd_vld) )
                overflow_last   <= wr_last;
        else if(overflow && rd_ready && overflow_last)
                overflow_last   <= 1'b0;
        else    overflow_last   <= overflow_last;
    end
end

// logic   last_byte;
//
// always@(posedge clock/*,negedge rst_n*/)begin
//     if(~rst_n)  last_byte  <= 1'b0;
//     else begin
//         if(point==(NSIZE-1) && wr_vld && rd_ready)
//                 last_byte <= 1'b1;
//         else if(last_byte && wr_vld)
//                 last_byte <= 1'b0;
//         else    last_byte <= last_byte;
//     end
// end

// always@(posedge clock/*,negedge rst_n*/)begin
//     if(~rst_n)  rd_data <= {DSIZE{1'b0}};
//     else begin
//         // if(wr_vld && rd_ready)
//         if(wr_vld)
//                 rd_data <= wr_data[DSIZE*(NSIZE-point)-1-:DSIZE];
//         else    rd_data <= rd_data;
//
//         // rd_data <= wr_data[DSIZE*(NSIZE-point)-1-:DSIZE];
//     end
// end

always@(posedge clock/*,negedge rst_n*/)begin
    if(~rst_n)  rd_data <= {DSIZE{1'b0}};
    else begin
        case({overflow,wr_vld,rd_vld,rd_ready})
        4'b1000: rd_data <= rd_data;
        4'b1001: rd_data <= overflow_data;
        4'b1010: rd_data <= rd_data;
        4'b1011: rd_data <= overflow_data;
        4'b1100: rd_data <= rd_data;
        4'b1101: rd_data <= overflow_data;
        4'b1110: rd_data <= rd_data;
        4'b1111: rd_data <= overflow_data;

        4'b0000: rd_data <= rd_data;
        4'b0001: rd_data <= rd_data;
        4'b0010: rd_data <= rd_data;
        4'b0011: rd_data <= rd_data;
        4'b0100: rd_data <= rd_data;
        4'b0101: rd_data <= wr_data[DSIZE*(NSIZE-point)-1-:DSIZE];
        4'b0110: rd_data <= rd_data;
        4'b0111: rd_data <= wr_data[DSIZE*(NSIZE-point)-1-:DSIZE];
        default: rd_data <= rd_data;
        endcase
    end
end

always@(posedge clock/*,negedge rst_n*/)begin
    if(~rst_n)  rd_vld  <= 1'b0;
    else begin
        // if(wr_vld && wr_ready && wr_last)
        //     rd_vld  <= 1'b0;
        // else
            case({overflow,wr_vld,rd_vld,rd_ready})
            4'b1000: rd_vld  <= 1'b0;
            4'b1001: rd_vld  <= 1'b1;
            4'b1010: rd_vld  <= 1'b1;
            4'b1011: rd_vld  <= 1'b1;
            4'b1100: rd_vld  <= 1'b0;
            4'b1101: rd_vld  <= 1'b1;
            4'b1110: rd_vld  <= 1'b1;
            4'b1111: rd_vld  <= 1'b1;

            4'b0000: rd_vld  <= 1'b0;
            4'b0001: rd_vld  <= 1'b0;
            4'b0010: rd_vld  <= 1'b1;
            4'b0011: rd_vld  <= 1'b0;
            4'b0100: rd_vld  <= 1'b0;
            4'b0101: rd_vld  <= 1'b1;
            4'b0110: rd_vld  <= 1'b1;
            4'b0111: rd_vld  <= 1'b1;
            default: rd_vld  <= 1'b0;
            endcase
    end
end


always@(posedge clock/*,negedge rst_n*/)begin
    if(~rst_n)  rd_last  <= 1'b0;
    else begin
        case({overflow,wr_vld,rd_vld,rd_ready})
        4'b1000: rd_last  <= 1'b0;
        4'b1001: rd_last  <= overflow_last;
        4'b1010: rd_last  <= rd_last;
        4'b1011: rd_last  <= overflow_last;
        4'b1100: rd_last  <= 1'b0;
        4'b1101: rd_last  <= overflow_last;
        4'b1110: rd_last  <= rd_last;
        4'b1111: rd_last  <= overflow_last;

        4'b0000: rd_last  <= 1'b0;
        4'b0001: rd_last  <= 1'b0;
        4'b0010: rd_last  <= rd_last;
        4'b0011: rd_last  <= 1'b0;
        4'b0100: rd_last  <= 1'b0;
        4'b0101: rd_last  <= point==(NSIZE-1) && wr_last;
        4'b0110: rd_last  <= rd_last;
        4'b0111: rd_last  <= point==(NSIZE-1) && wr_last;
        default: rd_last  <= 1'b0;
        endcase
    end
end


endmodule
