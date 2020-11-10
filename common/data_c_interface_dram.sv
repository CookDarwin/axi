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

module data_c_interface_dram #(
    parameter  OUT_LAT  = 3,
    parameter  DSIZE    = 32,
    parameter  ASIZE    = 12,
    parameter  OUT_PIPE = "TRUE"
)(
    data_inf_c.slaver   exinfo_addr_inf,
    data_inf_c.master   exinfo_addr_data_inf,
    data_inf_c.slaver   rd_wr_ram_inf,
    data_inf_c.master   rd_ram_rel_inf,
    cm_ram_inf.master   ram_inf
);

//==========================================================================
//-------- define ----------------------------------------------------------

data_inf_c #(.DSIZE(ASIZE)) m00_only_rd (.clock(rd_wr_ram_inf.clock),.rst_n(rd_wr_ram_inf.rst_n)) ;
data_inf_c #(.DSIZE(rd_ram_rel_inf.DSIZE)) pre_rd_rel_inf (.clock(rd_ram_rel_inf.clock),.rst_n(rd_ram_rel_inf.rst_n)) ;
//==========================================================================
//-------- instance --------------------------------------------------------
data_inf_c_planer_A1 #(
    .LAT   (OUT_LAT ),
    .DSIZE (DSIZE   ),
    .HEAD  ("OFF"   )
)data_inf_c_planer_A1_inst_ld_st(
/* input             */.reset     (~exinfo_addr_inf.rst_n ),
/* input             */.pack_data (ram_inf.dob            ),
/* data_inf_c.slaver */.slaver    (m00_only_rd            ),
/* data_inf_c.master */.master    (pre_rd_rel_inf         )
);
data_inf_c_planer_A1 #(
    .LAT   (OUT_LAT       ),
    .DSIZE (ram_inf.DSIZE ),
    .HEAD  ("OFF"         )
)data_inf_c_planer_A1_inst(
/* input             */.reset     (~exinfo_addr_inf.rst_n ),
/* input             */.pack_data (ram_inf.doa            ),
/* data_inf_c.slaver */.slaver    (exinfo_addr_inf        ),
/* data_inf_c.master */.master    (exinfo_addr_data_inf   )
);
//==========================================================================
//-------- expression ------------------------------------------------------
generate

if( OUT_PIPE=="TRUE")begin
    data_c_pipe_inf data_c_pipe_inf_inst(
    /* data_inf_c.slaver */.slaver (pre_rd_rel_inf ),
    /* data_inf_c.master */.master (rd_ram_rel_inf )
    );end 
else begin
    data_c_direct direct_inst(
    /* data_inf_c.slaver */.slaver (pre_rd_rel_inf ),
    /* data_inf_c.master */.master (rd_ram_rel_inf )
    );end
endgenerate
initial begin
    assert( rd_wr_ram_inf.DSIZE==( DSIZE+ASIZE+1))else begin
         $error("rd_wr_ram_inf.DSIZE[%d] != DSIZE[%d]+ASIZE[%d]+1",rd_wr_ram_inf.DSIZE,DSIZE,ASIZE);
         $stop;
    end
    assert( rd_ram_rel_inf.DSIZE==( DSIZE+ASIZE))else begin
         $error("rd_ram_rel_inf.DSIZE[%d] != DSIZE[%d]+ASIZE[%d]",rd_ram_rel_inf.DSIZE,DSIZE,ASIZE);
         $stop;
    end
    assert( ram_inf.DSIZE==DSIZE)else begin
         $error("ram_inf.DSIZE[%d] != DSIZE[%d]",ram_inf.DSIZE,DSIZE);
         $stop;
    end
    assert( ram_inf.RSIZE==ASIZE)else begin
         $error("ram_inf.RSIZE[%d] != RSIZE[%d]",ram_inf.RSIZE,ASIZE);
         $stop;
    end
end

assign  ram_inf.dib = rd_wr_ram_inf.data[ DSIZE-1:0];
assign  ram_inf.enb = 1'b1;
assign  ram_inf.web = rd_wr_ram_inf.data[ rd_wr_ram_inf.DSIZE-1];
assign  ram_inf.addrb = rd_wr_ram_inf.data[ DSIZE+ASIZE-1:DSIZE];

assign  m00_only_rd.data = rd_wr_ram_inf.data[ DSIZE+ASIZE-1:DSIZE];
assign  m00_only_rd.valid = ( ~rd_wr_ram_inf.data[ rd_wr_ram_inf.DSIZE-1]&rd_wr_ram_inf.valid);
assign  rd_wr_ram_inf.ready = ( ~rd_wr_ram_inf.data[ rd_wr_ram_inf.DSIZE-1]|m00_only_rd.ready);

assign  ram_inf.addra = exinfo_addr_inf.data[ ASIZE-1:0];
assign  ram_inf.dia = '0;
assign  ram_inf.ena = 1'b1;
assign  ram_inf.wea = 1'b0;

assign  ram_inf.clka = exinfo_addr_inf.clock;
assign  ram_inf.rsta = ~exinfo_addr_inf.rst_n;
assign  ram_inf.clkb = rd_wr_ram_inf.clock;
assign  ram_inf.rstb = ~rd_wr_ram_inf.rst_n;

endmodule
