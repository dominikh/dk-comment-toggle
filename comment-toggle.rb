module Diakonos
  class Buffer
    # Comments or uncomments the currently selected lines. If all
    # lines are commented, uncomment them, otherwise comment all
    # lines. If no lines are selected, append a comment.
    def comment_uncomment
      take_snapshot

      # get characters for commenting
      comment_begin = @settings["lang.#{@language}.comment_string"].to_s
      comment_end   = @settings["lang.#{@language}.comment_close_string"].to_s

      # append a comment if nothing is selected
      if not selecting?
        # TODO: dont append a comment if we already have one appended
        line = selected_lines[0]
        line << "#{comment_begin} "
        line << comment_end unless comment_end.empty?
      else
        mark = selection_mark
        row  = @last_row

        # determine whether the selection already is commented
        uncomment = true
        selected_lines.each do |line|
          uncomment = (line =~ /^\s*#{comment_begin}.+#{comment_end}/)
          break unless uncomment
        end

        # calculate the indentation by which to comment
        unless uncomment
          smallest_indentation = (selected_lines.map do |line|
                                    line =~ /^(\s*)/
                                    $1.length
                                  end.min)
        end

        selected_lines.each do |line|
          if uncomment
            line.gsub!(/^(\s*)#{comment_begin}(.+)#{comment_end}/, "\\1\\2")
          else
            line.gsub!(/^(\s{#{smallest_indentation}})(\s*)(.+)/, "\\1#{comment_begin}\\2\\3#{comment_end}")
          end
        end
      end

      # move the cursor to the right position
      if mark
        if row == mark.start_row
          x = mark.start_col
        else
          if uncomment
            x = mark.end_col - comment_begin.length - comment_end.length
          else
            x = mark.end_col + comment_begin.length + comment_end.length
          end
        end
        cursor_to(row, x)
      else
        cursor_to(@last_row, @lines[@last_row].length)
      end

      remove_selection
      set_modified
    end
  end
end

module Diakonos
  module Functions
    def comment_uncomment
      @current_buffer.comment_uncomment
    end
  end
end
