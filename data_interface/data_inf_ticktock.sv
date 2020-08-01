/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/17 
madified:
***********************************************/
`timescale 1ns/1ps
`include "define_macro.sv"
module data_inf_ticktack #(
    parameter DSIZE = 8,
    parameter SUB_HBIT = DSIZE-1,
    parameter SUB_LBIT = 0,
    `parameter_string MODE  = "COMPARE:<", //COMPARE:< COMPARE:> COMPARE:<= COMPARE:>= COMPARE:== COMPARE:!= ,INDEX
    parameter ISIZE = 32        // ONLY INDEX MODE
)(
    input                 clock,
    input                 rst_n,
    input [DSIZE-1:0]     compare_data,
    input [ISIZE-1:0]     index_data,
    (* data_up = "true" *)
    data_inf.slaver       slaver,
    data_inf.master       master
);

import SystemPkg::*;

initial begin
    assert(slaver.DSIZE == master.DSIZE)
    else begin
        $error("SLAVER AXIS DATA WIDTH != MASTER AXIS DATA WIDTH");
        $stop;
    end
end

logic   ex_ready;
logic   fifo_empty;
logic   fifo_full ;

common_fifo #(           //fifo can stack DEPTH+1 "DATA"
    .DEPTH      (3     ),
    .DSIZE      (slaver.DSIZE)
)fifo_inst(
/*    input                     */  .clock          (clock               ),
/*    input                     */  .rst_n          (rst_n               ),
/*    input [DSIZE-1:0]         */  .wdata          (slaver.data         ),
/*    input                     */  .wr_en          ((slaver.valid && slaver.ready )       ),
/*    output logic[DSIZE-1:0]   */  .rdata          (master.data         ),
/*    input                     */  .rd_en          ((master.ready && master.valid )       ),
/*    output logic              */  .empty          (fifo_empty          ),
/*    output logic              */  .full           (fifo_full           )
);

assign slaver.ready     = !fifo_full  && ex_ready;
assign master.valid     = !fifo_empty && ex_ready;
//--->> STATE MACHINE <<-----------------
logic   tick_trigger,tock_trigger;

typedef enum {IDLE,TICK_TOCK}   STATUS;
STATUS cstate,nstate;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cstate  <= IDLE;
    else        cstate  <= nstate;

always_comb
    case(cstate)
    IDLE:
        if(tick_trigger)
                nstate  = TICK_TOCK;
        else    nstate  = IDLE;
    TICK_TOCK:
        if(tock_trigger)
                nstate  = IDLE;
        else    nstate  = TICK_TOCK;
    default:    nstate  = IDLE;
    endcase

logic [slaver.DSIZE-1:0]    tock_reg;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  tock_reg    <= '0;
    else begin
        case(nstate)
        TICK_TOCK:begin
            if(slaver.valid && slaver.ready)
                    tock_reg    <= slaver.data;
            else    tock_reg    <= tock_reg;
        end
        default:    tock_reg    <= '0;
        endcase
    end

//---<< STATE MACHINE >>-----------------
//--->> BLOCK CTRL <<--------------------
logic        compare_tick;
logic        compare_tock;
logic        index_tick;
logic        index_tock;

generate
if(MODE=="COMPARE:<")begin:COMPARE_BLOCK
    assign compare_tick     =  (slaver.data[SUB_HBIT:SUB_LBIT] < compare_data) && (slaver.valid && slaver.ready);
    assign compare_tock     =  !(tock_reg[SUB_HBIT:SUB_LBIT]   < compare_data);
end else if(MODE=="COMPARE:>")begin
    assign compare_tick     =  (slaver.data[SUB_HBIT:SUB_LBIT] > compare_data) && (slaver.valid && slaver.ready);
    assign compare_tock     =  !(tock_reg  [SUB_HBIT:SUB_LBIT] > compare_data);
end else if(MODE=="COMPARE:<=")begin
    assign compare_tick     =  (slaver.data[SUB_HBIT:SUB_LBIT] <= compare_data) && (slaver.valid && slaver.ready);
    assign compare_tock     =  !(tock_reg  [SUB_HBIT:SUB_LBIT] <= compare_data);
end else if(MODE=="COMPARE:>=")begin
    assign compare_tick     =  (slaver.data[SUB_HBIT:SUB_LBIT] >= compare_data) && (slaver.valid && slaver.ready);
    assign compare_tock     =  !(tock_reg  [SUB_HBIT:SUB_LBIT] >= compare_data);
end else if(MODE=="COMPARE:==")begin
    assign compare_tick     =  (slaver.data[SUB_HBIT:SUB_LBIT] == compare_data) && (slaver.valid && slaver.ready);
    assign compare_tock     =  !(tock_reg  [SUB_HBIT:SUB_LBIT] == compare_data);
end else if(MODE=="COMPARE:!=")begin
    assign compare_tick     =  (slaver.data[SUB_HBIT:SUB_LBIT] != compare_data) && (slaver.valid && slaver.ready);
    assign compare_tock     =  !(tock_reg  [SUB_HBIT:SUB_LBIT] != compare_data);
end
endgenerate

generate
if(MODE=="INDEX")begin:INDEX_BLOCK
    assign index_tick     =  (!index_data[slaver.data[SUB_HBIT:SUB_LBIT]]) && (slaver.valid && slaver.ready);
    assign index_tock     =  index_data[tock_reg[SUB_HBIT:SUB_LBIT]];
end
endgenerate

generate
if(MODE=="INDEX")begin:TT_BLOCK
    assign tick_trigger     = index_tick;
    assign tock_trigger     = index_tock;
end else begin
    assign tick_trigger     = compare_tick;
    assign tock_trigger     = compare_tock;
end
endgenerate


always@(posedge clock,negedge rst_n)
    if(~rst_n) ex_ready <= 1'b0;
    else
        case(nstate)
        TICK_TOCK:
                ex_ready    <= 1'b0;
        default:ex_ready    <= 1'b1;
        endcase
//---<< BLOCK CTRL >>--------------------

endmodule
