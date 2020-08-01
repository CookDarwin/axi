/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
created: 2020-01-17 12:18:32 +0800
madified:
***********************************************/
`timescale 1ns/1ps

module data_c_intc_M2S_force_robin#(
    parameter  NUM = 8
)(
    data_inf_c.slaver s00 [NUM-1:0],
    data_inf_c.master m00
);

//==========================================================================
//-------- define ----------------------------------------------------------
logic  clock;
logic  rst_n;
logic [$clog2(NUM)-1:0]  robin_index ;
logic [$clog2(NUM)-1:0]  next_robin_index ;
logic from_up_vld;
logic to_up_ready;
logic [m00.DSIZE-1:0]  from_up_data ;
logic [1-1:0]  s00_valid[NUM-1:0] ;
logic [1-1:0]  s00_ready[NUM-1:0] ;
logic [s00[0].DSIZE-1:0]  s00_data[NUM-1:0] ;
logic [m00.DSIZE-1:0]  buffer_data ;
logic buffer_vld;
logic main_ready;
logic [NUM-1:0]  to_up_ready_array ;
//==========================================================================
//-------- instance --------------------------------------------------------

//==========================================================================
//-------- expression ------------------------------------------------------
enum { 
    IDLE,
    EM_CN_EM_BUF,
    VD_CN_EM_BUF,
    VD_CN_ST_BUF,
    VD_CN_CL_BUF
} CSTATE_mainS,NSTATE_mainS;

generate
for(genvar KK0=0;KK0 < NUM;KK0++)begin
    assign  s00_ready[KK0] = ( to_up_ready_array[KK0]&main_ready);
end
endgenerate

generate
for(genvar KK0=0;KK0<NUM;KK0++)begin
    assign s00_valid[KK0] = s00[KK0].valid;
end
endgenerate

generate
for(genvar KK0=0;KK0<NUM;KK0++)begin
    assign s00[KK0].ready = s00_ready[KK0];
end
endgenerate

generate
for(genvar KK0=0;KK0<NUM;KK0++)begin
    assign s00_data[KK0] = s00[KK0].data;
end
endgenerate
assign  from_up_vld = s00_valid[robin_index];
assign  to_up_ready = s00_ready[robin_index];
assign  from_up_data = s00_data[robin_index];

assign  clock = m00.clock;
assign  rst_n = m00.rst_n;

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         robin_index <= '0;
    end
    else begin
        if( from_up_vld&to_up_ready)begin
            if( robin_index>=NUM-1)begin
                 robin_index <= '0;
            end
            else begin
                 robin_index <= ( robin_index+1'b1);
            end
        end
        else begin
             robin_index <= robin_index;
        end
    end
end

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         next_robin_index <= ( '0+1'b1);
    end
    else begin
        if( from_up_vld&to_up_ready)begin
            if( next_robin_index>=NUM-1)begin
                 next_robin_index <= '0;
            end
            else begin
                 next_robin_index <= ( next_robin_index+1'b1);
            end
        end
        else begin
             next_robin_index <= next_robin_index;
        end
    end
end

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         CSTATE_mainS <= IDLE;
    end
    else begin
         CSTATE_mainS <= NSTATE_mainS;
    end
end

always_comb begin 
    case(CSTATE_mainS) 
        IDLE:begin 
             NSTATE_mainS = EM_CN_EM_BUF;
        end
        EM_CN_EM_BUF:begin 
            if( from_up_vld&to_up_ready)begin
                 NSTATE_mainS = VD_CN_EM_BUF;
            end
            else begin
                 NSTATE_mainS = EM_CN_EM_BUF;
            end
        end
        VD_CN_EM_BUF:begin 
            if( from_up_vld&to_up_ready)begin
                if(m00.vld_rdy)begin
                     NSTATE_mainS = VD_CN_EM_BUF;
                end
                else begin
                     NSTATE_mainS = VD_CN_ST_BUF;
                end
            end
            else begin
                if(m00.vld_rdy)begin
                     NSTATE_mainS = EM_CN_EM_BUF;
                end
                else begin
                     NSTATE_mainS = VD_CN_EM_BUF;
                end
            end
        end
        VD_CN_ST_BUF:begin 
            if(m00.vld_rdy)begin
                 NSTATE_mainS = VD_CN_EM_BUF;
            end
            else begin
                 NSTATE_mainS = VD_CN_ST_BUF;
            end
        end
        default:begin 
             NSTATE_mainS = IDLE;
        end
    endcase
end

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         m00.valid <= 1'b0;
    end
    else begin
        case(NSTATE_mainS) 
            VD_CN_EM_BUF,VD_CN_ST_BUF:begin 
                 m00.valid <= 1'b1;
            end
            default:begin 
                 m00.valid <= 1'b0;
            end
        endcase
    end
end

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         m00.data <= '0;
    end
    else begin
        case(NSTATE_mainS) 
            VD_CN_EM_BUF:begin 
                if(buffer_vld)begin
                     m00.data <= buffer_data;
                end
                else if( from_up_vld&to_up_ready)begin
                     m00.data <= from_up_data;
                end
                else begin
                     m00.data <= m00.data;
                end
            end
            VD_CN_ST_BUF:begin 
                if(m00.vld_rdy)begin
                     m00.data <= buffer_data;
                end
                else begin
                     m00.data <= m00.data;
                end
            end
        endcase
    end
end

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         buffer_data <= '0;
    end
    else begin
        case(NSTATE_mainS) 
            VD_CN_ST_BUF:begin 
                if( from_up_vld&to_up_ready)begin
                     buffer_data <= from_up_data;
                end
                else begin
                     buffer_data <= buffer_data;
                end
            end
            default:begin 
                 buffer_data <= '0;
            end
        endcase
    end
end

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         buffer_vld <= '0;
    end
    else begin
        case(NSTATE_mainS) 
            VD_CN_ST_BUF:begin 
                if( from_up_vld&to_up_ready)begin
                     buffer_vld <= 1'b1;
                end
                else begin
                     buffer_vld <= buffer_vld;
                end
            end
            default:begin 
                 buffer_vld <= 1'b0;
            end
        endcase
    end
end

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         main_ready <= 1'b0;
    end
    else begin
        case(NSTATE_mainS) 
            EM_CN_EM_BUF,VD_CN_EM_BUF:begin 
                 main_ready <= 1'b1;
            end
            VD_CN_ST_BUF:begin 
                if(m00.vld_rdy)begin
                     main_ready <= 1'b1;
                end
                else begin
                     main_ready <= 1'b0;
                end
            end
            default:begin 
                 main_ready <= 1'b0;
            end
        endcase
    end
end

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         to_up_ready_array <= '0;
    end
    else begin
        if( CSTATE_mainS==IDLE)begin
             to_up_ready_array <= '0;
             to_up_ready_array[robin_index] <= 1'b1;
        end
        else if( from_up_vld&to_up_ready)begin
             to_up_ready_array <= '0;
             to_up_ready_array[next_robin_index] <= 1'b1;
        end
        else begin
             to_up_ready_array <= to_up_ready_array;
        end
    end
end

endmodule
