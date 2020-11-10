# require_relative "../prj_lib"
require_sdl "axis_to_axi4_wr.rb"
new_m = SdlModule.new(name:File.basename(__FILE__,".rb"),out_sv_path:__dir__)
new_m.target_class = AxiStream

new_m.instance_exec do
    # AxiStream().slaver  :axis_in
    # AxiStream().master  :rd_rel_axis
    # Axi4().master       :axi4
    # AxiLite().master    :lite

    port.axis.slaver    - 'axis_in'
    port.axis.master    - 'rd_rel_axis'
    port.axi4.master    - 'axi4m'
    port.axi_lite.master    - 'lite'


    Instance(:axi_stream_interconnect_S2M_auto,"axi_stream_interconnect_S2M_auto_inst") do |h|
        h[:HEAD_DUMMY]      = 4
        h[:NUM]             = 4
        h[:slaver]          = axis_in
        # h[:sub_tx_inf]      = Def().axi_stream(name:"sub_rx_inf",clock:axis_in.aclk,reset:axis_in.aresetn,dsize:axis_in.DSIZE,dimension:[4])
        h[:sub_tx_inf]      = axi_stream_inf(clock:axis_in.aclk,reset:axis_in.aresetn,dsize:axis_in.DSIZE,dimension:[4]).sub_rx_inf
    end

    ## axi4 write
    # Def().axi_stream(name:"axis_axi4_wr_inf",clock:axis_in.aclk,reset:axis_in.aresetn,dsize:axis_in.DSIZE)
    axi_stream_inf(clock:axis_in.aclk,reset:axis_in.aresetn,dsize:axis_in.DSIZE) - 'axis_axi4_wr_inf'

    # axis_axi4_wr_inf.direct(up_stream:sub_rx_inf[0])
    axis_direct.axis_direct_inst do |h|
        h.slaver        sub_rx_inf[0]
        h.master        axis_axi4_wr_inf
    end

    parse_big_field_table_A1.parse_big_field_table_A1_inst do |h| #(
        h.param.DSIZE           8
        h.param.FIELD_LEN       4     #//MAX 16*8 : byte-> row:16, col:8
        h.param.FIELD_NAME      "Big Filed"
        h.param.TRY_PARSE       "OFF"
        h.port.input.enable
        h.port.output.logic['DSIZE-1:0'].value  logic[32].axis_axi4_wr_inf_seq        
        h.port.output.logic.out_valid           logic.axis_axi4_wr_inf_seq_vld
        h.port.axi_stream_inf.slaver.cm_tb_s    axis_axi4_wr_inf
        h.port.axi_stream_inf.master.cm_tb_m    axis_axi4_wr_inf.copy(name: 'seq_tail_stream')
        h.port.axi_stream_inf.mirror.cm_mirror  axis_axi4_wr_inf
    end

    Instance(:axis_to_axi4_wr,"axis_to_axi4_wr_inst") do |h|
        # h[:addr]        = axis_axi4_wr_inf.seq(0,4)
        h[:addr]        = axis_axi4_wr_inf_seq
        h[:max_length]  = 2048
        h[:axis_in]     = seq_tail_stream
        h[:axi_wr]      = axi4m
    end
    #
    ## axi4 read
    # Def().axi_stream(name:"axis_axi4_rd_inf",clock:axis_in.aclk,reset:axis_in.aresetn,dsize:axis_in.DSIZE)
    axi_stream_inf(clock:axis_in.aclk,reset:axis_in.aresetn,dsize:axis_in.DSIZE) - 'axis_axi4_rd_inf'
    # axis_axi4_rd_inf.direct(up_stream:sub_rx_inf[1])
    axis_direct.axis_direct_inst1 do |h|
        h.slaver        sub_rx_inf[1]
        h.master        axis_axi4_rd_inf
    end

    parse_big_field_table_A1.parse_big_field_table_A1_inst1 do |h| #(
        h.param.DSIZE           8
        h.param.FIELD_LEN       8     #//MAX 16*8 : byte-> row:16, col:8
        h.param.FIELD_NAME      "Big Filed"
        h.param.TRY_PARSE       "OFF"
        h.port.input.enable
        h.port.output.logic['DSIZE-1:0'].value  logic[64].axis_axi4_rd_inf_seq        
        h.port.output.logic.out_valid           logic.axis_axi4_rd_inf_seq_vld
        h.port.axi_stream_inf.slaver.cm_tb_s    axis_axi4_rd_inf
        h.port.axi_stream_inf.master.cm_tb_m    seq_tail_stream
        h.port.axi_stream_inf.mirror.cm_mirror  axis_axi4_rd_inf
    end

    Instance(:odata_pool_axi4_A1,"odata_pool_axi4_A1_inst") do |h|
        # h[:source_addr] = axis_axi4_rd_inf.seq(0,4)
        # h[:size]        = axis_axi4_rd_inf.seq(4,4)
        h[:source_addr] = axis_axi4_rd_inf_seq[63,32]
        h[:size]        = axis_axi4_rd_inf_seq[31,0]
        h[:out_axis]    = rd_rel_axis.copy
        h[:valid]       = axis_axi4_rd_inf_seq_vld
        h[:axi_master]  = axi4m
    end

    rd_rel_axis << odata_pool_axi4_A1_inst[:out_axis]

    ## axi4 lite wr
    # Def().axi_stream(name:"axis_lite_wr_inf",clock:axis_in.aclk,reset:axis_in.aresetn,dsize:axis_in.DSIZE)
    axi_stream_inf(clock:axis_in.aclk,reset:axis_in.aresetn,dsize:axis_in.DSIZE) - 'axis_lite_wr_inf'

    # axis_lite_wr_inf.direct(up_stream:sub_rx_inf[2])
    axis_direct.axis_direct_inst2 do |h|
        h.slaver        sub_rx_inf[2]
        h.master        axis_lite_wr_inf
    end

    Instance(:axis_to_lite_wr,"axi4_to_lite_wr_inst") do |h|
        h[:DUMMY]   = 8
        h[:axis_in] = axis_lite_wr_inf
        h[:lite]    = lite
    end

    ## axi4 lite rd
    # Def().axi_stream(name:"axis_lite_rd_inf",clock:axis_in.aclk,reset:axis_in.aresetn,dsize:axis_in.DSIZE)
    axi_stream_inf(clock:axis_in.aclk,reset:axis_in.aresetn,dsize:axis_in.DSIZE) -  'axis_lite_rd_inf'
    # axis_lite_rd_inf.direct(up_stream:sub_rx_inf[3])
    axis_direct.axis_direct_inst3 do |h|
        h.slaver        sub_rx_inf[3]
        h.master        axis_lite_rd_inf
    end

    Instance(:axis_to_lite_rd,"axis_to_lite_rd_inst") do |h|
        h[:DUMMY]       = 4
        h[:axis_in]     = axis_lite_rd_inf
        h[:lite]        = lite
        h[:rd_rel_axis] = rd_rel_axis.copy
    end

    rd_rel_axis << axis_to_lite_rd_inst[:rd_rel_axis]

end

new_m.gen_sv_module
