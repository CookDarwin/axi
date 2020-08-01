/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________descript:
author : Cook.Darwin
Version: VERA.1.0 2018-4-16 12:04:47
    add trigger
creaded: 2018-4-13 12:39:59
madified:
***********************************************/
`timescale 1ns/1ps
module data_c_scaler_A1 #(
    parameter       MODE = "BOTH"
)(
    input                   trigger,
    input                   head_last,
    input                   body_last,
    input                   end_last,
    data_inf_c.slaver       head_inf,
    data_inf_c.slaver       body_inf,
    data_inf_c.slaver       end_inf,
    data_inf_c.master       m00
);

logic   clock,rst_n;
assign  clock = m00.clock;
assign  rst_n = m00.rst_n;

logic   head_vld_rdy,body_vld_rdy,end_vld_rdy,m00_vld_rdy;
logic   head_vld_rdy_last,body_vld_rdy_last,end_vld_rdy_last;

assign  head_vld_rdy = head_inf.valid && head_inf.ready;
assign  body_vld_rdy = body_inf.valid && body_inf.ready;
assign  end_vld_rdy  = end_inf.valid  && end_inf.ready;
assign  m00_vld_rdy  = m00.valid  && m00.ready;

assign  head_vld_rdy_last = head_inf.valid && head_inf.ready && head_last;
assign  body_vld_rdy_last = body_inf.valid && body_inf.ready && body_last;
assign  end_vld_rdy_last  = end_inf.valid  && end_inf.ready && end_last;

logic   jump_end;

generate
    if(MODE=="BOTH")
        assign jump_end    = 1'b1;
    else if(MODE=="END")
        assign jump_end    = 1'b1;
    else
        assign jump_end    = 1'b0;
endgenerate

typedef enum {
    IDLE,
    HEAD_EM_CN_EM_BUF,               //  empty connector,empty buffer
    HEAD_VD_CN_EM_BUF,               //  valid connector,empty buffer
    HEAD_VD_CN_VD_BUF,

    BODY_EM_CN_EM_BUF,
    BODY_VD_CN_EM_BUF,
    BODY_VD_CN_VD_BUF,

    END_EM_CN_EM_BUF,
    END_VD_CN_EM_BUF,
    END_VD_CN_VD_BUF,

    FSH_VD_CN_EM_BUF,
    FSH_VD_CN_VD_BUF
}   STATUS;

STATUS cstate,nstate;

always@(posedge clock,negedge rst_n)
    if(~rst_n)   cstate  <= IDLE;
    else         cstate  <= nstate;

logic [m00.DSIZE-1:0]   buffer_data;
logic                   buffer_vld;
logic                   head_last_buf,body_last_buf,end_last_buf;

always_comb begin
    case(cstate)
    IDLE:
        if(1)begin
            if(MODE=="BOTH")
                    nstate  = head_vld_rdy? (head_last? BODY_VD_CN_EM_BUF : HEAD_VD_CN_EM_BUF) : IDLE;
            else if(MODE=="HEAD")
                    nstate  = head_vld_rdy? (head_last? BODY_VD_CN_EM_BUF : HEAD_VD_CN_EM_BUF) : IDLE;
            else    nstate  = body_vld_rdy? (body_last? END_VD_CN_EM_BUF  : BODY_VD_CN_EM_BUF) : IDLE;
        end else begin
            nstate  = IDLE;
        end
    //-->> HEAD
    HEAD_VD_CN_EM_BUF:
        case({m00_vld_rdy,head_vld_rdy})
        2'b00:  nstate  = HEAD_VD_CN_EM_BUF;
        2'b10:  nstate  = HEAD_EM_CN_EM_BUF;
        2'b01:  nstate  = !head_last? HEAD_VD_CN_VD_BUF : BODY_VD_CN_VD_BUF;
        2'b11:  nstate  = !head_last? HEAD_VD_CN_EM_BUF : BODY_VD_CN_EM_BUF;
        default:;
        endcase
    HEAD_EM_CN_EM_BUF:
        if(head_vld_rdy)
                nstate  = !head_last? HEAD_VD_CN_EM_BUF : BODY_VD_CN_EM_BUF;
        else    nstate  = HEAD_EM_CN_EM_BUF;
    HEAD_VD_CN_VD_BUF:
        if(m00_vld_rdy)
                nstate  = !head_last_buf? HEAD_VD_CN_EM_BUF : BODY_VD_CN_VD_BUF;
        else    nstate  = HEAD_VD_CN_VD_BUF;
    //-->> BODY
    BODY_EM_CN_EM_BUF:
        if(body_vld_rdy)
                nstate  = body_last? (jump_end? END_VD_CN_EM_BUF : FSH_VD_CN_EM_BUF) : BODY_VD_CN_EM_BUF;
        else    nstate  = BODY_EM_CN_EM_BUF;
    BODY_VD_CN_EM_BUF:
        case({m00_vld_rdy,body_vld_rdy})
        2'b00:  nstate  = BODY_VD_CN_EM_BUF;
        2'b10:  nstate  = BODY_EM_CN_EM_BUF;
        2'b01:  nstate  = !body_last? BODY_VD_CN_VD_BUF : (jump_end? END_VD_CN_VD_BUF : FSH_VD_CN_VD_BUF);
        2'b11:  nstate  = !body_last? BODY_VD_CN_EM_BUF : (jump_end? END_VD_CN_EM_BUF : FSH_VD_CN_EM_BUF);
        default:;
        endcase
    BODY_VD_CN_VD_BUF:
        if(m00_vld_rdy)
                nstate = !body_last_buf? BODY_VD_CN_EM_BUF : (jump_end? END_VD_CN_VD_BUF : FSH_VD_CN_VD_BUF);
        else    nstate = BODY_VD_CN_VD_BUF;
    //-->> END
    END_EM_CN_EM_BUF:
        if(end_vld_rdy)
                nstate  = end_last? FSH_VD_CN_EM_BUF : END_VD_CN_EM_BUF;
        else    nstate  = END_EM_CN_EM_BUF;
    END_VD_CN_EM_BUF:
        case({m00_vld_rdy,end_vld_rdy})
        2'b00:  nstate  = end_last? FSH_VD_CN_EM_BUF : END_VD_CN_EM_BUF;
        2'b10:  nstate  = END_EM_CN_EM_BUF;
        2'b01:  nstate  = end_last? FSH_VD_CN_VD_BUF : END_VD_CN_VD_BUF;
        2'b11:  nstate  = end_last? FSH_VD_CN_EM_BUF : END_VD_CN_EM_BUF;
        default:;
        endcase
    END_VD_CN_VD_BUF:
        if(m00_vld_rdy)
                nstate  = !end_last_buf? END_VD_CN_EM_BUF : FSH_VD_CN_EM_BUF;
        else    nstate  = END_VD_CN_VD_BUF;
    //-->> FSH
    FSH_VD_CN_EM_BUF:begin
        if(MODE=="BOTH" || MODE=="HEAD")begin
            case({m00_vld_rdy,head_vld_rdy})
            2'b00:  nstate  = FSH_VD_CN_EM_BUF;
            2'b10:  nstate  = IDLE;
            2'b01:  nstate  = !head_last? HEAD_VD_CN_VD_BUF : BODY_VD_CN_VD_BUF;
            2'b11:  nstate  = !head_last? HEAD_VD_CN_EM_BUF : BODY_VD_CN_EM_BUF;
            default:;
            endcase
        end else begin
            case({m00_vld_rdy,body_vld_rdy})
            2'b00:  nstate  = FSH_VD_CN_EM_BUF;
            2'b10:  nstate  = IDLE;
            2'b01:  nstate  = !body_last? BODY_VD_CN_VD_BUF : (jump_end? END_VD_CN_VD_BUF : FSH_VD_CN_VD_BUF);
            2'b11:  nstate  = !body_last? BODY_VD_CN_EM_BUF : (jump_end? END_VD_CN_EM_BUF : FSH_VD_CN_EM_BUF);
            default:;
            endcase
        end
    end
    FSH_VD_CN_VD_BUF:
        if(m00_vld_rdy)
                nstate  = head_last_buf? HEAD_VD_CN_EM_BUF : (body_last_buf? (jump_end? END_VD_CN_EM_BUF : FSH_VD_CN_EM_BUF) : FSH_VD_CN_EM_BUF);
        else    nstate  = FSH_VD_CN_VD_BUF;
    default:    nstate  = IDLE;
    endcase
end


//---->>  STATUS SLAVER <<----------------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  head_inf.ready   <= 1'b0;
    else begin
        case(nstate)
        HEAD_EM_CN_EM_BUF,HEAD_VD_CN_EM_BUF:
                head_inf.ready   <= 1'b1;
        IDLE,FSH_VD_CN_EM_BUF:begin
            if(MODE=="BOTH" || MODE=="HEAD")
                    head_inf.ready   <= trigger;
            else    head_inf.ready   <= 1'b0;
        end
        default:head_inf.ready   <= 1'b0;
        endcase
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  body_inf.ready   <= 1'b0;
    else begin
        case(nstate)
        BODY_EM_CN_EM_BUF,BODY_VD_CN_EM_BUF:
                body_inf.ready   <= 1'b1;
        IDLE,FSH_VD_CN_EM_BUF:
            if(MODE=="END")
                    body_inf.ready   <= trigger;
            else    body_inf.ready   <= 1'b0;
        default:    body_inf.ready   <= 1'b0;
        endcase
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  end_inf.ready   <= 1'b0;
    else begin
        case(nstate)
        END_EM_CN_EM_BUF,END_VD_CN_EM_BUF:
                // end_inf.ready   <= trigger;
                end_inf.ready   <= 1'b1;
        default:end_inf.ready   <= 1'b0;
        endcase
    end

//----<<  STATUS SLAVER >>----------------------------------
//---->>  STATUS MASTER <<----------------------------------
always@(posedge clock,negedge rst_n)begin
    if(~rst_n)  m00.valid   <= 1'b0;
    else begin
        case(nstate)
        HEAD_VD_CN_EM_BUF,BODY_VD_CN_EM_BUF,END_VD_CN_EM_BUF,FSH_VD_CN_EM_BUF:
                m00.valid   <= 1'b1;
        HEAD_VD_CN_VD_BUF,BODY_VD_CN_VD_BUF,END_VD_CN_VD_BUF,FSH_VD_CN_VD_BUF:
                m00.valid   <= 1'b1;
        default:m00.valid   <= 1'b0;
        endcase
    end
end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  m00.data   <= '0;
    else begin
        case(nstate)
        HEAD_VD_CN_EM_BUF:
            if(buffer_vld)
                    m00.data   <= buffer_data;
            else    m00.data   <= head_vld_rdy? head_inf.data : m00.data;
        BODY_VD_CN_EM_BUF:
            if(head_vld_rdy_last)
                    m00.data    <= head_inf.data;
            else if(body_vld_rdy)
                    m00.data    <= body_inf.data;
            else if(buffer_vld)
                    m00.data    <= buffer_data;
            else    m00.data    <= m00.data;
        END_VD_CN_EM_BUF:
            if(body_vld_rdy_last)
                    m00.data    <= body_inf.data;
            else if(end_vld_rdy)
                    m00.data    <= end_inf.data;
            else if(buffer_vld)
                    m00.data    <= buffer_data;
            else    m00.data    <= m00.data;
        FSH_VD_CN_EM_BUF:
            if(body_vld_rdy_last)
                    m00.data    <= body_inf.data;
            else if(end_vld_rdy_last)
                    m00.data    <= end_inf.data;
            else if(buffer_vld)
                    m00.data    <= buffer_data;
            else    m00.data    <= m00.data;
        IDLE:       m00.data    <= m00.data;
        default:;
        endcase
    end
//----<<  STATUS MASTER >>----------------------------------
//---->>  STATUS BUFFER <<----------------------------------

always@(posedge clock,negedge rst_n)
    if(~rst_n)  buffer_data <= '0;
    else begin
        case(nstate)
        HEAD_VD_CN_VD_BUF:
                buffer_data <= head_vld_rdy? head_inf.data : buffer_data;
        BODY_VD_CN_VD_BUF:
            if(head_vld_rdy_last)
                    buffer_data <= head_inf.data;
            else    buffer_data <= body_vld_rdy? body_inf.data : buffer_data;
        END_VD_CN_VD_BUF:
            if(body_vld_rdy_last)
                    buffer_data <= body_inf.data;
            else    buffer_data <= end_vld_rdy? end_inf.data : buffer_data;
        FSH_VD_CN_VD_BUF:
            if(body_vld_rdy_last)
                    buffer_data <= body_inf.data;
            else    buffer_data <= end_vld_rdy? end_inf.data : buffer_data;
        default:    buffer_data <= '0;
        endcase
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  buffer_vld  <= '0;
    else begin
        case(nstate)
        HEAD_VD_CN_VD_BUF,BODY_VD_CN_VD_BUF,END_VD_CN_VD_BUF,FSH_VD_CN_VD_BUF:
                buffer_vld  <= 1'b1;
        default:buffer_vld  <= 1'b0;
        endcase
    end


always@(posedge clock,negedge rst_n)
    if(~rst_n)begin
      head_last_buf <= '0;
    end else begin
        case(nstate)
        HEAD_VD_CN_VD_BUF,BODY_VD_CN_VD_BUF:
                head_last_buf <= head_vld_rdy? head_last : head_last_buf;
        default:    head_last_buf <= 1'b0;
        endcase
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)begin
      body_last_buf <= '0;
    end else begin
        case(nstate)
        BODY_VD_CN_VD_BUF,END_VD_CN_VD_BUF,FSH_VD_CN_VD_BUF:
            body_last_buf <= body_vld_rdy? body_last : body_last_buf;
        default:    body_last_buf <= 1'b0;
        endcase
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)begin
      end_last_buf  <= '0;
    end else begin
        case(nstate)
        END_VD_CN_VD_BUF,FSH_VD_CN_VD_BUF:
            end_last_buf    <= end_vld_rdy? end_last : end_last_buf;
        default:    end_last_buf  <= 1'b0;
        endcase
    end
//----<<  STATUS BUFFER >>----------------------------------
endmodule
