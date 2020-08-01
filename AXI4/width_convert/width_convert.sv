/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2016/11/21 
madified:
***********************************************/
`timescale 1ns/1ps
module width_convert #(
    parameter   ISIZE   = 8,
    parameter   OSIZE   = 8
)(
    input                           clock,
    input                           rst_n,
    input [ISIZE-1:0]               wr_data,
    input                           wr_vld,
    output logic                    wr_ready,
    input                           wr_last,
    input                           wr_align_last,      //can be leave 1'b0
    output logic[OSIZE-1:0]         rd_data,
    output logic                    rd_vld,
    input                           rd_ready,
    output                          rd_last
);

initial begin
    if(ISIZE>OSIZE)begin
        if(ISIZE%OSIZE)
            $error("ISIZE OSIZE ERROR ISIZE=%d,OSIZE=%d",ISIZE,OSIZE);
    end else begin
        if(OSIZE%ISIZE)
            $error("ISIZE OSIZE ERROR ISIZE=%d,OSIZE=%d",ISIZE,OSIZE);
    end
end

localparam REAL_DST_NSIZE = ISIZE/OSIZE + (ISIZE%OSIZE != 0);
localparam REAL_CBN_NSIZE = OSIZE/ISIZE;
generate
if(ISIZE > OSIZE)begin
width_destruct #(
    .DSIZE      (OSIZE          ),
    .NSIZE      (ISIZE/OSIZE    )
    // .NSIZE      (REAL_DST_NSIZE    )
)width_destruct_inst(
/*  input                    */       .clock        (clock        ),
/*  input                    */       .rst_n        (rst_n        ),
/*  input [DSIZE*NSIZE-1:0]  */       .wr_data      (wr_data      ),        //it maybe match bit width
/*  input                    */       .wr_vld       (wr_vld       ),
/*  output logic             */       .wr_ready     (wr_ready     ),
/*  input                    */       .wr_last      (wr_last      ),
/*  output logic[DSIZE-1:0]  */       .rd_data      (rd_data      ),
/*  output logic             */       .rd_vld       (rd_vld       ),
/*  output logic             */       .rd_last      (rd_last      ),
/*  input                    */       .rd_ready     (rd_ready     )
);
end else if(ISIZE<OSIZE)begin
width_combin #(
    .DSIZE  (ISIZE      ),
    .NSIZE  (OSIZE/ISIZE)
    // .NSIZE  (REAL_CBN_NSIZE)
)width_combin_inst(
/*   input                        */   .clock             (clock         ),
/*   input                        */   .rst_n             (rst_n         ),
/*   input [DSIZE-1:0]            */   .wr_data           (wr_data       ),
/*   input                        */   .wr_vld            (wr_vld        ),
/*   output logic                 */   .wr_ready          (wr_ready      ),
/*   input                        */   .wr_last           (wr_last       ),
/*   input                        */   .wr_align_last     (wr_align_last ),
/*   output logic[DSIZE*NSIZE-1:0]*/   .rd_data           (rd_data       ),     //it maybe match bit width
/*   output logic                 */   .rd_vld            (rd_vld        ),
/*   input                        */   .rd_ready          (rd_ready      ),
/*   output                       */   .rd_last           (rd_last       )
);
end else begin

assign    wr_ready  = rd_ready;
assign    rd_data   = wr_data;
assign    rd_vld    = wr_vld;
assign    rd_last   = wr_last;

end
endgenerate

endmodule
