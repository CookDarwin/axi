
require_hdl 'axi_stream_interconnect_S2M.sv'

TdlBuild.axi_stream_split_channel(__dir__) do 
    input[16]               - 'split_len'       # 1:need 1 size ; split len must large than 2
    port.axis.slaver        - 'origin_inf'
    port.axis.master        - 'first_inf'
    port.axis.master        - 'end_inf'

    same_clock_domain(origin_inf, first_inf, end_inf)

    origin_inf.clock_reset_taps('clock','rst_n')

    logic   - 'addr'
    logic   - 'new_last'

    always_ff(posedge.clock, negedge.rst_n) do 
        IF ~rst_n do 
            addr        <= 1.b0 
            new_last    <= 1.b0
        end
        ELSE do 
            new_last    <= (origin_inf.axis_tcnt == (split_len - 2)).and(origin_inf.vld_rdy)

            IF origin_inf.vld_rdy_last do 
                addr    <= 1.b0 
            end
            ELSIF (origin_inf.axis_tcnt == (split_len - 1)).and(origin_inf.vld_rdy) do 
                addr    <= 1.b1
            end 
            ELSE do 
                addr    <= addr 
            end
        end
    end

    axi_stream_interconnect_S2M.axi_stream_interconnect_S2M_inst do |h| #(
        h.param.NUM             2
        h.input.addr            addr 
        h.port.axis.slaver.s00          origin_inf.copy(name: 'origin_inf_add_last')  
        h.port.axis.master.m00          origin_inf.copy(name: 'sub_origin_inf', dimension:[2])     
    end

    Assign do 
        origin_inf_add_last.axis_tdata      <= origin_inf.axis_tdata
        origin_inf_add_last.axis_tvalid     <= origin_inf.axis_tvalid 
        origin_inf_add_last.axis_tuser      <= origin_inf.axis_tuser 
        origin_inf_add_last.axis_tkeep      <= origin_inf.axis_tkeep
        origin_inf_add_last.axis_tlast      <= origin_inf.axis_tlast | new_last
        origin_inf.axis_tready              <= origin_inf_add_last.axis_tready
    end

    first_inf   << sub_origin_inf[0]
    end_inf     << sub_origin_inf[1]

end