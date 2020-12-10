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
`include "define_macro.sv" 

module axis_rom_contect #(
    `parameter_longstring(256) INIT_FILE = "template.coe",
    parameter  STEP      = 1
)(
    axi_stream_inf.slaver   a_axis_zip,
    axi_stream_inf.slaver   b_axis_zip,
    axi_stream_inf.master   a_rom_contect_inf,
    axi_stream_inf.master   b_rom_contect_inf
);

//==========================================================================
//-------- define ----------------------------------------------------------

axi_stream_inf #(.DSIZE( a_axis_zip.DSIZE/2),.USIZE(1)) a_axis_unzip (.aclk(a_axis_zip.aclk),.aresetn(a_axis_zip.aresetn),.aclken(1'b1)) ;
axi_stream_inf #(.DSIZE( b_axis_zip.DSIZE/2),.USIZE(1)) b_axis_unzip (.aclk(b_axis_zip.aclk),.aresetn(b_axis_zip.aresetn),.aclken(1'b1)) ;
cm_ram_inf #(.DSIZE(a_rom_contect_inf.DSIZE),.RSIZE(a_axis_zip.DSIZE),.MSIZE(1)) xram_inf();
axi_stream_inf #(.DSIZE(a_rom_contect_inf.DSIZE+ a_axis_zip.DSIZE/2),.USIZE(1)) a_rom_contect_inf_pre (.aclk(a_rom_contect_inf.aclk),.aresetn(a_rom_contect_inf.aresetn),.aclken(1'b1)) ;
axi_stream_inf #(.DSIZE(b_rom_contect_inf.DSIZE+ b_axis_zip.DSIZE/2),.USIZE(1)) b_rom_contect_inf_pre (.aclk(b_rom_contect_inf.aclk),.aresetn(b_rom_contect_inf.aresetn),.aclken(1'b1)) ;
//==========================================================================
//-------- instance --------------------------------------------------------
axis_uncompress_verb #(
    .ASIZE ( a_axis_zip.DSIZE/2 ),
    .LSIZE ( a_axis_zip.DSIZE/2 ),
    .STEP  (STEP                )
)axis_uncompress_verb_ainst(
/* axi_stream_inf.slaver */.axis_zip   (a_axis_zip   ),
/* axi_stream_inf.master */.axis_unzip (a_axis_unzip )
);
axis_uncompress_verb #(
    .ASIZE ( a_axis_zip.DSIZE/2 ),
    .LSIZE ( a_axis_zip.DSIZE/2 ),
    .STEP  (STEP                )
)axis_uncompress_verb_binst(
/* axi_stream_inf.slaver */.axis_zip   (b_axis_zip   ),
/* axi_stream_inf.master */.axis_unzip (b_axis_unzip )
);
common_ram_wrapper #(
    .INIT_FILE (INIT_FILE )
)common_ram_wrapper_inst(
/* cm_ram_inf.slaver */.ram_inf (xram_inf )
);
axi_stream_planer #(
    .LAT   (3                       ),
    .DSIZE (a_rom_contect_inf.DSIZE ),
    .HEAD  ("FALSE"                 )
)axi_stream_planer_ainst(
/* input                 */.reset     (~a_axis_zip.aresetn   ),
/* input                 */.pack_data (xram_inf.doa          ),
/* axi_stream_inf.slaver */.axis_in   (a_axis_unzip          ),
/* axi_stream_inf.master */.axis_out  (a_rom_contect_inf_pre )
);
axi_stream_planer #(
    .LAT   (3                       ),
    .DSIZE (b_rom_contect_inf.DSIZE ),
    .HEAD  ("FALSE"                 )
)axi_stream_planer_binst(
/* input                 */.reset     (~b_axis_zip.aresetn   ),
/* input                 */.pack_data (xram_inf.dob          ),
/* axi_stream_inf.slaver */.axis_in   (b_axis_unzip          ),
/* axi_stream_inf.master */.axis_out  (b_rom_contect_inf_pre )
);
//==========================================================================
//-------- expression ------------------------------------------------------
initial begin
    assert( a_axis_zip.DSIZE==b_axis_zip.DSIZE)else begin
         $error("a_axis_zip.DSIZE<%0d> must equal b_axis_zip.DSIZE<%0d>",a_axis_zip.DSIZE,b_axis_zip.DSIZE);
         $stop;
    end
    assert( a_rom_contect_inf.DSIZE==b_rom_contect_inf.DSIZE)else begin
         $error("a_rom_contect_inf.DSIZE<%0d>==b_rom_contect_inf.DSIZE<%0d>",a_rom_contect_inf.DSIZE,b_rom_contect_inf.DSIZE);
         $stop;
    end
end

assign  xram_inf.addra = a_axis_unzip.axis_tdata;
assign  xram_inf.dia = '0;
assign  xram_inf.wea = '0;
assign  xram_inf.ena = 1'b1;
assign  xram_inf.clka = a_axis_zip.aclk;
assign  xram_inf.rsta = ~a_axis_zip.aresetn;
assign  xram_inf.addrb = b_axis_unzip.axis_tdata;
assign  xram_inf.dib = '0;
assign  xram_inf.web = '0;
assign  xram_inf.enb = 1'b1;
assign  xram_inf.clkb = b_axis_zip.aclk;
assign  xram_inf.rstb = ~b_axis_zip.aresetn;

assign  a_rom_contect_inf.axis_tdata = a_rom_contect_inf_pre.axis_tdata[ a_rom_contect_inf.DSIZE-1:0];
assign  a_rom_contect_inf.axis_tvalid = a_rom_contect_inf_pre.axis_tvalid;
assign  a_rom_contect_inf.axis_tlast = a_rom_contect_inf_pre.axis_tlast;
assign  a_rom_contect_inf_pre.axis_tready = a_rom_contect_inf.axis_tready;
assign  b_rom_contect_inf.axis_tdata = b_rom_contect_inf_pre.axis_tdata[ b_rom_contect_inf.DSIZE-1:0];
assign  b_rom_contect_inf.axis_tvalid = b_rom_contect_inf_pre.axis_tvalid;
assign  b_rom_contect_inf.axis_tlast = b_rom_contect_inf_pre.axis_tlast;
assign  b_rom_contect_inf_pre.axis_tready = b_rom_contect_inf.axis_tready;

endmodule
