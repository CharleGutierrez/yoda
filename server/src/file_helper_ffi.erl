-module(file_helper_ffi).
-export([append_log/2, read_tail/2]).

append_log(FilenameBin, LineBin) ->
    Filename = binary_to_list(FilenameBin),
    file:write_file(Filename, <<LineBin/binary, "\n">>, [append]),
    nil.

read_tail(FilenameBin, MaxLines) ->
    Filename = binary_to_list(FilenameBin),
    case file:read_file(Filename) of
        {ok, Bin} ->
            Lines = binary:split(Bin, <<"\n">>, [global, trim_all]),
            Len = length(Lines),
            Tail = if Len > MaxLines -> lists:nthtail(Len - MaxLines, Lines);
                      true -> Lines
                   end,
            Tail;
        _ -> []
    end.
