require_hdl File.join(__dir__,'full_axi4_to_axis_partition_wr_rd.sv')
# require_relative '../../wmy/NRISC_TDL/ram/cm_ram_inf_define.rb'
require_sdl 'common_ram_wrapper.rb'

require_hdl File.join(__dir__,"./full_axi4_to_axis.sv")

TdlBuild.axi4_dpram_cache(__dir__) do 
    parameter.INIT_FILE     ''
    port.axi4.slaver    - 'a_inf'
    port.axi4.slaver    - 'b_inf'

    cm_ram_inf(dsize: a_inf.dsize,rsize: a_inf.asize,msize: a_inf.DSIZE/8)           - 'xram_inf'

    initial do 
        assert(a_inf.ASIZE == b_inf.ASIZE,"a_inf.ASIZE != b_inf.ASIZE")
        assert(a_inf.DSIZE == b_inf.DSIZE,"a_inf.ASIZE != b_inf.ASIZE")
    end

    full_axi4_to_axis.full_axi4_to_axis_ainst do |h|
        h.port.axi_inf.slaver.xaxi4_inf                 a_inf
        h.port.axi_stream_inf.master.axis_inf           axi_stream_inf(dsize: "#{a_inf.ASIZE}+#{a_inf.DSIZE}+1".to_nq ,clock: a_inf.axi_aclk,reset: a_inf.axi_aresetn).a_axis_inf    #// ASIZE + DSIZE + 1
        h.port.axi_stream_inf.slaver.axis_rd_inf        axi_stream_inf(dsize: a_inf.DSIZE ,clock: a_inf.axi_aclk,reset: a_inf.axi_aresetn).a_axis_rd_inf    #// ASIZE
    end

    data_inf_c(dsize: "#{a_inf.ASIZE}+1".to_nq ,clock: a_inf.axi_aclk,reset: a_inf.axi_aresetn) - 'a_datac_rd_inf' 

    Assign do 
        #如果是写 一直有ready 
        a_axis_inf.axis_tready  <= "#{a_axis_inf.axis_tdata[a_axis_inf.DSIZE-1]} || (#{a_datac_rd_inf.ready} && !#{a_axis_inf.axis_tdata[a_axis_inf.DSIZE-1]})".to_nq
        
        a_datac_rd_inf.data     <= "{#{a_axis_inf.axis_tlast},#{a_axis_inf.axis_tdata[a_axis_inf.DSIZE-1-1,a_axis_inf.DSIZE-a_inf.ASIZE-1]}}".to_nq #
        a_datac_rd_inf.valid    <= "#{a_axis_inf.axis_tvalid} && !#{a_axis_inf.axis_tdata[a_axis_inf.DSIZE-1]}".to_nq
    end

    data_inf_c_planer_A1.data_inf_c_planer_A1_ainst do |h|
        h.param.LAT         3   
        h.param.DSIZE       a_inf.DSIZE     
        h.param.HEAD        "OFF"    
        h.input.reset                   ~a_datac_rd_inf.rst_n         
        h.input['DSIZE'].pack_data      xram_inf.doa               
        h.slaver                        a_datac_rd_inf        
        h.master                        data_inf_c(dsize: "#{a_inf.ASIZE}+#{a_inf.DSIZE}+1".to_nq ,clock: a_inf.axi_aclk,reset: a_inf.axi_aresetn).a_datac_rd_rel_inf #HEAD=="ON" : {pack_data,slaver.data} or /HEAD=="OFF" : {slaver.data,pack_data}
    end

    Assign do 
        a_axis_rd_inf.axis_tvalid   <= a_datac_rd_rel_inf.valid
        a_axis_rd_inf.axis_tdata    <= a_datac_rd_rel_inf.data[a_axis_rd_inf.DSIZE-1,0]
        a_axis_rd_inf.axis_tlast    <= a_datac_rd_rel_inf.data[a_datac_rd_rel_inf.DSIZE-1]
        a_datac_rd_rel_inf.ready    <= a_axis_rd_inf.axis_tready

        # xram_inf.addra      <= a_datac_rd_inf.data[a_datac_rd_inf.DSIZE-3,0]
        xram_inf.addra      <= a_axis_inf.axis_tdata[a_axis_inf.DSIZE-1-1,a_axis_inf.DSIZE-a_inf.ASIZE-1]
        xram_inf.dia        <= a_axis_inf.axis_tdata[a_inf.DSIZE-1,0]
        xram_inf.wea        <= "{xram_inf.MSIZE{#{a_axis_inf.axis_tdata[a_axis_inf.DSIZE-1]}}}".to_nq
        xram_inf.ena        <= 1.b1
        xram_inf.clka       <= a_axis_inf.aclk
        xram_inf.rsta       <= ~a_axis_inf.aresetn
    end

    full_axi4_to_axis.full_axi4_to_axis_binst do |h|
        h.port.axi_inf.slaver.xaxi4_inf                 b_inf
        h.port.axi_stream_inf.master.axis_inf           axi_stream_inf(dsize: "#{b_inf.ASIZE}+#{b_inf.DSIZE}+1".to_nq,clock: b_inf.axi_aclk,reset: b_inf.axi_aresetn).b_axis_inf    #// ASIZE + DSIZE + 1
        h.port.axi_stream_inf.slaver.axis_rd_inf        axi_stream_inf(dsize: b_inf.DSIZE ,clock: b_inf.axi_aclk,reset: b_inf.axi_aresetn).b_axis_rd_inf    #// ASIZE
    end

    data_inf_c(dsize: "#{b_inf.ASIZE}+1".to_nq ,clock: b_inf.axi_aclk,reset: b_inf.axi_aresetn) - 'b_datac_rd_inf' 

    Assign do 
        #如果是写 一直有ready 
        b_axis_inf.axis_tready  <= "#{b_axis_inf.axis_tdata[b_axis_inf.DSIZE-1]} || (#{b_datac_rd_inf.ready} && !#{b_axis_inf.axis_tdata[b_axis_inf.DSIZE-1]})".to_nq
        
        b_datac_rd_inf.data     <= "{#{b_axis_inf.axis_tlast},#{b_axis_inf.axis_tdata[b_axis_inf.DSIZE-1-1,b_axis_inf.DSIZE-b_inf.ASIZE-1]}}".to_nq
        b_datac_rd_inf.valid    <="#{b_axis_inf.axis_tvalid} && !#{b_axis_inf.axis_tdata[b_axis_inf.DSIZE-1]}".to_nq
    end

    data_inf_c_planer_A1.data_inf_c_planer_A1_binst do |h|
        h.param.LAT         3   
        h.param.DSIZE       b_inf.DSIZE     
        h.param.HEAD        "OFF"    
        h.input.reset                   ~b_datac_rd_inf.rst_n         
        h.input['DSIZE'].pack_data      xram_inf.dob               
        h.slaver                        b_datac_rd_inf        
        h.master                        data_inf_c(dsize: "#{b_inf.ASIZE}+#{b_inf.DSIZE}+1".to_nq ,clock: b_inf.axi_aclk,reset: b_inf.axi_aresetn).b_datac_rd_rel_inf #HEAD=="ON" : {pack_data,slaver.data} or /HEAD=="OFF" : {slaver.data,pack_data}
    end

    Assign do 
        b_axis_rd_inf.axis_tvalid   <= b_datac_rd_rel_inf.valid
        b_axis_rd_inf.axis_tdata    <= b_datac_rd_rel_inf.data[b_axis_rd_inf.DSIZE-1,0]
        b_axis_rd_inf.axis_tlast    <= b_datac_rd_rel_inf.data[b_datac_rd_rel_inf.DSIZE-1]
        b_datac_rd_rel_inf.ready    <= b_axis_rd_inf.axis_tready

        # xram_inf.addrb      <= b_datac_rd_inf.data[b_datac_rd_inf.DSIZE-2,0]
        xram_inf.addrb      <= b_axis_inf.axis_tdata[b_axis_inf.DSIZE-1-1,b_axis_inf.DSIZE-b_inf.ASIZE-1]
        xram_inf.dib        <= b_axis_inf.axis_tdata[b_inf.DSIZE-1,0]
        xram_inf.web        <= "{xram_inf.MSIZE{#{b_axis_inf.axis_tdata[b_axis_inf.DSIZE-1]}}}".to_nq
        xram_inf.enb        <= 1.b1
        xram_inf.clkb       <= b_axis_inf.aclk
        xram_inf.rstb       <= ~b_axis_inf.aresetn
    end

    common_ram_wrapper.common_ram_wrapper_inst do |h|
        h.param.INIT_FILE                   param.INIT_FILE
        h.port.cm_ram_inf.slaver.ram_inf    xram_inf  
    end

end