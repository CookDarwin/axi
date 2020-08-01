/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    out of order
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/7 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_partition_rd_OD #(
    parameter PSIZE = 128 //master side
    // parameter real ADDR_STEP = 1
)(
    axi_inf.slaver_rd slaver,
    axi_inf.master_rd master
);

// localparam  ADDR_STEP = PSIZE*master.DSIZE / slaver.DSIZE;


import SystemPkg::*;

initial begin
    assert(slaver.IDSIZE+4 == master.IDSIZE)
    else begin
        $error("SLAVER AXIS IDSIZE+4 != MASTER AXIS IDSIZE");
        $stop;
    end
    assert(master.IDSIZE > 4)
    else begin
        $error("MASTER AXI IDSIZE[%d] MUST LARGER THAN 4",master.IDSIZE);
        $stop;
    end
end

logic       clock,rst_n;

assign      clock   = slaver.axi_aclk;
assign      rst_n   = slaver.axi_aresetn;

//--->> PARTITION STATE MACHINE <<----------------------
logic                       p_arvalid,p_arready;
logic [slaver.IDSIZE+3:0]   p_id;
logic [master.ASIZE-1:0]    p_araddr;
logic [master.LSIZE-1:0]    p_arlen;
logic                       p_ar_last;

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
        if(slaver.axi_arvalid && slaver.axi_arready)
                nstate  = GET_IP_A;
        else    nstate  = IDLE;
    GET_IP_A:
        if(len_overflow)
                nstate  = P_A;
        else    nstate  = O_A;
    P_A:
        if(p_arvalid && p_arready)
                nstate  = P_R;
        else    nstate  = P_A;
    P_R:
        if(partition_completel)
                // nstate  = L_A;
                nstate  = UP_LAST;
        else    nstate  = P_A;
    L_A:
        if(p_arvalid && p_arready)
                nstate  = L_R;
        else    nstate  = L_A;
    L_R:        nstate  = UP_LAST;
    O_A:
        if(p_arvalid && p_arready)
                nstate  = O_R;
        else    nstate  = O_A;
    O_R:        nstate  = UP_LAST;
    UP_LAST:    nstate  = IDLE;
    default:    nstate  = IDLE;
    endcase
end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  p_id    <= '0;
    else
        if(p_arvalid && p_arready)
                p_id    <= p_id + 1'b1;
        else    p_id    <= p_id;

//--->>> AUXILIARY FIFO <<<------------------------
logic [slaver.IDSIZE+3:0]  rp_id;
logic [master.ASIZE-1:0]   rp_araddr;
logic [master.LSIZE-1:0]   rp_arlen;
logic                      rp_ar_last;
logic                      fifo_empty;
logic                      fifo_full;
logic                      id_fifo_empty;
logic                      id_fifo_full;

common_fifo #(
    .DEPTH  (4      ),
    .DSIZE  (1+4+master.ASIZE+master.LSIZE+slaver.IDSIZE      )
)common_fifo_inst(
/*    input                    */   .clock      (clock                      ),
/*    input                    */   .rst_n      (rst_n                      ),
/*    input [DSIZE-1:0]        */   .wdata      ({p_ar_last,p_id,p_araddr,p_arlen}    ),
/*    input                    */   .wr_en      (p_arvalid && p_arready               ),
/*    output logic[DSIZE-1:0]  */   .rdata      ({rp_ar_last,rp_id,rp_araddr,rp_arlen} ),
/*    input                    */   .rd_en      (master.axi_arready && !fifo_empty && !id_fifo_full    ),       // STOP,untill rlast
/*    output logic[CSIZE-1:0]  */   .count      (                           ),
/*    output logic             */   .empty      (fifo_empty                 ),
/*    output logic             */   .full       (fifo_full                  )
);

assign master.axi_arvalid   = !fifo_empty && !id_fifo_full; // STOP,untill rlast

assign master.axi_arid      = rp_id[master.IDSIZE-1:0];
assign master.axi_araddr    = rp_araddr;
assign master.axi_arlen     = rp_arlen;

// (* dont_touch = "true" *)
logic[15:0]     len_cnt;
always@(posedge clock,negedge rst_n)
    if(~rst_n)  len_cnt <= '0;
    else begin
        if(p_arvalid && p_arready && p_ar_last)
                len_cnt <= '0;
        else if(p_arvalid && p_arready)
                len_cnt <= len_cnt + 1'b1;
        else    len_cnt <= len_cnt;
    end

//---<<< AUXILIARY FIFO >>>------------------------
//--->>> STREAM ID FIFO <<<------------------------
logic [slaver.IDSIZE+3:0]  stream_id;
logic [master.ASIZE-1:0]   stream_araddr;
logic [master.LSIZE-1:0]   stream_arlen;
logic                       stream_last;


common_fifo #(
    .DEPTH  (4      ),
    .DSIZE  (1+4+master.ASIZE+master.LSIZE+slaver.IDSIZE      )
)id_fifo_inst(
/*    input                    */   .clock      (clock                      ),
/*    input                    */   .rst_n      (rst_n                      ),
/*    input [DSIZE-1:0]        */   .wdata      ({rp_ar_last,rp_id,rp_araddr,rp_arlen} ),
/*    input                    */   .wr_en      ((master.axi_arvalid && master.axi_arready) ),
/*    output logic[DSIZE-1:0]  */   .rdata      ({stream_last,stream_id,stream_araddr,stream_arlen}     ),
/*    input                    */   .rd_en      ((master.axi_rvalid && master.axi_rready && master.axi_rlast)),
/*    output logic[CSIZE-1:0]  */   .count      (                           ),
/*    output logic             */   .empty      (id_fifo_empty              ),
/*    output logic             */   .full       (id_fifo_full               )
);

