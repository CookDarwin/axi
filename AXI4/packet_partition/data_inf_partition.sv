/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
created: xxxx.xx.xx
madified:
***********************************************/
`timescale 1ns/1ps

module data_inf_partition #(
    parameter  PLEN      = 128,
    parameter  LSIZE     = 8,
    parameter  IDSIZE    = 4,
    parameter  ADDR_STEP = 1
)(
    data_inf_c.slaver   data_in,
    data_inf_c.master   data_out,
    data_inf_c.master   partition_pulse_inf,
    data_inf_c.master   wait_last_inf
);

//==========================================================================
//-------- define ----------------------------------------------------------
logic  clock;
logic  rst_n;
logic tail_len;
logic one_long_stream;
logic fifo_wr;
logic [ IDSIZE+4-1:0]  curr_id ;
logic [LSIZE-1:0]  curr_length ;
logic [ data_in.DSIZE-IDSIZE- LSIZE-1:0]  curr_addr ;
logic [LSIZE-1:0]  wr_length ;
(* MARK_DEBUG="true" *)(* dont_touch="true" *)logic fifo_full;
(* MARK_DEBUG="true" *)(* dont_touch="true" *)logic fifo_empty;
(* MARK_DEBUG="true" *)(* dont_touch="true" *)logic [9:0]  st5_cnt ;
(* MARK_DEBUG="true" *)(* dont_touch="true" *)logic track_st5;

//==========================================================================
//-------- instance --------------------------------------------------------
common_fifo #(
    .DEPTH (6              ),
    .DSIZE (data_out.DSIZE )
)common_fifo_inst(
/* input  */.clock (data_in.clock                    ),
/* input  */.rst_n (data_in.rst_n                    ),
/* input  */.wdata ({curr_id,curr_addr,wr_length}    ),
/* input  */.wr_en (fifo_wr & ~fifo_full             ),
/* output */.rdata (data_out.data                    ),
/* input  */.rd_en (data_out.valid && data_out.ready ),
/* output */.count (/*unused */                      ),
/* output */.empty (fifo_empty                       ),
/* output */.full  (fifo_full                        )
);
//==========================================================================
//-------- expression ------------------------------------------------------
typedef enum { 
    IDLE,
    LOCK,
    Px,
    Pl,
    HOLD,
    WAT_PP,
    DONE,
    WAIT
} SE_STATE_ps;
SE_STATE_ps CSTATE_ps,NSTATE_ps;
initial begin
    assert( data_in.DSIZE+4== data_out.DSIZE)else begin
         $error("data_in.DSIZE<%d> != data_out.DSIZE<%d>",data_in.DSIZE,data_out.DSIZE);
         $stop;
    end
end

assign  clock = data_in.clock;
assign  rst_n = data_in.rst_n;

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         CSTATE_ps <= IDLE;
    end
    else begin
         CSTATE_ps <= NSTATE_ps;
    end
end

always_comb begin 
    case(CSTATE_ps) 
        IDLE:begin 
            if(data_in.valid && data_in.ready)begin
                 NSTATE_ps = LOCK;
            end
            else begin
                 NSTATE_ps = IDLE;
            end
        end
        LOCK:begin 
            if(one_long_stream)begin
                 NSTATE_ps = Pl;
            end
            else begin
                 NSTATE_ps = WAT_PP;
            end
        end
        WAT_PP:begin 
            if(partition_pulse_inf.valid && partition_pulse_inf.ready)begin
                 NSTATE_ps = Px;
            end
            else begin
                 NSTATE_ps = WAT_PP;
            end
        end
        Px:begin 
            if(~fifo_full)begin
                 NSTATE_ps = HOLD;
            end
            else begin
                 NSTATE_ps = Px;
            end
        end
        HOLD:begin 
            if(tail_len)begin
                 NSTATE_ps = Pl;
            end
            else begin
                 NSTATE_ps = WAT_PP;
            end
        end
        Pl:begin 
            if(~fifo_full)begin
                 NSTATE_ps = DONE;
            end
            else begin
                 NSTATE_ps = Pl;
            end
        end
        DONE:begin 
            if(fifo_empty)begin
                 NSTATE_ps = WAIT;
            end
            else begin
                 NSTATE_ps = DONE;
            end
        end
        WAIT:begin 
            if(wait_last_inf.valid && wait_last_inf.ready)begin
                 NSTATE_ps = IDLE;
            end
            else begin
                 NSTATE_ps = WAIT;
            end
        end
        default:begin 
             NSTATE_ps = IDLE;
        end
    endcase
end

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         data_in.ready <= 1'b0;
    end
    else begin
        case(NSTATE_ps) 
            IDLE:begin 
                 data_in.ready <= 1'b1;
            end
            default:begin 
                 data_in.ready <= 1'b0;
            end
        endcase
    end
end

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         curr_addr <= '0;
         curr_length <= '0;
    end
    else begin
        case(NSTATE_ps) 
            LOCK:begin 
                 one_long_stream <= data_in.data[ LSIZE-1:0]< PLEN;
                 curr_id[ IDSIZE+4-1:IDSIZE] <= 2'b00;
                 {curr_id[ IDSIZE-1:0],curr_addr,curr_length} <= data_in.data;
            end
            HOLD:begin 
                 curr_length <= ( curr_length-PLEN);
                 curr_addr <= ( curr_addr+( ADDR_STEP*PLEN/1024));
                 curr_id[ IDSIZE+4-1:IDSIZE] <= ( curr_id[ IDSIZE+2-1:IDSIZE]+1'b1);
            end
            IDLE,DONE:begin 
                 one_long_stream <= 1'b0;
            end
        endcase
    end
end

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         tail_len <= 1'b0;
    end
    else begin
        case(NSTATE_ps) 
            LOCK:begin 
                 tail_len <= ( data_in.data[ LSIZE-1:0]<PLEN);
            end
            HOLD:begin 
                if( curr_length<( PLEN*2-0))begin
                     tail_len <= 1'b1;
                end
                else begin
                     tail_len <= 1'b0;
                end
            end
        endcase
    end
end

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         wr_length <= '0;
         fifo_wr <= 1'b0;
    end
    else begin
        case(NSTATE_ps) 
            Px:begin 
                 wr_length <= ( PLEN-1'b1);
                 fifo_wr <= 1'b1;
            end
            Pl:begin 
                 wr_length <= curr_length;
                 fifo_wr <= 1'b1;
            end
            default:begin 
                 fifo_wr <= 1'b0;
            end
        endcase
    end
end

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         partition_pulse_inf.valid <= 1'b0;
         partition_pulse_inf.data <= '0;
    end
    else begin
        case(NSTATE_ps) 
            WAT_PP:begin 
                 partition_pulse_inf.valid <= 1'b1;
                 partition_pulse_inf.data <= '0;
            end
            default:begin 
                 partition_pulse_inf.valid <= 1'b0;
                 partition_pulse_inf.data <= '0;
            end
        endcase
    end
end

assign  data_out.valid = ~fifo_empty;

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         wait_last_inf.data <= '0;
         wait_last_inf.valid <= '0;
    end
    else begin
        case(NSTATE_ps) 
            WAIT:begin 
                 wait_last_inf.data <= '0;
                 wait_last_inf.valid <= 1'b1;
            end
            default:begin 
                 wait_last_inf.data <= '0;
                 wait_last_inf.valid <= 1'b0;
            end
        endcase
    end
end

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         st5_cnt <= '0;
         track_st5 <= 1'b0;
    end
    else begin
        case(NSTATE_ps) 
            WAT_PP:begin 
                 st5_cnt <= ( st5_cnt+1'b1);
                 track_st5 <= st5_cnt> 10'd200;
            end
            WAIT:begin 
                 st5_cnt <= ( st5_cnt+1'b1);
                 track_st5 <= st5_cnt> 10'd1000;
            end
            default:begin 
                 st5_cnt <= '0;
                 track_st5 <= 1'b0;
            end
        endcase
    end
end

endmodule
