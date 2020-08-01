/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.1.0
    user axis_tuser
creaded: 2017/9/13 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_width_destruct_A1 (
    (* up_stream = "true" *)
    axi_stream_inf.slaver   wide_axis,
    (* down_stream = "true" *)
    axi_stream_inf.master   slim_axis
);

`define NSIZE wide_axis.DSIZE/slim_axis.DSIZE

initial begin
    assert(wide_axis.DSIZE%slim_axis.DSIZE == 0)
    else $error("Axi Stream Width Destruct Error, wide_axis.DSIZE %% slim_axis.DSIZE != 0!!");

    assert(wide_axis.DSIZE>slim_axis.DSIZE)
    else $error("Axi Stream Width Destruct Error, wide_axis.DSIZE should be larger than slim_axis.DSIZE !!!");

    assert(slim_axis.DSIZE >= 8 && slim_axis.DSIZE%8 ==0)
    else $error("Axi Stream Width Destruct Error, slim_axis.DSIZE should be larger than 7 && multiper 8");
end

logic [wide_axis.DSIZE+wide_axis.KSIZE-1:0] indata;
logic [slim_axis.DSIZE+slim_axis.KSIZE-1:0] outdata;


always_comb begin
int CC;
    for(CC=0;CC<wide_axis.KSIZE;CC++)
        indata[(1+8)*CC+:(1+8)] = {wide_axis.axis_tkeep[CC],wide_axis.axis_tdata[CC*8+:8]};
end

always_comb begin
int CC;
    for(CC=0;CC<slim_axis.KSIZE;CC++)
        {slim_axis.axis_tkeep[CC],slim_axis.axis_tdata[CC*8+:8]} = outdata[(1+8)*CC+:(1+8)];
end


// data_destruct #(
//     .IDSIZE     (wide_axis.DSIZE+wide_axis.KSIZE    ),
//     .ODSIZE     (slim_axis.DSIZE+slim_axis.KSIZE    )
// )data_destruct_inst(
// /*  input                    */   .clock        (wide_axis.aclk         ),
// /*  input                    */   .rst_n        (wide_axis.aresetn      ),
// /*  input [IDSIZE-1:0]       */   .indata       (indata                 ),
// /*  input                    */   .invalid      (wide_axis.axis_tvalid  ),
// /*  output logic             */   .inready      (wide_axis.axis_tready  ),
// /*  input                    */   .inlast       (wide_axis.axis_tlast   ),
// /*  output logic[ODSIZE-1:0] */   .outdata      (outdata                ),
// /*  output logic             */   .outvalid     (slim_axis.axis_tvalid  ),
// /*  input                    */   .outready     (slim_axis.axis_tready  ),
// /*  output logic             */   .outlast      (slim_axis.axis_tlast   )
// );

width_destruct_A1 #(
    .DSIZE  (slim_axis.DSIZE+slim_axis.KSIZE),
    .NSIZE  (`NSIZE                         ),
    .USIZE  (1                              )
)width_destruct_inst(
/*  input                    */       .clock        (wide_axis.aclk         ),
/*  input                    */       .rst_n        (wide_axis.aresetn      ),
/*  input [DSIZE*NSIZE-1:0]  */       .wr_data      (indata                 ),
/*  input                    */       .wr_vld       (wide_axis.axis_tvalid  ),
/*  output logic             */       .wr_ready     (wide_axis.axis_tready  ),
/*  input                    */       .wr_last      (wide_axis.axis_tlast   ),
/*  input [USIZE-1:0]        */       .wr_user      (wide_axis.axis_tuser   ),
/*  output logic[DSIZE-1:0]  */       .rd_data      (outdata                ),
/*  output logic             */       .rd_vld       (slim_axis.axis_tvalid  ),
/*  output logic             */       .rd_last      (slim_axis.axis_tlast   ),
/*  output logic[USIZE-1:0]  */       .rd_user      (slim_axis.axis_tuser   ),
/*  input                    */       .rd_ready     (slim_axis.axis_tready  )
);

endmodule
