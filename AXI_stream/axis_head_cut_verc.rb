## VERC 非整数型剪切,使用 right shift 
require_hdl 'axis_connect_pipe_right_shift_verb.sv'

TdlBuild.axis_head_cut_verc(__dir__) do 
    parameter.BYTE_BITS     8
    input[10]               - 'bytes'       # BEFORE    origin valid, and keep value when valid
    port.axis.slaver        - 'origin_inf'
    port.axis.master        - 'out_inf'

    localparam.DX   (origin_inf.DSIZE / param.BYTE_BITS)

    Initial do 
        assert(param.DX < 17, "param.DX<%0d> !< 17",param.DX)
    end


    origin_inf.clock_reset_taps('clock', 'rst_n')

    axis_slaver_pipe_A1.axis_slaver_pipe_A1_inst do |h| #(
        h.param.DEPTH               3
        h.port.axis.slaver.axis_in      origin_inf
        h.port.axis.master.axis_out     origin_inf.copy(name: 'origin_inf_post')
    end 

    ## 解析编码
    logic[4]        - 'bytes_x'
    logic[4]        - 'bytes_x_Q'
    logic[4]        - 'bytes_x_tmp'
    logic[4]        - 'bytes_x_sub_nDx'
    logic[2]        - 'route_addr'

    logic[4]        - 'bytes_y'
    logic[10]       - 'tmp_loop'

    # genvar - 'cc'

    always_comb() do  
        # FOREACH(tmp_loop) do |ii|
        #     IF bytes < "#{param.DX}*(10-#{ii})".to_nq do 
        #         bytes_x_tmp <= (10-1-ii)
        #     end
        # end
        bytes_x_tmp <= 0.A
        FOR(start: 0,stop: 10) do |ii|
            IF bytes < "#{param.DX}*(10-#{ii})".to_nq do 
                bytes_x_tmp <= (10-1-ii)
            end
        end
    end

    always_ff(posedge.clock ,negedge.rst_n) do 
        IF ~rst_n do 
            bytes_x             <= 0.A 
            bytes_x_Q           <= 0.A 
            bytes_x_sub_nDx     <= 0.A
        end 
        ELSE do 
            bytes_x             <= bytes_x_tmp
            bytes_x_Q           <= bytes_x
            bytes_x_sub_nDx     <= bytes - bytes_x*param.DX
        end
    end

    always_ff(posedge.clock, negedge.rst_n) do 
        IF ~rst_n do 
            route_addr  <= 0.A 
        end
        ELSE do 
            IF bytes == 0.A do 
                route_addr  <= 2.d0 
            end
            ELSIF bytes_x == 0.A do 
                route_addr  <= 2.d2
            end
            ELSIF bytes_x_sub_nDx == 0.A do 
                route_addr  <= 2.d1 
            end
            ELSE do 
                route_addr  <= 2.d1
            end 
        end
    end


    axi_stream_interconnect_S2M.axi_stream_interconnect_S2M_inst do |h| #(
        h.param.NUM                         3
        h.input['NSIZE'].addr               route_addr
        h.port.axis.slaver.s00              origin_inf_post
        h.port.axis.master.m00              origin_inf.copy(name: 'sub_origin_inf', dimension:[3])
    end

    ## 不需要任何截取
    out_inf << sub_origin_inf[0]
    ## 整数倍截取，非整数倍截取
    logic   - 'fifo_wr_en'
    always_ff(posedge.clock, negedge.rst_n) do 
        IF ~rst_n do 
            fifo_wr_en  <= 1.b0 
        end
        ELSE do 
            fifo_wr_en  <= (origin_inf.axis_tcnt==0.A ).and( origin_inf.vld_rdy)
        end
    end 

    common_fifo.common_fifo_head_bytesx_inst do |h| #(
        h.param.DEPTH   4  
        h.param.DSIZE   4   
        h.input.clock                       clock
        h.input.rst_n                       rst_n
        h.input['DSIZE'].wdata              bytes_x
        h.input.wr_en                       "#{fifo_wr_en} && (#{bytes_x}!= '0)".to_nq
        h.output.logic['DSIZE'].rdata       logic[4].int_cut_len
        h.input.rd_en                       sub_origin_inf[1].vld_rdy_last
    end

    axis_head_cut_verb.axis_head_cut_verb_inst do |h|
        h.input[16].length              logic_bind_(12.d0, int_cut_len)
        h.port.axis.slaver.axis_in      sub_origin_inf[1]
        h.port.axis.master.axis_out     origin_inf.copy(name: 'origin_inf_ss')
    end

    origin_inf.copy(name: 'origin_inf_cut_mix')
    
    origin_inf_cut_mix  << origin_inf_ss
    origin_inf_cut_mix  << sub_origin_inf[2]





    ## dout 

    axis_append_A1.axis_append_A1_inst do |h| #(
        h.param.MODE            "END"
        h.param.DSIZE           out_inf.DSIZE
        h.param.HEAD_FIELD_LEN      1     #//MAX 16*8
        h.param.HEAD_FIELD_NAME     "HEAD Filed"
        h.param.END_FIELD_LEN       1     #//MAX 16*8
        h.param.END_FIELD_NAME      "END Filed"
        h.input.enable              1.b1 
        h.input['END_FIELD_LEN*DSIZE'].end_value        0.A 
        h.port.axis.slaver.origin_in                    origin_inf_cut_mix
        h.port.axis.master.append_out                   origin_inf.copy(name: 'origin_inf_ss_E0')
    end

    logic[4] - 'shift_sel_pre'
    Assign do 
        shift_sel_pre   <= param.DX-bytes_x_sub_nDx
    end
    common_fifo.common_fifo_head_nDx_inst do |h| #(
        h.param.DEPTH   4  
        h.param.DSIZE   4   
        h.input.clock                       clock
        h.input.rst_n                       rst_n
        h.input['DSIZE'].wdata              shift_sel_pre
        h.input.wr_en                       fifo_wr_en.latency(clock: clock, reset: rst_n, count: 2)
        h.output.logic['DSIZE'].rdata       logic[4].shift_sel
        h.input.rd_en                       origin_inf_ss_E0.vld_rdy_last
    end

    axis_connect_pipe_right_shift_verb.axis_connect_pipe_right_shift_verb_inst do |h| #(
        h.param.SHIFT_BYTE_BIT      param.BYTE_BITS
        h.param.SNUM                param.DX
        h.input['$clog2(SNUM+1)'].shift_sel     shift_sel # // sync axis_in.axis_tvalid
        h.port.axis.slaver.axis_in              origin_inf_ss_E0    
        h.port.axis.master.axis_out             origin_inf.copy(name: 'origin_inf_ss_E0_CH')
    end

    axis_head_cut_verb.last_cut_inst do |h|
        h.input[16].length              16.d1
        h.port.axis.slaver.axis_in      origin_inf_ss_E0_CH
        h.port.axis.master.axis_out     out_inf.branch  
    end
        
end