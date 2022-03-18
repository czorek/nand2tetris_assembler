module VM
  module PushWriter
    def write_push(command)
      case command.arg1
      when 'static'
        write_push_static(command)
      when 'constant'
        write_push_constant(command)
      when 'temp'
        write_push_temp(command)
      when 'pointer'
        write_push_pointer(command)
      else
        write_push_segment(command)
      end
    end

    def write_push_segment(command)
      segment = command.arg1
      index = command.arg2
      segment_pointer = POINTER_MAP.fetch(segment)

      <<~STR
        @#{index} // #{command.command_str}
        D=A
        @#{segment_pointer}
        A=D+M // address to push
        D=M // value to push
        #{push_and_increment_sp}
      STR
    end

    def write_push_temp(command)
      index = command.arg2

      <<~STR
        @#{index} // #{command.command_str}
        D=A
        @5
        A=D+A // address to push
        D=M // value to push
        #{push_and_increment_sp}
      STR
    end

    def write_push_pointer(command)
      index = command.arg2
      segment_pointer = POINTER_MAP.fetch(index)

      <<~STR
        @#{segment_pointer} // #{command.command_str}
        D=M
        #{push_and_increment_sp}
      STR
    end

    def write_push_constant(command)
      value = command.arg2

      <<~STR
        @#{value} // #{command.command_str}
        D=A
        #{push_and_increment_sp}
      STR
    end

    def write_push_static(command)
      index = command.arg2

      <<~STR
        @#{@filename}.#{index} // #{command.command_str}
        D=M
        #{push_and_increment_sp}
      STR
    end

    def push_and_increment_sp
      <<~STR
        @SP
        A=M
        M=D
        @SP
        M=M+1
      STR
    end
  end
end
