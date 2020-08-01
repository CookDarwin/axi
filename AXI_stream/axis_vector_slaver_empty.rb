TdlBuild.axis_vector_slaver_empty(__dir__) do 
    parameter.NUM                    8
    port.axis.slaver[param.NUM ]   - 'slaver_vector'

    generate(param.NUM) do |kk|
        axis_slaver_empty.axis_slaver_empty_inst do |h|
            h.slaver    slaver_vector[kk]
        end
    end

end