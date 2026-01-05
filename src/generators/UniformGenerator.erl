-module(erlang_generator).
-export([main/1, generate_samples/2]).

main([NumSamplesStr, OutputFile]) ->
    NumSamples = list_to_integer(NumSamplesStr),
    generate_samples(NumSamples, OutputFile),
    halt(0);
main(_) ->
    io:format("Usage: escript erlang_generator.erl <num_samples> <output_file>~n"),
    halt(1).

generate_samples(NumSamples, OutputFile) ->
    {ok, File} = file:open(OutputFile, [write]),
    write_samples(File, NumSamples),
    file:close(File),
    io:format("Generated ~p samples in ~s~n", [NumSamples, OutputFile]).

write_samples(_File, 0) -> ok;
write_samples(File, N) ->
    Value = rand:uniform(), % [0,1)
    io:format(File, "~.15f~n", [Value]),
    write_samples(File, N - 1).