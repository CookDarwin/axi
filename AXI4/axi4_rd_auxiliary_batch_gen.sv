/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    it burst next ,and dont need to wait current be responed
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/1 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_rd_auxiliary_batch_gen (
    axi_stream_inf.slaver       id_add_len_in,      //tlast is not necessary
    axi_inf.master_rd_aux       axi_rd_aux,
    output [2:0]                pend_id,
    output                      pend_en
);

logic       clock,rst_n;
assign  clock   = axi_rd_aux.axi_aclk;
assign  rst_n   = axi_rd_aux.axi_aresetn;

logic [axi_rd_aux.ASIZE-1:0]    addr;
logic [axi_rd_aux.IDSIZE-1:0]   id;
logic [axi_rd_aux.LSIZE-1:0]    length;

logic       fifo_full;
logic       fifo_empty;
logic       fifo_rd_en;
logic       force_rd_en;

common_fifo #(
    .DEPTH      (4  ),
    .DSIZE      (axi_rd_aux.IDSIZE+axi_rd_aux.ASIZE+axi_rd_aux.LSIZE)
)common_fifo_inst(
/*    input                     */  .clock          (clock          ),
/*    input                     */  .rst_n          (rst_n          ),
/*    input [DSIZE-1:0]         */  .wdata          (id_add_len_in.axis_tdata   ),
/*    input                     */  .wr_en          (id_add_len_in.axis_tvalid  ),
/*    output logic[DSIZE-1:0]   */  .rdata          ({id,addr,length}           ),
/*    input                     */  .rd_en          (fifo_rd_en                 ),
/*    output logic[CSIZE-1:0]   */  .count          (                           ),
/*    output logic              */  .empty          (fifo_empty                 ),
/*    output logic              */  .full           (fifo_full                  )
);

assign fifo_rd_en    = (axi_rd_aux.axi_arvalid && axi_rd_aux.axi_arready) || force_rd_en;

assign id_add_len_in.axis_tready    = !fifo_full;

logic       id_chk_rel;
logic       id_record_full;
logic       id_record_read_en;

id_record #(
    .LEN        (8      )
)id_record_inst(
/*    input                 */  .clock          (clock          ),
/*    input                 */  .rst_n          (rst_n          ),
/*    input [IDSIZE-1:0]    */  .set_id         (id             ),
/*    input                 */  .set_vld        ((axi_rd_aux.axi_arvalid && axi_rd_aux.axi_arready)   ),
/*    input [IDSIZE-1:0]    */  .clear_id       (axi_rd_aux.axi_rid     ),
/*    input                 */  .clear_vld      ((axi_rd_aux.axi_rvalid && axi_rd_aux.axi_rready && axi_rd_aux.axi_rlast)     ),
/*    input [IDSIZE-1:0]    */  .read_id        (id                 ),
/*    input                 */  .read_en        (id_record_read_en  ),
/*    output logic          */  .result         (id_chk_rel         ),
/*    output logic          */  .full           (id_record_full     )
);

typedef enum {IDLE,CHECK_ID,RESULT,SET_AR,CLEAR_FIFO_BYTE} STATUS;

STATUS nstate,cstate;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cstate  = IDLE;
    else        cstate  = nstate;

always_comb begin
    case(cstate)
    IDLE:
        if(!fifo_empty && !id_record_full)
                nstate  = CHECK_ID;
        else    nstate  = IDLE;
    CHECK_ID:   nstate  = RESULT;
    RESULT:
        if(!id_chk_rel)
                nstate  = SET_AR;
        else    nstate  = CLEAR_FIFO_BYTE;
    CLEAR_FIFO_BYTE:
                nstate  = IDLE;
    SET_AR:
        if(axi_rd_aux.axi_arvalid && axi_rd_aux.axi_arready)
                nstate  = IDLE;
        else    nstate  = SET_AR;
    default:    nstate  = IDLE;
    endcase
end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  id_record_read_en   <= 1'b0;
    else begin
        case(nstate)
        CHECK_ID:
                id_record_read_en   <= 1'b1;
        default:id_record_read_en   <= 1'b0;
        endcase
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  force_rd_en   <= 1'b0;
    else begin
        case(nstate)
        CLEAR_FIFO_BYTE:
                force_rd_en   <= 1'b1;
        default:force_rd_en   <= 1'b0;
        endcase
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axi_rd_aux.axi_arvalid   <= 1'b0;
    else begin
        case(nstate)
        SET_AR:
                axi_rd_aux.axi_arvalid   <= 1'b1;
        default:axi_rd_aux.axi_arvalid   <= 1'b0;
        endcase
    end


assign pend_id  = id;
assign pend_en  = force_rd_en;

endmodule
