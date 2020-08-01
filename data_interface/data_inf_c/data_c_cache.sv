/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018-5-3 14:44:14
madified:
***********************************************/
`timescale 1ns/1ps
(* data_inf_c = "true" *)
module data_c_cache (
    (* data_up = "true" *)
    data_inf_c.slaver     data_in,
    (* data_down = "true" *)
    data_inf_c.master     data_out    //
);

initial begin
    assert(data_in.DSIZE == data_out.DSIZE)
    else begin
        $error("`data_c_cache` IN DSIZE[%d] dont eql OUT DSIZE[%d]",data_in.DSIZE,data_out.DSIZE);
        $stop;
    end
end

logic   fifo_empty,fifo_full;

independent_clock_fifo #(
    .DEPTH  (4  ),
    .DSIZE  (data_in.DSIZE  )
)independent_clock_fifo_inst(
/*  input                    */   .wr_clk       (data_in.clock  ),
/*  input                    */   .wr_rst_n     (data_in.rst_n  ),
/*  input                    */   .rd_clk       (data_out.clock ),
/*  input                    */   .rd_rst_n     (data_out.rst_n ),
/*  input [DSIZE-1:0]        */   .wdata        (data_in.data   ),
/*  input                    */   .wr_en        (data_in.valid && data_in.ready     ),
/*  output logic[DSIZE-1:0]  */   .rdata        (data_out.data  ),
/*  input                    */   .rd_en        (data_out.valid && data_out.ready   ),
/*  output logic             */   .empty        (fifo_empty     ),
/*  output logic             */   .full         (fifo_full      )
);

assign  data_out.valid  = ~fifo_empty;
assign  data_in.ready   = ~fifo_full;

endmodule
