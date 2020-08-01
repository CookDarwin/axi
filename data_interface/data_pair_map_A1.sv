/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.1.0 2017/6/6 
    add delete
creaded: 2017/6/6 
madified:
***********************************************/
`timescale 1ns/1ps
module data_pair_map_A1 #(
    parameter   ISIZE = 8,
    parameter   OSIZE = 8,
    parameter   NUM   = 8
)(
    //-->> WRITE
    data_inf_c.slaver       write_inf,      //data -> [ISIZE-1:0][OSIZE-1:0]
    //-->> READ <<----------------
    data_inf_c.slaver       read_inf,       //data -> [ISIZE-1:0]
    //-->> DELETE
    data_inf_c.slaver       idel_inf,       //data -> [ISIZE-1:0]
    data_inf_c.slaver       odel_inf,       //data -> [OSIZE-1:0]
    //-->> OUT
    data_inf_c.master       out_inf,       //data -> [OSIZE-1:0]
    //-->> err
    data_inf_c.master       err_inf
);

import DataInterfacePkg::*;

assign read_inf.ready   = out_inf.ready;
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
bit [ISIZE-1:0]       next_odata_vld_side;
bit [ISIZE-1:0]       next_odata_data_side;
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

logic [OSIZE-1:0]       next_odata;
logic                   next_vld;

always_comb begin
    next_vld    = 0;
    foreach(odata[i])begin
        if(read_inf.data == idata[i])begin
            next_odata  = odata[i];
            next_vld    = read_inf.valid && read_inf.ready && map_vld[i];
        end
    end
    // #1;
end


always@(posedge clock,negedge rst_n)
    if(~rst_n)  out_inf.data    <= '0;
    else begin
        if(read_inf.valid && read_inf.ready)
                out_inf.data    <= next_odata;
        else    out_inf.data    <= out_inf.data;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  out_inf.valid    <= '0;
    else begin
        out_inf.valid   <= pipe_valid_func((read_inf.valid && next_vld),read_inf.ready,out_inf.valid);
    end

//--->> ERROR <<------------------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  err_inf.data    <= '0;
    else begin
        if(read_inf.valid && read_inf.ready)
                err_inf.data    <= read_inf.data;
        else    err_inf.data    <= err_inf.data;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  err_inf.valid    <= '0;
    else begin
        if(read_inf.valid && read_inf.ready)
                err_inf.valid   <= !next_vld;
        else if(err_inf.valid && err_inf.ready)
                err_inf.valid    <= 1'b0;
        else    err_inf.valid    <= err_inf.valid;
    end
//---<< ERROR >>------------------------------------

endmodule
