# require_relative "../prj_lib"

## raise TdlError.new("The module have be abandon\n    Path:[#{__dir__}]\n    Name:[#{__FILE__}]")

new_m = SdlModule.new(name:File.basename(__FILE__,".rb"),out_sv_path:__dir__)

# Parameter :ADDR_STEP,1.0
new_m.instance_exec do
    Input :addr,dsize:32
    Input :max_length,dsize:32
    # AxiStream().slaver :axis_in
    # Axi4().master_wr   :axi_wr

    port.axis.slaver    - 'axis_in'
    port.axi4.master_wr -  'axi_wr'

    ADDR_STEP = axi_wr.ADDR_STEP


    Def().logic(name:"addr_cur",dsize:32)

    axis_region = {clock:axis_in.aclk,reset:axis_in.aresetn,dsize:axis_in.dsize}

    self.ex_up_code =
%Q{
//int     MAX_LENGTH;
//assign     MAX_LENGTH     =   (axis_in.DSIZE <= 8)?  2**11 :
//                                (axis_in.DSIZE <= 16)? 2**10 :
//                                (axis_in.DSIZE <= 32)? 2**9  :
//                                (axis_in.DSIZE <= 64)? 2**8  :
//                                (axis_in.DSIZE <= 128)? 2**7 :
//                                (axis_in.DSIZE <= 256)? 2**6 :
//                                (axis_in.DSIZE <= 512)? 2**5 :  2**4;

initial begin
    assert(#{axis_in}.DSIZE == #{axi_wr}.DSIZE)
    else begin
        $error("STREAM DSIZE should eql AXI4 DSIZE");
        $finish;
    end
//    assert(#{axi_wr}.LSIZE >= $clog2(MAX_LENGTH))
//    else begin
//        $error("AXIS LSIZE is too smaller");
//        $finish;
//    end
end
}

    # split_out = AxiStream.axis_length_split_with_addr(
    #     addr_step:ADDR_STEP,
    #     length:max_length,
    #     up_stream:axis_in,
    #     origin_addr:addr,
    #     band_addr:addr_cur,
    #     belong_to_module:self
    # )

    axis_length_split_with_addr.axis_length_split_with_addr_inst do |h|
        h.param.ADDR_STEP       ADDR_STEP      #//1024 := 1
        h.input[32].origin_addr addr
        h.input[32].length      max_length
        h.output.logic[32].band_addr        addr_cur     
        h.port.axi_stream_inf.slaver.axis_in     axis_in
        h.port.axi_stream_inf.master.axis_out    axis_in.copy(name: 'split_out')
    end


# packet_fifo = Tdl.inst_axi_stream_packet_fifo(
#         depth:4,
#         # esize:32,
#         # info_in:    addr_cur,
#         # info_out:   {name:"burst_addr",dsize:32},
#         axis_in:    split_out,
#         axis_out:   {clock:axi_wr.axi_aclk,reset:axi_wr.axi_aresetn,dsize:axi_wr.dsize})

    packet_fifo =  Instance(:axi_stream_long_fifo,"axi_stream_long_fifo_inst") do |h|
        h[:DEPTH]       =   8
        h[:BYTE_DEPTH]  =   8192
        h[:axis_in]     =   split_out
        h[:axis_out]    =   axis_in.copy(name:"long_fifo_axis_out",clock:axi_wr.axi_aclk,reset:axi_wr.axi_aresetn)
    end

    Def().logic(name: :id,dsize:axi_wr.idsize)
    Def().logic(name: :addr_s,dsize:axi_wr.asize)
    Def().logic(name: :len_s,dsize:axi_wr.lsize)

    Instance(:independent_clock_fifo,"independent_clock_fifo_inst") do |h|
        h[:DEPTH]       = 4
        h[:DSIZE]       = "#{axi_wr.idsize} + #{axi_wr.asize} + #{axi_wr.lsize}".to_nq
        h[:wr_clk]      = axis_in.aclk
        h[:wr_rst_n]    = axis_in.aresetn
        h[:rd_clk]      = axi_wr.axi_aclk
        h[:rd_rst_n]    = axi_wr.axi_aresetn
        h[:wdata]       = "{#{id},#{addr_s},#{len_s}}".to_nq
        h[:wr_en]       = packet_fifo[:axis_in].vld_rdy_last
        h[:rdata]       = Def().logic(name:"fifo_rdata",dsize:"#{axi_wr.idsize} + #{axi_wr.asize} + #{axi_wr.lsize}")
        h[:rd_en]       = Def().logic(name:'rd_en')
        h[:empty]       = Def().logic(name:'fifo_empty')
        h[:full]        = Def().logic(name:'fifo_full')
    end

    axi4_wr_auxiliary = Instance(:axi4_wr_auxiliary_gen_without_resp,"axi4_wr_auxiliary_gen_without_resp_inst") do |h|
        h[:stream_en]       = Def().logic(name:"stream_en")
        # h[:id_add_len_in]   = Def().axi_stream(name:"id_add_len_in",clock:axi_wr.axi_aclk,reset:axi_wr.axi_aresetn,dsize:"#{axi_wr.idsize} + #{axi_wr.asize} + #{axi_wr.lsize}")
        h[:id_add_len_in]   = axi_stream_inf(clock:axi_wr.axi_aclk,reset:axi_wr.axi_aresetn,dsize:"#{axi_wr.idsize} + #{axi_wr.asize} + #{axi_wr.lsize}".to_nq).id_add_len_in
        h[:axi_wr_aux]      = axi_wr
    end


    Always(posedge:axis_in.aclk,negedge:axis_in.aresetn) do
        IF ~axis_in.aresetn do
            id <= 0
        end
        ELSIF split_out.vld_rdy_last do
            id <= id + 1
        end
        ELSE do
            id <= id
        end
    end

    Assign do
        addr_s  <= addr_cur
        len_s   <= split_out.axis_tcnt
        axi4_wr_auxiliary[:id_add_len_in].axis_tvalid   <= ~independent_clock_fifo_inst[:empty]
        axi4_wr_auxiliary[:id_add_len_in].axis_tdata    <= independent_clock_fifo_inst[:rdata]
        axi4_wr_auxiliary[:id_add_len_in].axis_tlast    <= "1'b1"
        independent_clock_fifo_inst[:rd_en]             <= axi4_wr_auxiliary[:id_add_len_in].axis_tready
    end

    # pipe_axis = AxiStream.axis_valve_with_pipe(button:axi4_wr_auxiliary[:stream_en],up_stream:packet_fifo[:axis_out])
    axis_valve_with_pipe.axis_valve_with_pipe_inst do |h|
        h.parameter.MODE            "BOTH"
        h.input.button              axi4_wr_auxiliary[:stream_en]         # //[1] OPEN ; [0] CLOSE
        h.axis_in                   packet_fifo[:axis_out]
        h.axis_out                  packet_fifo[:axis_out].copy(name: 'pipe_axis')
    end

    Assign do
        axi_wr.axi_wdata      <= pipe_axis.axis_tdata
        axi_wr.axi_wstrb      <= ~pipe_axis.axis_tkeep
        axi_wr.axi_wvalid     <= pipe_axis.axis_tvalid
        axi_wr.axi_wlast      <= pipe_axis.axis_tlast
        axi_wr.axi_bready     <= "1'b1".to_nq
        pipe_axis.axis_tready <= axi_wr.axi_wready
    end
end

new_m.gen_sv_module
