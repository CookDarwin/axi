/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/22 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_partition_wr #(
    parameter PSIZE = 128,
    parameter real ADDR_STEP = 1
)(
    axi_inf.slaver_wr axi_in,
    axi_inf.master_wr axi_out
);

logic       clock,rst_n;

assign      clock   = axi_in.axi_aclk;
assign      rst_n   = axi_in.axi_aresetn;

typedef enum {IDLE,GET_IP_A,P_A,P_W,P_B,O_A,O_W,O_B,UP_B,L_A,L_W,L_B}    STATUS;

STATUS nstate,cstate;

logic   len_overflow;
logic   partition_complete;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cstate  <= IDLE;
    else        cstate  <= nstate;

always_comb
    case(cstate)
    IDLE:
        if(axi_in.axi_awvalid && axi_in.axi_awready)
                nstate  = GET_IP_A;
        else    nstate  = IDLE;
    GET_IP_A:
        if(len_overflow)
                nstate  = P_A;
        else    nstate  = O_A;
    P_A:
        if(axi_out.axi_awvalid && axi_out.axi_awready)
                nstate  = P_W;
        else    nstate  = P_A;
    P_W:
        if(axi_out.axi_wvalid && axi_out.axi_wready && axi_out.axi_wlast)
                nstate  = P_B;
        else    nstate  = P_W;
    P_B:
        if(axi_out.axi_bvalid && axi_out.axi_bready)begin
            if(partition_complete)
                    nstate  = L_A;
            else    nstate  = P_A;
        end else    nstate  = P_B;
    L_A:
        if(axi_out.axi_awvalid && axi_out.axi_awready)
                nstate  = L_W;
        else    nstate  = L_A;
    L_W:
        if(axi_out.axi_wvalid && axi_out.axi_wready && axi_out.axi_wlast)
                nstate  = L_B;
        else    nstate  = L_W;
    L_B:
        if(axi_out.axi_bvalid && axi_out.axi_bready)begin
                    nstate  = UP_B;
        end else    nstate  = L_B;
    O_A:
        if(axi_out.axi_awvalid && axi_out.axi_awready)
                nstate  = O_W;
        else    nstate  = O_A;
    O_W:
        if(axi_out.axi_wvalid && axi_out.axi_wready && axi_out.axi_wlast)
                nstate  = O_B;
        else    nstate  = O_W;
    O_B:
        if(axi_out.axi_bvalid && axi_out.axi_bready)
                nstate  = UP_B;
        else    nstate  = O_B;
    UP_B:
        if(axi_in.axi_bvalid && axi_in.axi_bready)
                nstate  = IDLE;
        else    nstate  = UP_B;
    default:    nstate  = IDLE;
    endcase

//---->> UP STREAM <<--------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  axi_in.axi_awready  <= 1'b0;
    else
        case(nstate)
        IDLE:   axi_in.axi_awready  <= 1'b1;
        default:axi_in.axi_awready  <= 1'b0;
        endcase

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axi_in.axi_bvalid  <= 1'b0;
    else
        case(nstate)
        UP_B:   axi_in.axi_bvalid  <= 1'b1;
        default:axi_in.axi_bvalid  <= 1'b0;
        endcase
//----<< UP STREAM >>--------------------------
//---->> DOWN STREAM <<------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  axi_out.axi_awvalid = 1'b0;
    else
        case(nstate)
        P_A,O_A,L_A:
                axi_out.axi_awvalid <= 1'b1;
        default:axi_out.axi_awvalid <= 1'b0;
        endcase

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axi_out.axi_bready <= 1'b0;
    else
        case(nstate)
        P_B,O_B,L_B:
                axi_out.axi_bready  <= 1'b1;
        default:axi_out.axi_bready  <= 1'b0;
        endcase
