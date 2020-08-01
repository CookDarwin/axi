/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.1.0 2017/6/6 
    add delete
Version: VERA.2.0 2017/6/6 
    both read
creaded: 2017/6/6 
madified:
***********************************************/
`timescale 1ns/1ps
module data_pair_map_A2 #(
    parameter   ISIZE = 8,
    parameter   OSIZE = 8,
    parameter   NUM   = 8
)(
    //-->> WRITE
    data_inf_c.slaver       write_inf,      //data -> [ISIZE-1:0][OSIZE-1:0]
    //-->> READ <<----------------
    data_inf_c.slaver       iread_inf,       //data -> [ISIZE-1:0]
    data_inf_c.slaver       oread_inf,       //data -> [OSIZE-1:0]
    //-->> DELETE
    data_inf_c.slaver       idel_inf,       //data -> [ISIZE-1:0]
    data_inf_c.slaver       odel_inf,       //data -> [OSIZE-1:0]
    //-->> OUT
    data_inf_c.master       Oiread_inf,       //data -> [ISIZE-1:0][OSIZE-1:0]
    data_inf_c.master       Ooread_inf,       //data -> [ISIZE-1:0][OSIZE-1:0]
    //-->> err
    data_inf_c.master       ierr_inf,         //data -> [ISIZE-1:0]
    data_inf_c.master       oerr_inf          //data -> [OSIZE-1:0]
);

import DataInterfacePkg::*;

assign iread_inf.ready   = Oiread_inf.ready;
assign oread_inf.ready   = Ooread_inf.ready;
assign write_inf.ready  = 1'b1;
assign idel_inf.ready   = !write_inf.valid;
assign odel_inf.ready   = !write_inf.valid;
//--->> CLOCK RESET <<-------------
logic   clock,rst_n;
assign  clock   = write_inf.clock;
assign  rst_n   = write_inf.rst_n;
//---<< CLOCK RESET >>-------------

logic [ISIZE-1:0]       idata [NUM-1:0];
logic [OSIZE-1:0]       odata [NUM-1:0];
logic [NUM-1:0]         map_vld;

bit [ISIZE-1:0]       next_idata_vld_side;
bit [ISIZE-1:0]       next_idata_data_side;
logic [NUM-1:0]         next_map_vld_vld_side;
logic [NUM-1:0]         next_map_vld_data_side;
bit [OSIZE-1:0]       next_odata_vld_side;
bit [OSIZE-1:0]       next_odata_data_side;
logic                   data_record;
logic                   vld_record;
logic [$clog2(NUM)-1:0] data_index,vld_index;

always_comb begin
    vld_record  = 0;
    // next_map_vld_vld_side = '0;
    foreach(map_vld[i])begin
        if(write_inf.valid && write_inf.ready && !map_vld[i])begin
            next_map_vld_vld_side[i] = 1'b1;
            vld_record               = 1'b1;
            next_idata_vld_side      = write_inf.data[OSIZE+:ISIZE];
            next_odata_vld_side      = write_inf.data[OSIZE-1:0];
            vld_index                = i;
        end
    end
    data_record = 0;
    // next_map_vld_data_side = '0;
    foreach(map_vld[i])begin
        if(write_inf.valid && write_inf.ready && (idata[i] == write_inf.data[OSIZE+:ISIZE]))begin
            next_map_vld_data_side[i]   = 1'b1;
            data_record                 = 1'b1;
            next_idata_data_side        = write_inf.data[OSIZE+:ISIZE];
            next_odata_data_side        = write_inf.data[OSIZE-1:0];
            data_index                  = i;
        end
    end
    // #1;
end

always@(posedge clock,negedge rst_n)
    if(~rst_n)
        foreach(idata[i])begin
            idata[i]    <= i;
            odata[i]    <= i;
            map_vld[i]  <= '0;
        end
    else begin
        if(data_record)begin
            idata[data_index]    <= next_idata_data_side;
            odata[data_index]    <= next_odata_data_side;
            map_vld[data_index]  <= 1'b1;
        end else if(vld_record)begin
            idata[vld_index]    <= next_idata_vld_side;
            odata[vld_index]    <= next_odata_vld_side;
            map_vld[vld_index]  <= 1'b1;
        end else begin
            foreach(idata[i])begin
                idata[i]    <= idata[i];
                odata[i]    <= odata[i];
                if((idel_inf.ready && idel_inf.valid && idata[i]==idel_inf.data) || (odel_inf.ready && odel_inf.valid && odata[i]==odel_inf.data))
                        map_vld[i]  <= 1'b0;
                else    map_vld[i]  <= map_vld[i];
            end
        end
    end

logic [OSIZE-1:0]       inext_odata;
logic                   inext_vld;

always_comb begin
    inext_vld    = 0;
    foreach(odata[i])begin
        if(iread_inf.data == idata[i])begin
            inext_odata  = odata[i];
            inext_vld    = iread_inf.valid && iread_inf.ready && map_vld[i];
        end
    end
    // #1;
end


always@(posedge clock,negedge rst_n)
    if(~rst_n)  Oiread_inf.data    <= '0;
    else begin
        if(iread_inf.valid && iread_inf.ready)
                Oiread_inf.data    <= {iread_inf.data,inext_odata};
        else    Oiread_inf.data    <= Oiread_inf.data;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  Oiread_inf.valid    <= '0;
    else begin
        Oiread_inf.valid   <= pipe_valid_func((iread_inf.valid && inext_vld),iread_inf.ready,Oiread_inf.valid);
    end

logic [OSIZE-1:0]       onext_odata;
logic                   onext_vld;

always_comb begin
    onext_vld    = 0;
    foreach(odata[i])begin
        if(oread_inf.data == odata[i])begin
            onext_odata  = idata[i];
            onext_vld    = oread_inf.valid && oread_inf.ready && map_vld[i];
        end
    end
    // #1;
end


always@(posedge clock,negedge rst_n)
    if(~rst_n)  Ooread_inf.data    <= '0;
    else begin
        if(oread_inf.valid && oread_inf.ready)
                Ooread_inf.data    <= {onext_odata,oread_inf.data};
        else    Ooread_inf.data    <= Ooread_inf.data;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  Ooread_inf.valid    <= '0;
    else begin
        Ooread_inf.valid   <= pipe_valid_func((oread_inf.valid && onext_vld),oread_inf.ready,Ooread_inf.valid);
    end

//--->> ERROR <<------------------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  ierr_inf.data    <= '0;
    else begin
        if(iread_inf.valid && iread_inf.ready)
                ierr_inf.data    <= iread_inf.data;
        else    ierr_inf.data    <= ierr_inf.data;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  ierr_inf.valid    <= '0;
    else begin
        if(iread_inf.valid && iread_inf.ready)
                ierr_inf.valid   <= !inext_vld;
        else if(ierr_inf.valid && ierr_inf.ready)
                ierr_inf.valid    <= 1'b0;
        else    ierr_inf.valid    <= ierr_inf.valid;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  oerr_inf.data    <= '0;
    else begin
        if(oread_inf.valid && oread_inf.ready)
                oerr_inf.data    <= oread_inf.data;
        else    oerr_inf.data    <= oerr_inf.data;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  oerr_inf.valid    <= '0;
    else begin
        if(oread_inf.valid && oread_inf.ready)
                oerr_inf.valid   <= !onext_vld;
        else if(oerr_inf.valid && oerr_inf.ready)
                oerr_inf.valid    <= 1'b0;
        else    oerr_inf.valid    <= oerr_inf.valid;
    end
//---<< ERROR >>------------------------------------

endmodule
