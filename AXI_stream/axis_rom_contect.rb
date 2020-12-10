
require_hdl 'axis_uncompress_A1.sv'
require_hdl 'axi_stream_planer.sv'
require_sdl 'axis_uncompress_verb.rb'

TdlBuild.axis_rom_contect(__dir__) do 
    vcs_string(256).INIT_FILE   'template.coe'
    parameter.STEP              1
    # parameter.DSIZE             11
    port.axi_stream_inf.slaver  - 'a_axis_zip' # ASIZE + ASIZE
    port.axi_stream_inf.slaver  - 'b_axis_zip' # ASIZE + ASIZE

    port.axi_stream_inf.master  - 'a_rom_contect_inf' # DSIZE
    port.axi_stream_inf.master  - 'b_rom_contect_inf' # DSIZE

    Initial do 
        assert(a_axis_zip.DSIZE==b_axis_zip.DSIZE,"a_axis_zip.DSIZE<%0d> must equal b_axis_zip.DSIZE<%0d>",a_axis_zip.DSIZE,b_axis_zip.DSIZE)
        assert(a_rom_contect_inf.DSIZE==b_rom_contect_inf.DSIZE, "a_rom_contect_inf.DSIZE<%0d>==b_rom_contect_inf.DSIZE<%0d>",a_rom_contect_inf.DSIZE,b_rom_contect_inf.DSIZE)
    end

    a_axis_zip.copy( dsize: a_axis_zip.DSIZE/2, name: 'a_axis_unzip')
    b_axis_zip.copy( dsize: b_axis_zip.DSIZE/2, name: 'b_axis_unzip')

    axis_uncompress_verb.axis_uncompress_verb_ainst do  |h|#(
        h.param.ASIZE         a_axis_zip.DSIZE/2        #//ASIZE + LSIZE = AXIS DATA WIDTH
        h.param.LSIZE         a_axis_zip.DSIZE/2
        h.param.STEP          param.STEP
        h.axi_stream_inf.slaver.axis_zip        a_axis_zip #          //ASIZE+LSIZE
        h.axi_stream_inf.master.axis_unzip      a_axis_unzip                   #//ASIZE
    end

    axis_uncompress_verb.axis_uncompress_verb_binst do  |h|#(
        h.param.ASIZE         a_axis_zip.DSIZE/2        #//ASIZE + LSIZE = AXIS DATA WIDTH
        h.param.LSIZE         a_axis_zip.DSIZE/2
        h.param.STEP          param.STEP
        h.axi_stream_inf.slaver.axis_zip        b_axis_zip #          //ASIZE+LSIZE
        h.axi_stream_inf.master.axis_unzip      b_axis_unzip                   #//ASIZE
    end

    cm_ram_inf(dsize: a_rom_contect_inf.DSIZE, rsize: a_axis_zip.DSIZE,msize: 1)           - 'xram_inf'

    common_ram_wrapper.common_ram_wrapper_inst do |h|
        h.INIT_FILE                         param.INIT_FILE
        h.port.cm_ram_inf.slaver.ram_inf    xram_inf
    end

    Assign do

        xram_inf.addra      <= a_axis_unzip.axis_tdata
        xram_inf.dia        <= 0.A
        xram_inf.wea        <= 0.A
        xram_inf.ena        <= 1.b1
        xram_inf.clka       <= a_axis_unzip.aclk
        xram_inf.rsta       <= ~a_axis_unzip.aresetn

        xram_inf.addrb      <= b_axis_unzip.axis_tdata
        xram_inf.dib        <= 0.A
        xram_inf.web        <= 0.A
        xram_inf.enb        <= 1.b1
        xram_inf.clkb       <= b_axis_unzip.aclk
        xram_inf.rstb       <= ~b_axis_unzip.aresetn
    end

    axi_stream_planer.axi_stream_planer_ainst do |h| #(
        h.param.LAT     3
        h.param.DSIZE   a_rom_contect_inf.DSIZE
        h.param.HEAD    "FALSE"
        h.input.reset                           ~a_axis_zip.aresetn 
        h.input['DSIZE'].pack_data              xram_inf.doa
        h.port.axi_stream_inf.slaver.axis_in    a_axis_unzip
        h.port.axi_stream_inf.master.axis_out   a_rom_contect_inf.copy(name: 'a_rom_contect_inf_pre', dsize: "#{a_rom_contect_inf.DSIZE}+#{a_axis_unzip.DSIZE}".to_nq)      #///HEAD=="ON" : {pack_data,slaver.data} or /HEAD=="OFF" : {slaver.data,pack_data}
    end


    axi_stream_planer.axi_stream_planer_binst do |h| #(
        h.param.LAT     3
        h.param.DSIZE   b_rom_contect_inf.DSIZE
        h.param.HEAD    "FALSE"
        h.input.reset                           ~b_axis_zip.aresetn 
        h.input['DSIZE'].pack_data              xram_inf.dob
        h.port.axi_stream_inf.slaver.axis_in    b_axis_unzip
        h.port.axi_stream_inf.master.axis_out   b_rom_contect_inf.copy(name: 'b_rom_contect_inf_pre', dsize: "#{b_rom_contect_inf.DSIZE}+#{b_axis_unzip.DSIZE}".to_nq)      #///HEAD=="ON" : {pack_data,slaver.data} or /HEAD=="OFF" : {slaver.data,pack_data}
    end

    Assign do 
        a_rom_contect_inf.axis_tdata        <= a_rom_contect_inf_pre.axis_tdata[a_rom_contect_inf.DSIZE-1,0]
        a_rom_contect_inf.axis_tvalid       <= a_rom_contect_inf_pre.axis_tvalid
        a_rom_contect_inf.axis_tlast        <= a_rom_contect_inf_pre.axis_tlast
        a_rom_contect_inf_pre.axis_tready   <= a_rom_contect_inf.axis_tready

        b_rom_contect_inf.axis_tdata        <= b_rom_contect_inf_pre.axis_tdata[b_rom_contect_inf.DSIZE-1,0]
        b_rom_contect_inf.axis_tvalid       <= b_rom_contect_inf_pre.axis_tvalid
        b_rom_contect_inf.axis_tlast        <= b_rom_contect_inf_pre.axis_tlast
        b_rom_contect_inf_pre.axis_tready   <= b_rom_contect_inf.axis_tready
    end

end