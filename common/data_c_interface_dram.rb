

TdlBuild.data_c_interface_dram(__dir__) do 
    parameter.OUT_LAT       3
    parameter.DSIZE         32
    parameter.ASIZE         12
    parameter.OUT_PIPE      "TRUE"
    #// RAM 
    port.data_inf_c.slaver           - 'exinfo_addr_inf'        #// other[?:?], addr[ASIZE-1:0]
    port.data_inf_c.master           - 'exinfo_addr_data_inf'   #// other[?:?], addr[ASIZE-1:0] data[DSIZE-1:0]      
    port.data_inf_c.slaver           - 'rd_wr_ram_inf'
    port.data_inf_c.master           - 'rd_ram_rel_inf'         #// ADDR[ASIZE-1:0] DATA[DSIZE-1:0]
    #// ram interfaec
    port.cm_ram_inf.master           - 'ram_inf'

    Initial do 
        assert(rd_wr_ram_inf.DSIZE == (param.DSIZE+param.ASIZE+1),"rd_wr_ram_inf.DSIZE[%d] != DSIZE[%d]+ASIZE[%d]+1",rd_wr_ram_inf.DSIZE,param.DSIZE,param.ASIZE)
        assert(rd_ram_rel_inf.DSIZE == (param.DSIZE+param.ASIZE),"rd_ram_rel_inf.DSIZE[%d] != DSIZE[%d]+ASIZE[%d]",rd_ram_rel_inf.DSIZE,param.DSIZE,param.ASIZE)
        assert(ram_inf.DSIZE==param.DSIZE,"ram_inf.DSIZE[%d] != DSIZE[%d]",ram_inf.DSIZE, param.DSIZE )
        assert(ram_inf.RSIZE==param.ASIZE,"ram_inf.RSIZE[%d] != RSIZE[%d]",ram_inf.RSIZE, param.ASIZE )
    end

    Assign do 
        ram_inf.dib     <= rd_wr_ram_inf.data[param.DSIZE-1,0]
        ram_inf.enb     <= 1.b1 
        ram_inf.web     <= rd_wr_ram_inf.data[rd_wr_ram_inf.DSIZE-1]
        ram_inf.addrb   <= rd_wr_ram_inf.data[param.DSIZE+param.ASIZE-1,param.DSIZE]
    end

    rd_wr_ram_inf.inherited(name: 'm00_only_rd',dsize: param.ASIZE)

    Assign do 
        m00_only_rd.data    <= rd_wr_ram_inf.data[param.DSIZE+param.ASIZE-1,param.DSIZE]
        m00_only_rd.valid   <= (~rd_wr_ram_inf.data[rd_wr_ram_inf.DSIZE-1]) & rd_wr_ram_inf.valid
        rd_wr_ram_inf.ready <= (~rd_wr_ram_inf.data[rd_wr_ram_inf.DSIZE-1]) | m00_only_rd.ready
    end 


    data_inf_c_planer_A1.data_inf_c_planer_A1_inst_ld_st do |h|
        h.param.LAT         param.OUT_LAT   
        h.param.DSIZE       param.DSIZE    
        h.param.HEAD        "OFF"    
        h.input.reset                   ~exinfo_addr_inf.rst_n             
        h.input['DSIZE'].pack_data      ram_inf.dob               
        h.slaver                        m00_only_rd        
        h.master                        rd_ram_rel_inf.copy(name: 'pre_rd_rel_inf')          #     //{pack_data,slaver.data} or {slaver.data,pack_data} depen on HEAD
    end

    generate() do 
        IF(param.OUT_PIPE=="TRUE" || param.OUT_PIPE=="ON") do 
            data_c_pipe_inf.data_c_pipe_inf_inst do |h|
                h.slaver    pre_rd_rel_inf
                h.master    rd_ram_rel_inf
            end
        end
        ELSE do 
            data_c_direct.direct_inst do |h|
                h.slaver    pre_rd_rel_inf
                h.master    rd_ram_rel_inf
            end
        end
    end


    Assign do 
        ram_inf.addra   <= exinfo_addr_inf.data[param.ASIZE-1,0]
        ram_inf.dia     <= 0.A
        ram_inf.ena     <= 1.b1
        ram_inf.wea     <= 1.b0
    end

    data_inf_c_planer_A1.data_inf_c_planer_A1_inst do |h|
        h.param.LAT         param.OUT_LAT    
        h.param.DSIZE       ram_inf.DSIZE  
        h.param.HEAD        "OFF"       
        h.input.reset                       ~exinfo_addr_inf.rst_n     #
        h.input['DSIZE'].pack_data          ram_inf.doa                #
        h.slaver            exinfo_addr_inf            #
        h.master            exinfo_addr_data_inf       #      //{pack_data,slaver.data} or {slaver.data,pack_data} depen on HEAD
    end

    #// clock and rst_n
    Assign do 
        ram_inf.clka    <= exinfo_addr_inf.clock
        ram_inf.rsta    <= ~exinfo_addr_inf.rst_n
        ram_inf.clkb    <= rd_wr_ram_inf.clock
        ram_inf.rstb    <= ~rd_wr_ram_inf.rst_n
    end

end