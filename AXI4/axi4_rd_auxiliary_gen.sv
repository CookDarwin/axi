/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    it burst next after current be responed
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/1 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axi4_rd_auxiliary_gen (
    axi_stream_inf.slaver       id_add_len_in,      //tlast is not necessary
    axi_inf.master_rd_aux       axi_rd_aux
);

logic       clock,rst_n;
assign  clock   = axi_rd_aux.axi_aclk;
assign  rst_n   = axi_rd_aux.axi_aresetn;

typedef enum {IDLE,SET_AR,LAST_BYTE} STATUS;

STATUS nstate,cstate;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cstate  = IDLE;
    else        cstate  = nstate;

always_comb
    case(cstate)
    IDLE:
        if(id_add_len_in.axis_tvalid && id_add_len_in.axis_tready)
                nstate  = SET_AR;
        else    nstate  = IDLE;
    SET_AR:
        if(axi_rd_aux.axi_arvalid && axi_rd_aux.axi_arready)
                nstate  = LAST_BYTE;
        else    nstate  = SET_AR;
    LAST_BYTE:
        if(axi_rd_aux.axi_rvalid && axi_rd_aux.axi_rready && axi_rd_aux.axi_rlast)
                nstate  = IDLE;
        else    nstate  = LAST_BYTE;
    default:    nstate  = IDLE;
    endcase

logic [axi_rd_aux.ASIZE-1:0]    addr;
logic [axi_rd_aux.IDSIZE-1:0]   id;
logic [axi_rd_aux.LSIZE-1:0]    length;

always@(posedge clock,negedge   rst_n)
    if(~rst_n)  {id,addr,length}    <= '0;
    else begin
        if(id_add_len_in.axis_tvalid && id_add_len_in.axis_tready)
                {id,addr,length}    <= id_add_len_in.axis_tdata;
        else    {id,addr,length}    <= {id,addr,length};
    end

assign axi_rd_aux.axi_araddr    = addr;
assign axi_rd_aux.axi_arlen     = length;
assign axi_rd_aux.axi_arid      = id;

always@(posedge clock,negedge   rst_n)
    if(~rst_n)  axi_rd_aux.axi_arvalid  <= 1'b0;
    else
        case(nstate)
        SET_AR: axi_rd_aux.axi_arvalid  <= 1'b1;
        default:axi_rd_aux.axi_arvalid  <= 1'b0;
        endcase


always@(posedge clock,negedge   rst_n)
    if(~rst_n)  id_add_len_in.axis_tready   <= 1'b0;
    else
        case(nstate)
        IDLE:   id_add_len_in.axis_tready   <= 1'b1;
        default:id_add_len_in.axis_tready   <= 1'b0;
        endcase

//-->> TRACK <<-----------------
// (* dont_touch="true" *)
logic [axi_rd_aux.LSIZE-1:0] rcnt;

always@(posedge clock,negedge   rst_n)
    if(~rst_n)  rcnt    <= '0;
    else        rcnt    <= axi_rd_aux.axi_rcnt;
//--<< TRACK >>-----------------
endmodule
