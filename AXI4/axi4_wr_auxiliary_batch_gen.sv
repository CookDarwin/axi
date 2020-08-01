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
module axi4_wr_auxiliary_batch_gen (
    axi_stream_inf.slaver       id_add_len_in,      //tlast is not necessary
    axi_inf.master_wr_aux       axi_wr_aux,
    output [2:0]                pend_id,
    output                      pend_en
);

logic       clock,rst_n;
assign  clock   = axi_wr_aux.axi_aclk;
assign  rst_n   = axi_wr_aux.axi_aresetn;

logic [axi_wr_aux.ASIZE-1:0]    addr;
logic [axi_wr_aux.IDSIZE-1:0]   id;
logic [axi_wr_aux.LSIZE-1:0]    length;

logic       fifo_full;
logic       fifo_empty;
logic       fifo_rd_en;
logic       force_rd_en;

common_fifo #(
    .DEPTH      (4  ),
    .DSIZE      (axi_wr_aux.IDSIZE+axi_wr_aux.ASIZE+axi_wr_aux.LSIZE)
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

assign fifo_rd_en    = (axi_wr_aux.axi_wvalid && axi_wr_aux.axi_wready && axi_wr_aux.axi_wlast) || force_rd_en;

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
/*    input                 */  .set_vld        ((axi_wr_aux.axi_awvalid && axi_wr_aux.axi_awready)   ),
/*    input [IDSIZE-1:0]    */  .clear_id       (axi_wr_aux.axi_bid     ),
/*    input                 */  .clear_vld      ((axi_wr_aux.axi_bvalid && axi_wr_aux.axi_bready)     ),
/*    input [IDSIZE-1:0]    */  .read_id        (id                 ),
/*    input                 */  .read_en        (id_record_read_en  ),
/*    output logic          */  .result         (id_chk_rel         ),
/*    output logic          */  .full           (id_record_full     )
);

typedef enum {IDLE,CHECK_ID,RESULT,SET_AW,CLEAR_FIFO_BYTE,LAST_BYTE} STATUS;

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
                nstate  = SET_AW;
        else    nstate  = CLEAR_FIFO_BYTE;
    CLEAR_FIFO_BYTE:
                nstate  = IDLE;
    SET_AW:
        if(axi_wr_aux.axi_awvalid && axi_wr_aux.axi_awready)
                nstate  = LAST_BYTE;
        else    nstate  = SET_AW;
    LAST_BYTE:
        if(axi_wr_aux.axi_wvalid && axi_wr_aux.axi_wready && axi_wr_aux.axi_wlast)
                nstate  = IDLE;
        else    nstate  = LAST_BYTE;
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
    if(~rst_n)  axi_wr_aux.axi_awvalid   <= 1'b0;
    else begin
        case(nstate)
        SET_AW:
                axi_wr_aux.axi_awvalid   <= 1'b1;
        default:axi_wr_aux.axi_awvalid   <= 1'b0;
        endcase
    end


assign axi_wr_aux.axi_bready    = 1'b1;

assign pend_id  = id;
assign pend_en  = force_rd_en;

endmodule
