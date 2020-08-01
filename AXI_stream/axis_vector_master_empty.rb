TdlBuild.axis_vector_master_empty(__dir__) do 
    parameter.NUM                    8
    port.axis.master[param.NUM ]   - 'master_vector'

    generate(param.NUM) do |kk|
        axis_master_empty.axis_master_empty_inst do |h|
            h.master    master_vector[kk]
        end
    end

end