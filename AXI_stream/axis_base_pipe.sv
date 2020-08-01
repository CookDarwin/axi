/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
    dont use child module
creaded: 2019/1/8 
madified:
***********************************************/
`timescale 1ns/1ps
module axis_base_pipe (
    output logic               empty,
    (* up_stream = "true" *)
    axi_stream_inf.slaver      axis_in,
    (* down_stream = "true" *)
    axi_stream_inf.master      axis_out
);



logic   clock,rst_n;
assign  clock = axis_in.aclk;
assign  rst_n = axis_in.aresetn;

logic   slaver_vld_rdy;
logic   master_vld_rdy;

assign  slaver_vld_rdy = axis_in.axis_tvalid && axis_in.axis_tready;
assign  master_vld_rdy = axis_out.axis_tvalid && axis_out.axis_tready;

logic [axis_out.DSIZE-1:0]      buffer_data;
logic                           buffer_vld;
logic                           buffer_last;

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
    if(~rst_n)  axis_in.axis_tready    <= 1'b0;
    else begin
        case(nstate)
        IDLE,VD_CN_EM_BUF:
                axis_in.axis_tready    <= 1'b1;
        default:axis_in.axis_tready    <= 1'b0;
        endcase
    end
//---<< SLAVER >>---------------------------
//--->> MASTER <<---------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_out.axis_tvalid    <= 1'b0;
    else begin
        case(nstate)
        VD_CN_EM_BUF,VD_CN_VD_BUF:
                axis_out.axis_tvalid    <= 1'b1;
        default:axis_out.axis_tvalid    <= 1'b0;
        endcase
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_out.axis_tdata     <= '0;
    else begin
        case(nstate)
        IDLE:   axis_out.axis_tdata     <= '0;
        VD_CN_EM_BUF:
            if(buffer_vld)
                    axis_out.axis_tdata <= buffer_data;
            else if(slaver_vld_rdy)
                    axis_out.axis_tdata <= axis_in.axis_tdata;
            else    axis_out.axis_tdata <= axis_out.axis_tdata;
        default:;
        endcase
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_out.axis_tlast     <= '0;
    else begin
        case(nstate)
        IDLE:   axis_out.axis_tlast     <= '0;
        VD_CN_EM_BUF:
            if(buffer_vld)
                    axis_out.axis_tlast <= buffer_last;
            else if(slaver_vld_rdy)
                    axis_out.axis_tlast <= axis_in.axis_tlast;
            else if(master_vld_rdy)
                    axis_out.axis_tlast <= '0;
            else    axis_out.axis_tlast <= axis_out.axis_tlast;
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
                    buffer_data <= axis_in.axis_tdata;
            else    buffer_data <= buffer_data;
        default:    buffer_data <= '0;
        endcase
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  buffer_last <= '0;
    else begin
        case(nstate)
        VD_CN_VD_BUF:
            if(slaver_vld_rdy)
                    buffer_last <= axis_in.axis_tlast;
            else    buffer_last <= buffer_last;
        default:    buffer_last <= '0;
        endcase
    end
//---<< BUFFER >>---------------------------
//--->> EMPTY FLAG <<-----------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  empty     <= '1;
    else begin
        case(nstate)
        // IDLE:   empty     <= '1;
        IDLE:begin
            if(master_vld_rdy && axis_out.axis_tlast)
                    empty   <= 1'b1;
            else    empty   <= empty;
        end
        VD_CN_EM_BUF:begin
            if(master_vld_rdy && axis_out.axis_tlast)
                    empty   <= 1'b1;
            else    empty   <= 1'b0;
        end
        VD_CN_VD_BUF:
                empty    <= 1'b0;
        default:;
        endcase
    end
//---<< EMPTY FLAG >>-----------------------
endmodule