// assign slaver.axi_arready   = !fifo_full && !id_fifo_full;
assign p_arready = !fifo_full && !id_fifo_full;
//---<<< STREAM ID FIFO >>>------------------------
//---<< PARTITION STATE MACHINE >>----------------------
//--->> UP STREAM <<---------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  slaver.axi_arready  <= 1'b0;
    else
        case(nstate)
        IDLE:   slaver.axi_arready  <= 1'b1;
        default:slaver.axi_arready  <= 1'b0;
        endcase
//---<< UP STREAM >>---------------------------
//---->> DOWN STREAM <<------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  p_arvalid <= 1'b0;
    else
        case(nstate)
        P_A,O_A,L_A:
                p_arvalid <= 1'b1;
        default:p_arvalid <= 1'b0;
        endcase

//----<< DOWN STREAM >>------------------------
//---->> LAST AR <<----------------------------
logic [31:0]                length;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  p_ar_last    <= 1'b0;
    else
        case(nstate)
        // O_A,L_A:
        O_A:
                p_ar_last   <= 1'b1;
        P_A:    p_ar_last   <= (length <= PSIZE);
        default:p_ar_last   <= 1'b0;
        endcase
//----<< LAST AR >>----------------------------
//---->> LENDTH CTRL <<------------------------

always@(posedge clock,negedge rst_n)
    if(~rst_n)  len_overflow    <= 1'b0;
    else begin
        if(slaver.axi_arvalid  && slaver.axi_arready )
                len_overflow    <= slaver.axi_arlen + 1 > PSIZE;
        else if(slaver.axi_rready && slaver.axi_rvalid && slaver.axi_rlast)
                len_overflow    <= 1'b0;
        else    len_overflow    <= len_overflow;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  length    <= '0;
    else begin
        if(slaver.axi_arvalid  && slaver.axi_arready )
                length    <= slaver.axi_arlen + 1 ;
        else if(p_arvalid  && p_arready)begin
            if(length >= PSIZE)
                    length    <= length - PSIZE;
            else    length    <= '0;
        end else    length    <= length;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  p_arlen   <= '0;
    else begin
        if(length>=PSIZE)
                p_arlen   <= PSIZE-1;
        else    p_arlen   <= length-1;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  partition_completel <= 1'b0;
    else begin
        partition_completel <= (length <= PSIZE);
    end

//----<< LENDTH CTRL >>------------------------
//---->> ADDR CTRL   <<------------------------
// (* dont_touch = "true" *)
// logic[31:0]     addr_step_int;
// assign          addr_step_int = $rtoi(slaver.ADDR_STEP*1024);

always@(posedge clock,negedge rst_n)
    if(~rst_n)  p_araddr   <= '0;
    else begin
        if(slaver.axi_arvalid  && slaver.axi_arready)
                p_araddr   <= slaver.axi_araddr;
        else if(p_arvalid  && p_arready)
                p_araddr   <= p_araddr + (PSIZE*slaver.ADDR_STEP)/1024;
                // p_araddr   <= p_araddr + (PSIZE*addr_step_int)/1024;
        else    p_araddr   <= p_araddr;
    end
//----<< ADDR CTRL   >>------------------------
//---->> DATA STREAM <<------------------------
axi_stream_inf #(
   .DSIZE(master.DSIZE+slaver.IDSIZE)
)axis_in(
   .aclk        (master.axi_aclk    ),
   .aresetn     (master.axi_aresetn  ),
   .aclken      (1'b1               )
);

axi_stream_inf #(
   .DSIZE(slaver.DSIZE+slaver.IDSIZE)
)axis_out(
   .aclk        (slaver.axi_aclk   ),
   .aresetn     (slaver.axi_aresetn ),
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

assign  axis_in.axis_tvalid = master.axi_rvalid;
assign  axis_in.axis_tdata  = {master.axi_rid[master.IDSIZE-1 + (master.IDSIZE<5)*10:4],master.axi_rdata};
assign  axis_in.axis_tlast  = master.axi_rlast && stream_last;
assign  axis_in.axis_tkeep  = '1;
assign  axis_in.axis_tuser  = '0;
assign  master.axi_rready   = axis_in.axis_tready;

assign  slaver.axi_rvalid  = axis_out.axis_tvalid;
assign  {slaver.axi_rid,slaver.axi_rdata}   = axis_out.axis_tdata;
assign  slaver.axi_rlast   = axis_out.axis_tlast;
assign  axis_out.axis_tready= slaver.axi_rready;
//----<< DATA STREAM >>------------------------
//---->> RID CTRL <<---------------------------
// logic [slaver.IDSIZE+4-1:0]     arid;
//
// always@(posedge clock,negedge rst_n)
//     if(~rst_n)  arid    <= '0;
//     else begin
//         if(slaver.axi_arvalid  && slaver.axi_arready )
//                 arid    <= slaver.axi_arid;
//         else if(p_arvalid  && p_arready)begin
//             if(length >= PSIZE)
//                     arid[3:0]    <= arid[3:0] + 1'b1;
//             else    arid         <= '0;
//         end else    arid         <= arid;
//     end
// //----<< RID CTRL >>---------------------------
// assign master.axi_arid = arid[master.IDSIZE-1:0];

endmodule
