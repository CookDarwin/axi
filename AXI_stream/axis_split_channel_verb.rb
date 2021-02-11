## VERB
## - insert copy first
require_sdl 'axis_insert_copy.rb'
TdlBuild.axis_split_channel_verb(__dir__) do 
    input[16]               - 'split_len'       # 1:need 1 size ; split len must large than 2
    port.axis.slaver        - 'origin_inf'
    port.axis.master        - 'first_inf'
    port.axis.master        - 'end_inf'

    origin_inf.clock_reset_taps('clock','rst_n')
    logic[16]       - 'insert_seed'
    Assign do 
        insert_seed <= split_len - 1.b1 
    end

    axis_insert_copy.axis_insert_copy_inst do |h|
        h.input[16].insert_seed         insert_seed ## 0 need first
        h.input[8].insert_len           8.d1  ## 1 need 1 len
        h.port.axis.slaver.in_inf       origin_inf  ## length of in_inf must be large than 2
        h.port.axis.master.out_inf      origin_inf.copy(name: 'origin_inf_insert')
    end

    common_fifo.common_fifo_head_bytesx_inst do |h| #(
        h.param.DEPTH   4  
        h.param.DSIZE   16 
        h.input.clock                       clock
        h.input.rst_n                       rst_n
        h.input['DSIZE'].wdata              split_len
        h.input.wr_en                       "#{(origin_inf.axis_tcnt == 0.A )} && #{origin_inf.vld_rdy }".to_nq
        h.output.logic['DSIZE'].rdata       logic[16].next_split_len
        h.input.rd_en                       origin_inf_insert.vld_rdy_last
    end


    axi_stream_split_channel.axi_stream_split_channel_inst do |h|
        h.input[16].split_len              next_split_len # 1:need 1 size ; split len must large than 2
        h.port.axis.slaver.origin_inf      origin_inf_insert 
        h.port.axis.master.first_inf       first_inf 
        h.port.axis.master.end_inf         end_inf 
    end

end