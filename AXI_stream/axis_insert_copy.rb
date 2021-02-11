

TdlBuild.axis_insert_copy(__dir__) do 
    input[16]               - 'insert_seed'     ## 0 need first
    input[8]                - 'insert_len'      ## 1 need 1 len
    port.axis.slaver        - 'in_inf'          ## length of in_inf must be large than 2
    port.axis.master        - 'out_inf'

    in_inf.clock_reset_taps('clock', 'rst_n')

    logic       - 'insert_tri'
    in_inf.copy(name: 'in_inf_valve')
    # axis_valve.axis_valve_inst do |h|
    #     h.input.button                  ~insert_tri#        //[1] OPEN ; [0] CLOSE
    #     h.port.axis.slaver.axis_in      in_inf
    #     h.port.axis.master.axis_out     in_inf.copy(name: 'in_inf_valve')
    # end 

    Assign do 
        in_inf_valve.axis_tdata     <= in_inf.axis_tdata
        in_inf_valve.axis_tvalid    <= in_inf.axis_tvalid | insert_tri
        in_inf_valve.axis_tuser     <= in_inf.axis_tuser 
        in_inf_valve.axis_tkeep     <= in_inf.axis_tkeep 
        in_inf.axis_tready          <= in_inf_valve.axis_tready & (~insert_tri)
        in_inf_valve.axis_tlast     <= in_inf.axis_tlast & (~insert_tri)
    end

    # logic   - 'insert_tri_zero_en'

    always_ff(posedge.clock, negedge.rst_n) do 
        IF ~rst_n do 
            insert_tri <= 1.b0 
            # insert_tri_zero_en  <= 1.b1
        end 
        ELSE do 
            IF insert_seed == 0.A do 
                IF in_inf.vld_rdy_last do 
                    insert_tri  <= 1.b1 
                end
                ELSIF in_inf.vld_rdy do 
                    insert_tri  <= (in_inf_valve.axis_tcnt >= insert_len - 1.b1 )
                end
                ELSE do 
                    insert_tri  <= insert_tri
                end
            end
            ELSE do 
                insert_tri <= (in_inf_valve.axis_tcnt >= insert_seed - 1.b1 ).and(in_inf_valve.vld_rdy).and(in_inf_valve.axis_tcnt < insert_seed + insert_len - 1.b1).and( ~in_inf.axis_tlast)
            end
        end
    end

    axis_connect_pipe.axis_connect_pipe_inst do |h|
        h.port.axis.slaver.axis_in          in_inf_valve
        h.port.axis.master.axis_out         out_inf
    end 
    

end