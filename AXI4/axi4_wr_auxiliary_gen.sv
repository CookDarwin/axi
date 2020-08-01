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
module axi4_wr_auxiliary_gen (
    axi_stream_inf.slaver       id_add_len_in,      //tlast is not necessary
    axi_inf.master_wr_aux       axi_wr_aux,
    output logic                stream_en
);

logic       clock,rst_n;
assign  clock   = axi_wr_aux.axi_aclk;
assign  rst_n   = axi_wr_aux.axi_aresetn;

typedef enum {IDLE,SET_AW,LAST_BYTE,RESP_DONE} STATUS;

STATUS nstate,cstate;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cstate  = IDLE;
    else        cstate  = nstate;

always_comb
    case(cstate)
    IDLE:
        if(id_add_len_in.axis_tvalid && id_add_len_in.axis_tready)
                nstate  = SET_AW;
        else    nstate  = IDLE;
    SET_AW:
        if(axi_wr_aux.axi_awvalid && axi_wr_aux.axi_awready)
                nstate  = LAST_BYTE;
        else    nstate  = SET_AW;
    LAST_BYTE:
        if(axi_wr_aux.axi_wvalid && axi_wr_aux.axi_wready && axi_wr_aux.axi_wlast)
                nstate  = RESP_DONE;
        else    nstate  = LAST_BYTE;
    RESP_DONE:
        if(axi_wr_aux.axi_bvalid && axi_wr_aux.axi_bvalid)
                nstate  = IDLE;
        else    nstate  = RESP_DONE;
    default:    nstate  = IDLE;
    endcase

logic [axi_wr_aux.ASIZE-1:0]    addr;
logic [axi_wr_aux.IDSIZE-1:0]   id;
logic [axi_wr_aux.LSIZE-1:0]    length;

always@(posedge clock,negedge   rst_n)
    if(~rst_n)  {id,addr,length}    <= '0;
    else begin
        if(id_add_len_in.axis_tvalid && id_add_len_in.axis_tready)
                {id,addr,length}    <= id_add_len_in.axis_tdata;
        else    {id,addr,length}    <= {id,addr,length};
    end

assign axi_wr_aux.axi_awaddr    = addr;
assign axi_wr_aux.axi_awlen     = length;
assign axi_wr_aux.axi_awid      = id;

always@(posedge clock,negedge   rst_n)
    if(~rst_n)  axi_wr_aux.axi_awvalid  <= 1'b0;
    else
        case(nstate)
        SET_AW: axi_wr_aux.axi_awvalid  <= 1'b1;
        default:axi_wr_aux.axi_awvalid  <= 1'b0;
        endcase

always@(posedge clock,negedge   rst_n)
    if(~rst_n)  axi_wr_aux.axi_bready  <= 1'b0;
    else
        case(nstate)
        RESP_DONE:
                axi_wr_aux.axi_bready  <= 1'b1;
        default:axi_wr_aux.axi_bready  <= 1'b0;
        endcase

always@(posedge clock,negedge   rst_n)
    if(~rst_n)  id_add_len_in.axis_tready   <= 1'b0;
    else
        case(nstate)
        IDLE:   id_add_len_in.axis_tready   <= 1'b1;
        default:id_add_len_in.axis_tready   <= 1'b0;
        endcase

always@(posedge clock,negedge   rst_n)
    if(~rst_n)  stream_en   <= 1'b0;
    else
        case(nstate)
        LAST_BYTE:
                stream_en   <= 1'b1;
        default:stream_en   <= 1'b0;
        endcase

endmodule
