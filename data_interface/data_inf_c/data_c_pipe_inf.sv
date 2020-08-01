/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    abandon data_connect_pipe
author : Cook.Darwin
Version:
creaded: 2018-4-16 12:25:05
madified:
***********************************************/
`timescale 1ns/1ps
(* data_inf_c = "true" *)
module data_c_pipe_inf (
    (* data_up = "true" *)
    data_inf_c.slaver     slaver,
    (* data_down = "true" *)
    data_inf_c.master     master
);

logic   clock,rst_n;
assign  clock = master.clock;
assign  rst_n = master.rst_n;

logic   slaver_vld_rdy;
logic   master_vld_rdy;

assign  slaver_vld_rdy = slaver.valid && slaver.ready;
assign  master_vld_rdy = master.valid && master.ready;

logic [master.DSIZE-1:0]    buffer_data;
logic                       buffer_vld;

typedef enum {
    IDLE,
    VD_CN_EM_BUF,
    VD_CN_VD_BUF,
    EM_CN_EM_BUF
}   STATUS;

STATUS nstate,cstate;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cstate  <= IDLE;
    else        cstate  <= nstate;

always_comb begin
    case(cstate)
    IDLE:
        if(slaver_vld_rdy)
                nstate  = VD_CN_EM_BUF;
        else    nstate  = IDLE;
    VD_CN_EM_BUF:
        case({master_vld_rdy,slaver_vld_rdy})
        2'b00:  nstate  = VD_CN_EM_BUF;
        2'b10:  nstate  = IDLE;
        2'b01:  nstate  = VD_CN_VD_BUF;
        2'b11:  nstate  = VD_CN_EM_BUF;
        default:nstate  = IDLE;
        endcase
    VD_CN_VD_BUF:
        if(master_vld_rdy)
                nstate  = VD_CN_EM_BUF;
        else    nstate  = VD_CN_VD_BUF;
    default:    nstate  = IDLE;
    endcase
end


//--->> SLAVER <<---------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  slaver.ready    <= 1'b0;
    else begin
        case(nstate)
        IDLE,VD_CN_EM_BUF:
                slaver.ready    <= 1'b1;
        default:slaver.ready    <= 1'b0;
        endcase
    end
//---<< SLAVER >>---------------------------
//--->> MASTER <<---------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  master.valid    <= 1'b0;
    else begin
        case(nstate)
        VD_CN_EM_BUF,VD_CN_VD_BUF:
                master.valid    <= 1'b1;
        default:master.valid    <= 1'b0;
        endcase
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  master.data     <= '0;
    else begin
        case(nstate)
        IDLE:   master.data     <= '0;
        VD_CN_EM_BUF:
            if(buffer_vld)
                    master.data <= buffer_data;
            else if(slaver_vld_rdy)
                    master.data <= slaver.data;
            else    master.data <= master.data;
        default:;
        endcase
    end
//---<< MASTER >>---------------------------
//--->> BUFFER <<---------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  buffer_vld  <= 1'b0;
    else begin
        case(nstate)
        VD_CN_VD_BUF:
                buffer_vld  <= 1'b1;
        default:buffer_vld  <= 1'b0;
        endcase
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  buffer_data <= '0;
    else begin
        case(nstate)
        VD_CN_VD_BUF:
            if(slaver_vld_rdy)
                    buffer_data <= slaver.data;
            else    buffer_data <= buffer_data;
        default:    buffer_data <= '0;
        endcase
    end
//---<< BUFFER >>---------------------------
endmodule
