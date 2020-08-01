/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    right shift data and combin data
author : Cook.Darwin
Version:
creaded: 2018-4-16 12:25:05
madified:
***********************************************/
`timescale 1ns/1ps
module data_c_pipe_inf_right_shift #(
    parameter SHIFT_BITS   = 1,
    parameter EX_SIZE      = 1
)(
    input [EX_SIZE-1:0]             ex_in,
    output logic[EX_SIZE-1:0]       ex_out,
    data_inf_c.slaver               slaver,
    data_inf_c.master               master
);

initial begin
    assert(SHIFT_BITS > 0 && SHIFT_BITS < slaver.DSIZE) else begin 
        $error("SHIFT_BITS[%d] must be in (0,slaver.DSIZE) ",SHIFT_BITS);
        $stop;
    end
end
logic   clock,rst_n;
assign  clock = master.clock;
assign  rst_n = master.rst_n;

logic   slaver_vld_rdy;
logic   master_vld_rdy;

assign  slaver_vld_rdy = slaver.valid && slaver.ready;
assign  master_vld_rdy = master.valid && master.ready;

logic [master.DSIZE-1:0]    buffer_data;
logic                       buffer_vld;
logic [EX_SIZE-1:0]         ex_buffer;

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

logic[SHIFT_BITS-1:0]   shift_data;
always@(posedge clock,negedge rst_n)
    if(~rst_n)begin   
        {shift_data,master.data}    <= '0;
        ex_out                      <= '0;
    end else begin
        case(nstate)
        VD_CN_EM_BUF:
            if(buffer_vld)begin
                {master.data,shift_data} <= {shift_data,buffer_data};
                ex_out                   <= ex_buffer;
            end else if(slaver_vld_rdy)begin
                {master.data,shift_data} <= {shift_data,slaver.data};
                ex_out                   <= ex_in;
            end else begin    
                {master.data,shift_data} <= {master.data,shift_data};
                ex_out                   <= ex_out;
            end
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
    if(~rst_n)begin   
        buffer_data <= '0;
    end else begin
        case(nstate)
        VD_CN_VD_BUF:
            if(slaver_vld_rdy)begin 
                buffer_data <= slaver.data;
                ex_buffer   <= ex_in;
            end else begin     
                buffer_data <= buffer_data;
                ex_buffer   <= ex_buffer;
            end 
        default: begin     
            buffer_data <= '0;
            ex_buffer   <= '0;
        end
        endcase
    end
//---<< BUFFER >>---------------------------

endmodule
