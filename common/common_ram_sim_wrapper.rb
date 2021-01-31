require_hdl File.join(__dir__,"xilinx_hdl_dpram_sim.sv")

TdlBuild.common_ram_sim_wrapper(__dir__) do 
    # vcs_string(256).INIT_FILE 'template.coe'
    parameter.FNUM      8
    input[param.FNUM]          - 'load_files'
    input[param.FNUM,512*8]    - 'init_files'
    port.cm_ram_inf.slaver     - 'ram_inf'
    self.ex_up_code ||= ''
    self.ex_up_code += 'import SystemPkg::*;'
    
    logic[11+1]         - 'addra'      
    # logic[32+1]         - 'dina'       
    # logic[32+1]         - 'douta'      
    logic[ram_inf.DSIZE]         - 'dina'       
    logic[ram_inf.DSIZE]         - 'douta' 
    
    logic[11+1]         - 'addrb'
    # logic[32+1]         - 'dinb'
    # logic[32+1]         - 'doutb'
    logic[ram_inf.DSIZE]         - 'dinb'
    logic[ram_inf.DSIZE]         - 'doutb'
    
    Assign do 
        addra       <= ram_inf.addra
        dina        <= ram_inf.dia
        addrb       <= ram_inf.addrb
        dinb        <= ram_inf.dib
    end
    
    
    xilinx_hdl_dpram_sim.xilinx_hdl_dpram_sim_inst do |h|
        h.param.NB_COL            "$bits(dina) / 9 + ($bits(dina)%9 != 0)".to_nq #   // Specify number of columns (number of bytes)
        h.param.COL_WIDTH         9                     #// Specify column width (byte width, typically 8 or 9)
        h.param.RAM_DEPTH         "2**$bits(addra)".to_nq       #// Specify RAM depth (number of entries)
        # h.param.RAM_PERFORMANCE   "HIGH_PERFORMANCE"   #// Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
        # h.param.INIT_FILE         param.INIT_FILE             #// Specify name/location of RAM initialization file if using one (leave blank if not)
        h.param.FNUM                            param.FNUM 
        h.input[param.FNUM].load_files          load_files
        h.input[param.FNUM,512*8].init_files    init_files      
        h.input["clogb2(RAM_DEPTH-1)-1:0"].addra     addra           #  // Port A address bus, width determined from RAM_DEPTH
        h.input["clogb2(RAM_DEPTH-1)-1:0"].addrb     addrb           #  // Port B address bus, width determined from RAM_DEPTH
        h.input["(NB_COL*COL_WIDTH)-1:0"].dina       dina            #  // Port A RAM input data
        h.input["(NB_COL*COL_WIDTH)-1:0"].dinb       dinb            #  // Port B RAM input data
        h.input.clka                                 ram_inf.clka    #  // Port A clock
        h.input.clkb                                 ram_inf.clkb    #  // Port B clock
        h.input['NB_COL-1:0'].wea                    "{4{ram_inf.wea}}".to_nq #  // Port A write enable
        h.input['NB_COL-1:0'].web                    "{4{ram_inf.web}}".to_nq #  // Port B write enable
        h.input.ena                                  1.b1            #  // Port A RAM Enable, for additional power savings, disable BRAM when not in use
        h.input.enb                                  1.b1            #  // Port B RAM Enable, for additional power savings, disable BRAM when not in use
        h.input.rsta                                 ram_inf.rsta    #  // Port A output reset (does not affect memory contents)
        h.input.rstb                                 ram_inf.rstb    #  // Port B output reset (does not affect memory contents)
        h.input.regcea                               1.b1            #  // Port A output register enable
        h.input.regceb                               1.b1            #  // Port B output register enable
        h.output["(NB_COL*COL_WIDTH)-1:0"].douta     douta           #  // Port A RAM output data
        h.output["(NB_COL*COL_WIDTH)-1:0"].doutb     doutb           #  // Port B RAM output data
    end
    
    always_ff(posedge: ram_inf.clka) do 
        ram_inf.doa <= douta[ram_inf.DSIZE-1,0]
    end
    
    always_ff(posedge: ram_inf.clkb) do 
        ram_inf.dob <= doutb[ram_inf.DSIZE-1,0]
    end
end