//----<< DOWN STREAM >>------------------------
//---->> LENDTH CTRL <<------------------------
logic [31:0]                length;
logic [axi_out.ASIZE-1:0]   awlen;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  len_overflow    <= 1'b0;
    else begin
        if(axi_in.axi_awvalid  && axi_in.axi_awready )
                len_overflow    <= axi_in.axi_awlen + 1 > PSIZE;
        else if(axi_in.axi_bready && axi_in.axi_bvalid)
                len_overflow    <= 1'b0;
        else    len_overflow    <= len_overflow;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  length    <= '0;
    else begin
        if(axi_in.axi_awvalid  && axi_in.axi_awready )
                length    <= axi_in.axi_awlen + 1 ;
        else if(axi_out.axi_awvalid  && axi_out.axi_awready)
                length    <= length - PSIZE;
        else    length    <= length;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  partition_complete <= 1'b0;
    else begin
        // case(nstate)
        // P_B:
            partition_complete <= (length <= PSIZE);
        // default:partition_complete <= partition_complete;
        // endcase
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  awlen   <= '0;
    else begin
        // if(axi_in.axi_awvalid  && axi_in.axi_awready)begin
        //     if(axi_in.axi_awlen + 1 > PSIZE)
        //             awlen   <= PSIZE-1;
        //     else    awlen   <= axi_in.axi_awlen;
        // end else if(axi_out.axi_awvalid  && axi_out.axi_awready)begin
            if(length>=PSIZE)
                    awlen   <= PSIZE-1;
            else    awlen   <= length-1;
        // end else    awlen   <= awlen;
    end
assign  axi_out.axi_awlen   = awlen;
//----<< LENDTH CTRL >>------------------------
//---->> ADDR CTRL   <<------------------------
logic[axi_out.ASIZE-1:0]    awaddr;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  awaddr   <= '0;
    else begin
        if(axi_in.axi_awvalid  && axi_in.axi_awready)
                awaddr   <= axi_in.axi_awaddr;
        else if(axi_out.axi_awvalid  && axi_out.axi_awready)
                awaddr   <= awaddr + int'(PSIZE*ADDR_STEP);
        else    awaddr   <= awaddr;
    end

assign axi_out.axi_awaddr   = awaddr;
//----<< ADDR CTRL   >>------------------------
//---->> DATA STREAM <<------------------------
logic   valve;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  valve  <= 1'b0;
    else
        case(nstate)
        P_W,O_W,L_W:
                valve  <= 1'b1;
        default:valve  <= 1'b0;
        endcase

axi_stream_inf #(
   .DSIZE(axi_in.DSIZE)
)axis_in(
   .aclk        (axi_in.axi_aclk    ),
   .aresetn     (axi_in.axi_aresetn  ),
   .aclken      (1'b1               )
);

axi_stream_inf #(
   .DSIZE(axi_out.DSIZE)
)axis_out(
   .aclk        (axi_out.axi_aclk   ),
   .aresetn     (axi_out.axi_aresetn ),
   .aclken      (1'b1               )
);

axi_stream_partition axi_stream_partition_inst(
/*    input                   */   .valve               (valve          ),
/*    input [31:0]            */   .partition_len       (PSIZE-1        ),       //[0] mean 1 len
/*    output                  */   .req_new_len         (               ),         //it is usefull, when last stream length is only one
/*    axi_stream_inf.slaver   */   .axis_in             (axis_in        ),
/*    axi_stream_inf.master   */   .axis_out            (axis_out       )
);

assign  axis_in.axis_tvalid = axi_in.axi_wvalid;
assign  axis_in.axis_tdata  = axi_in.axi_wdata;
assign  axis_in.axis_tlast  = axi_in.axi_wlast;
assign  axis_in.axis_tkeep  = '1;
assign  axis_in.axis_tuser  = '0;
assign  axi_in.axi_wready   = axis_in.axis_tready;

assign  axi_out.axi_wvalid  = axis_out.axis_tvalid;
assign  axi_out.axi_wdata   = axis_out.axis_tdata;
assign  axi_out.axi_wlast   = axis_out.axis_tlast;
assign  axis_out.axis_tready= axi_out.axi_wready;
//----<< DATA STREAM >>------------------------
endmodule
