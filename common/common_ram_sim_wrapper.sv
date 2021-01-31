/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
created: xxxx.xx.xx
madified:
***********************************************/
`timescale 1ns/1ps

module common_ram_sim_wrapper #(
    parameter  FNUM = 8
)(
    input [ FNUM-1:0]   load_files,
    input [4095:0]      init_files [FNUM-1:0],
    cm_ram_inf.slaver   ram_inf
);

//------>> EX CODE <<-------------------
import SystemPkg::*;//------<< EX CODE >>-------------------

//==========================================================================
//-------- define ----------------------------------------------------------
logic [12-1:0]  addra ;
logic [ram_inf.DSIZE-1:0]  dina ;
logic [ram_inf.DSIZE-1:0]  douta ;
logic [12-1:0]  addrb ;
logic [ram_inf.DSIZE-1:0]  dinb ;
logic [ram_inf.DSIZE-1:0]  doutb ;

//==========================================================================
//-------- instance --------------------------------------------------------
xilinx_hdl_dpram_sim #(
    .NB_COL          ($bits(dina) / 9 + ($bits(dina)%9 != 0) ),
    .COL_WIDTH       (9                                      ),
    .RAM_DEPTH       (2**$bits(addra)                        ),
    .FNUM            (FNUM                                   )
)xilinx_hdl_dpram_sim_inst(
/* input  */.load_files (load_files       ),
/* input  */.init_files (init_files       ),
/* input  */.addra      (addra            ),
/* input  */.addrb      (addrb            ),
/* input  */.dina       (dina             ),
/* input  */.dinb       (dinb             ),
/* input  */.clka       (ram_inf.clka     ),
/* input  */.clkb       (ram_inf.clkb     ),
/* input  */.wea        ({4{ram_inf.wea}} ),
/* input  */.web        ({4{ram_inf.web}} ),
/* input  */.ena        (1'b1             ),
/* input  */.enb        (1'b1             ),
/* input  */.rsta       (ram_inf.rsta     ),
/* input  */.rstb       (ram_inf.rstb     ),
/* input  */.regcea     (1'b1             ),
/* input  */.regceb     (1'b1             ),
/* output */.douta      (douta            ),
/* output */.doutb      (doutb            )
);
//==========================================================================
//-------- expression ------------------------------------------------------
assign  addra = ram_inf.addra;
assign  dina = ram_inf.dia;
assign  addrb = ram_inf.addrb;
assign  dinb = ram_inf.dib;

always_ff@(posedge ram_inf.clka) begin 
     ram_inf.doa <= douta[ ram_inf.DSIZE-1:0];
end

always_ff@(posedge ram_inf.clkb) begin 
     ram_inf.dob <= doutb[ ram_inf.DSIZE-1:0];
end

endmodule
