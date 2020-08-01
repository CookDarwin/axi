/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/23 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_partition_rd #(
    parameter PSIZE = 128,
    parameter real ADDR_STEP = 1
)(
    axi_inf.slaver_rd axi_in,
    axi_inf.master_rd axi_out
);

logic       clock,rst_n;

assign      clock   = axi_in.axi_aclk;
assign      rst_n   = axi_in.axi_aresetn;

typedef enum {IDLE,GET_IP_A,P_A,P_R,O_A,O_R,UP_LAST,L_A,L_R}    STATUS;

STATUS nstate,cstate;

always@(posedge clock,negedge rst_n)begin
    if(~rst_n)  cstate  <= IDLE;
    else        cstate  <= nstate;
end

logic   len_overflow;
logic   partition_completel;

always_comb begin
    case(cstate)
    IDLE:
        if(axi_in.axi_arvalid && axi_in.axi_arready)
                nstate  = GET_IP_A;
        else    nstate  = IDLE;
    GET_IP_A:
        if(len_overflow)
                nstate  = P_A;
        else    nstate  = O_A;
    P_A:
        if(axi_out.axi_arvalid && axi_out.axi_arready)
                nstate  = P_R;
        else    nstate  = P_A;
    P_R:
        if(axi_out.axi_rvalid && axi_out.axi_rready && axi_out.axi_rlast)begin
            if(partition_completel)
                    nstate  = L_A;
            else    nstate  = P_A;
        end else    nstate  = P_R;
    L_A:
        if(axi_out.axi_arvalid && axi_out.axi_arready)
                nstate  = L_R;
        else    nstate  = L_A;
    L_R:
        if(axi_out.axi_rvalid && axi_out.axi_rready && axi_out.axi_rlast)
                nstate  = UP_LAST;
        else    nstate  = L_R;
    O_A:
        if(axi_out.axi_arvalid && axi_out.axi_arready)
                nstate  = O_R;
        else    nstate  = O_A;
    O_R:
        if(axi_out.axi_rvalid && axi_out.axi_rready && axi_out.axi_rlast)
                nstate  = UP_LAST;
        else    nstate  = O_R;
    UP_LAST:    nstate  = IDLE;
    default:    nstate  = IDLE;
    endcase
end
//--->> UP STREAM <<---------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  axi_in.axi_arready  <= 1'b0;
    else
        case(nstate)
        IDLE:   axi_in.axi_arready  <= 1'b1;
        default:axi_in.axi_arready  <= 1'b0;
        endcase
//---<< UP STREAM >>---------------------------
//---->> DOWN STREAM <<------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  axi_out.axi_arvalid <= 1'b0;
    else
        case(nstate)
        P_A,O_A,L_A:
                axi_out.axi_arvalid <= 1'b1;
        default:axi_out.axi_arvalid <= 1'b0;
        endcase

//----<< DOWN STREAM >>------------------------
//---->> LENDTH CTRL <<------------------------
logic [31:0]                length;
logic [axi_out.ASIZE-1:0]   arlen;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  len_overflow    <= 1'b0;
    else begin
        if(axi_in.axi_arvalid  && axi_in.axi_arready )
                len_overflow    <= axi_in.axi_arlen + 1 > PSIZE;
        else if(axi_in.axi_rready && axi_in.axi_rvalid && axi_in.axi_rlast)
                len_overflow    <= 1'b0;
        else    len_overflow    <= len_overflow;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  length    <= '0;
    else begin
        if(axi_in.axi_arvalid  && axi_in.axi_arready )
                length    <= axi_in.axi_arlen + 1 ;
        else if(axi_out.axi_arvalid  && axi_out.axi_arready)
                length    <= length - PSIZE;
        else    length    <= length;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  partition_completel <= 1'b0;
    else begin
        partition_completel <= (length <= PSIZE);
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  arlen   <= '0;
    else begin
        // if(axi_in.axi_arvalid  && axi_in.axi_arready)begin
        //     if(axi_in.axi_arlen + 1 > PSIZE)
        //             arlen   <= PSIZE-1;
        //     else    arlen   <= axi_in.axi_arlen;
        // end else if(axi_out.axi_arvalid  && axi_out.axi_arready)begin
            if(length>=PSIZE)
                    arlen   <= PSIZE-1;
            else    arlen   <= length-1;
    //     end else    arlen   <= arlen;
    end
assign  axi_out.axi_arlen   = arlen;
//----<< LENDTH CTRL >>------------------------
//---->> ADDR CTRL   <<------------------------
logic[axi_out.ASIZE-1:0]    araddr;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  araddr   <= '0;
    else begin
        if(axi_in.axi_arvalid  && axi_in.axi_arready)
                araddr   <= axi_in.axi_araddr;
        else if(axi_out.axi_arvalid  && axi_out.axi_arready)
                araddr   <= araddr + int'(PSIZE*ADDR_STEP);
        else    araddr   <= araddr;
    end

assign axi_out.axi_araddr   = araddr;
//----<< ADDR CTRL   >>------------------------
//---->> DATA STREAM <<------------------------
logic   pass_last;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  pass_last   <= 1'b0;
    else
        case(nstate)
        L_R,O_R:
                pass_last   <= 1'b1;
        default:pass_last   <= 1'b0;
        endcase


axi_stream_inf #(
   .DSIZE(axi_out.DSIZE)
)axis_in(
   .aclk        (axi_out.axi_aclk    ),
   .aresetn     (axi_out.axi_aresetn  ),
   .aclken      (1'b1               )
);

axi_stream_inf #(
   .DSIZE(axi_in.DSIZE)
)axis_out(
   .aclk        (axi_in.axi_aclk   ),
   .aresetn     (axi_in.axi_aresetn ),
   .aclken      (1'b1               )
);

// axi_stream_partition axi_stream_partition_inst(
// /*    input                   */   .valve               (valve          ),
// /*    input [31:0]            */   .partition_len       (PSIZE-1        ),       //[0] mean 1 len
// /*    output                  */   .req_new_len         (               ),         //it is usefull, when last stream length is only one
// /*    axi_stream_inf.slaver   */   .axis_in             (axis_in        ),
// /*    axi_stream_inf.master   */   .axis_out            (axis_out       )
// );

axis_connect_pipe axis_connect_pipe_inst(
/*    axi_stream_inf.slaver   */   .axis_in     (axis_in        ),
/*    axi_stream_inf.master   */   .axis_out    (axis_out       )
);

assign  axis_in.axis_tvalid = axi_out.axi_rvalid;
assign  axis_in.axis_tdata  = axi_out.axi_rdata;
assign  axis_in.axis_tlast  = axi_out.axi_rlast && pass_last;
assign  axis_in.axis_tkeep  = '1;
assign  axis_in.axis_tuser  = '0;
assign  axi_out.axi_rready   = axis_in.axis_tready;

assign  axi_in.axi_rvalid  = axis_out.axis_tvalid;
assign  axi_in.axi_rdata   = axis_out.axis_tdata;
assign  axi_in.axi_rlast   = axis_out.axis_tlast;
assign  axis_out.axis_tready= axi_in.axi_rready;
//----<< DATA STREAM >>------------------------
endmodule
