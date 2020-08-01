/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/6/7 
madified:
***********************************************/
// `include "define_macro.sv"
`timescale 1ns/1ps
(* datainf_c = "true" *)
module part_data_pair_map #(
    parameter   NUM   = 8,
    parameter   ISIZE = 8,
    parameter   OSIZE = 8
)(
    //-->> WRITE
    data_inf_c.slaver       write_inf,      //data -> [ISIZE-1:0][OSIZE-1:0]
    //-->> READ <<----------------
    data_inf_c.slaver       ipart_inf,       //data -> [ISIZE-1:0] + other
    data_inf_c.slaver       opart_inf,       //data -> [OSIZE-1:0] + other
    //-->> DELETE
    data_inf_c.slaver       idel_inf,       //data -> [ISIZE-1:0]
    data_inf_c.slaver       odel_inf,       //data -> [OSIZE-1:0]
    //-->> OUT
    data_inf_c.master       Oipart_inf,       //data -> [ISIZE-1:0][OSIZE-1:0] + other
    data_inf_c.master       Oopart_inf,       //data -> [ISIZE-1:0][OSIZE-1:0] + other
    //-->> err
    data_inf_c.master       ierr_inf,         //data -> [ISIZE-1:0]
    data_inf_c.master       oerr_inf          //data -> [OSIZE-1:0]
);

// `CheckParamPair(fid_addr_len_inf.DSIZE,96)

data_inf_c     #(.DSIZE(ISIZE))  iread_inf       (ipart_inf.clock,ipart_inf.rst_n);
data_inf_c     #(.DSIZE(ISIZE))  tmp_iread_inf       (ipart_inf.clock,ipart_inf.rst_n);
data_inf_c     #(.DSIZE(OSIZE))  oread_inf       (ipart_inf.clock,ipart_inf.rst_n);
data_inf_c     #(.DSIZE(ISIZE+OSIZE))  Oiread_inf      (ipart_inf.clock,ipart_inf.rst_n);
data_inf_c     #(.DSIZE(ISIZE+OSIZE))  Ooread_inf      (ipart_inf.clock,ipart_inf.rst_n);

assign  iread_inf.data  = ipart_inf.data[ipart_inf.DSIZE-1-:ISIZE];
// assign  iread_inf.data  = '1;
assign  iread_inf.valid = ipart_inf.valid;
assign  ipart_inf.ready = iread_inf.ready;

assign  oread_inf.data  = opart_inf.data[opart_inf.DSIZE-1-:OSIZE];
assign  oread_inf.valid = opart_inf.valid;
assign  opart_inf.ready = oread_inf.ready;

data_pair_map_A2 #(
    .ISIZE      (ISIZE  ),
    .OSIZE      (OSIZE  ),
    .NUM        (NUM    )
)data_pair_map_A2_inst(
    //-->> WRITE
/*    data_inf_c.slaver    */   .write_inf      (write_inf  ),      //data -> [ISIZE-1:0][OSIZE-1:0]
    //-->> READ <<----------------
/*    data_inf_c.slaver    */   .iread_inf      (iread_inf  ),       //data -> [ISIZE-1:0]
/*    data_inf_c.slaver    */   .oread_inf      (oread_inf  ),       //data -> [OSIZE-1:0]
    //-->> DELETE
/*    data_inf_c.slaver    */   .idel_inf       (idel_inf   ),       //data -> [ISIZE-1:0]
/*    data_inf_c.slaver    */   .odel_inf       (odel_inf   ),       //data -> [OSIZE-1:0]
    //-->> OUT
/*    data_inf_c.master    */   .Oiread_inf     (Oiread_inf ),       //data -> [OSIZE-1:0]
/*    data_inf_c.master    */   .Ooread_inf     (Ooread_inf ),       //data -> [ISIZE-1:0]
    //-->> err
/*    data_inf_c.master    */   .ierr_inf       (ierr_inf   ),       //data -> [ISIZE-1:0]
/*    data_inf_c.master    */   .oerr_inf       (oerr_inf   )        //data -> [OSIZE-1:0]
);


logic  [opart_inf.DSIZE-OSIZE-1:0]     ipart_slaver_data;
logic  [opart_inf.DSIZE-OSIZE-1:0]     opart_slaver_data;

simple_data_pipe_slaver #(
    .DSIZE          (ipart_inf.DSIZE-ISIZE)
)simple_data_pipe_slaver_inst_i(
/*  input                   */    .clock        (ipart_inf.clock    ),
/*  input                   */    .rst_n        (ipart_inf.rst_n    ),
/*  input [DSIZE-1:0]       */    .indata       (ipart_inf.data[ipart_inf.DSIZE-ISIZE-1:0]),
/*  input                   */    .invalid      (ipart_inf.valid    ),
/*  input                   */    .inready      (ipart_inf.ready    ),
/*  output logic[DSIZE-1:0] */    .outdata      (ipart_slaver_data  ),
/*  input                   */    .outvalid     (Oiread_inf.valid   ),
/*  input                   */    .outready     (Oiread_inf.ready   )
);

simple_data_pipe_slaver #(
    .DSIZE          (opart_inf.DSIZE-OSIZE)
)simple_data_pipe_slaver_inst_o(
/*  input                   */    .clock        (opart_inf.clock    ),
/*  input                   */    .rst_n        (opart_inf.rst_n    ),
/*  input [DSIZE-1:0]       */    .indata       (opart_inf.data[opart_inf.DSIZE-OSIZE-1:0]),
/*  input                   */    .invalid      (opart_inf.valid    ),
/*  input                   */    .inready      (opart_inf.ready    ),
/*  output logic[DSIZE-1:0] */    .outdata      (opart_slaver_data  ),
/*  input                   */    .outvalid     (Ooread_inf.valid   ),
/*  input                   */    .outready     (Ooread_inf.ready   )
);

assign  Oipart_inf.data     = {Oiread_inf.data,ipart_slaver_data};
assign  Oipart_inf.valid    = Oiread_inf.valid;
assign  Oiread_inf.ready    = Oipart_inf.ready;

assign  Oopart_inf.data     = {Ooread_inf.data,opart_slaver_data};
assign  Oopart_inf.valid    = Ooread_inf.valid;
assign  Ooread_inf.ready    = Oopart_inf.ready;

endmodule
