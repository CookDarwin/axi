add_to_tdl_paths __dir__ 
require_sdl 'data_inf_partition.rb'

TdlBuild.axi4_partition_rd_verb(__dir__) do 
    parameter.PSIZE         128
    port.axi4.slaver_rd     - 'long_inf'
    port.axi4.master_rd     - 'short_inf'

    long_inf.clock_reset_taps('clock','rst_n')

    data_inf_c(clock: clock,reset: rst_n,dsize: "#{long_inf.IDSIZE}+#{long_inf.LSIZE}+#{long_inf.ASIZE}".to_nq)    - 'pre_partition_data_inf'
    data_inf_c(clock: clock,reset: rst_n,dsize: "#{short_inf.IDSIZE}+#{long_inf.LSIZE}+#{long_inf.ASIZE}".to_nq)   - 'post_partition_data_inf'
    data_inf_c(clock: clock,reset: rst_n,dsize: 1)    - 'partition_pulse_inf'
    data_inf_c(clock: clock,reset: rst_n,dsize: 1)    - 'wait_last_inf'

    data_inf_partition.data_inf_partition_inst do |h|
        h.param.PLEN                        param.PSIZE 
        h.param.IDSIZE                      long_inf.IDSIZE
        h.param.LSIZE                       long_inf.LSIZE 
        h.param.ADDR_STEP                   long_inf.ADDR_STEP
        h.port.data_inf_c.slaver.data_in                pre_partition_data_inf  #[in ID..][ADDR...][LENGTH| LSIZE-1:0] length `0 mean 1
        h.port.data_inf_c.master.data_out               post_partition_data_inf #[out ID 4bit][in ID..][LENGTH| LSIZE-1:0]
        h.port.data_inf_c.master.partition_pulse_inf    partition_pulse_inf  
        h.port.data_inf_c.master.wait_last_inf          wait_last_inf  
    end

    Assign do 
        pre_partition_data_inf.data     <= logic_bind_(long_inf.axi_arid,long_inf.axi_araddr,long_inf.axi_arlen)
        pre_partition_data_inf.valid    <= long_inf.axi_arvalid
        long_inf.axi_arready            <= pre_partition_data_inf.ready
        
        logic_bind_(short_inf.axi_arid,short_inf.axi_araddr,short_inf.axi_arlen)   <= post_partition_data_inf.data 
        short_inf.axi_arvalid           <= post_partition_data_inf.valid
        post_partition_data_inf.ready   <= short_inf.axi_arready 

    end

    common_fifo.common_fifo_inst do |h|
        h.param.DEPTH       6
        h.param.DSIZE       1
        h.input.clock                   clock
        h.input.rst_n                   rst_n
        h.input['DSIZE'].wdata          partition_pulse_inf.data
        h.input.wr_en                   partition_pulse_inf.vld_rdy
        h.output['DSIZE'].rdata         ''.to_nq
        h.input.rd_en                   short_inf.axi_rvalid & short_inf.axi_rready & short_inf.axi_rlast
        h.output.logic.empty            debugLogic.fifo_empty
        h.output.logic.full             debugLogic.fifo_full
    end

    Assign do 
        partition_pulse_inf.ready   <= ~fifo_full
    end

    Assign do 
        short_inf.axi_arsize    <= long_inf.axi_arsize 
        short_inf.axi_arburst   <= long_inf.axi_arburst
        short_inf.axi_arlock    <= long_inf.axi_arlock 
        short_inf.axi_arcache   <= long_inf.axi_arcache
        short_inf.axi_arprot    <= long_inf.axi_arprot 
        short_inf.axi_arqos     <= long_inf.axi_arqos  
        long_inf.axi_rid        <= short_inf.axi_rid[long_inf.IDSIZE-1,0]
        long_inf.axi_rdata      <= short_inf.axi_rdata  
        long_inf.axi_rresp      <= short_inf.axi_rresp  
        long_inf.axi_rlast      <= short_inf.axi_rlast  & fifo_empty
        long_inf.axi_rvalid     <= short_inf.axi_rvalid 
        short_inf.axi_rready    <= long_inf.axi_rready
    end

    always_ff(posedge.clock,negedge.rst_n) do 
        IF ~rst_n do 
            wait_last_inf.ready     <= 1.b0 
        end
        ELSE do 
            wait_last_inf.ready     <= long_inf.axi_rvalid & long_inf.axi_rready & long_inf.axi_rlast
            # wait_last_inf.ready     <= long_inf.axi_rvalid & long_inf.axi_rlast
        end
    end

end