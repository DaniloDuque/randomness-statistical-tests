#!/usr/bin/env swipl

:- initialization(main, main).

lcg(Seed, Next) :-
    A = 1103515245,
    C = 12345,
    M = 2147483648,
    Next is (A * Seed + C) mod M.

generate_numbers(_, 0, []).
generate_numbers(Seed, N, [Num|Rest]) :-
    N > 0,
    lcg(Seed, NextSeed),
    RawNum is NextSeed / 2147483648,
    lcg(NextSeed, Seed2),
    Extra is Seed2 / 2147483648,
    Num is (RawNum + Extra) / 2,
    N1 is N - 1,
    generate_numbers(Seed2, N1, Rest).

format_number(Num, Formatted) :-
    format(atom(Formatted), '~15f', [Num]).

write_numbers(_, []).
write_numbers(Stream, [H|T]) :-
    format_number(H, Formatted),
    writeln(Stream, Formatted),
    write_numbers(Stream, T).

generate_samples(NumSamples, OutputFile) :-
    get_time(Time),
    Seed is round(Time * 1000000) mod 2147483648,
    generate_numbers(Seed, NumSamples, Numbers),
    open(OutputFile, write, Stream),
    writeln(Stream, NumSamples),
    writeln(Stream, '0 1'),
    write_numbers(Stream, Numbers),
    close(Stream),
    format('Generated ~w samples in ~w~n', [NumSamples, OutputFile]).

main(Argv) :-
    (   length(Argv, 2)
    ->  nth0(0, Argv, NumSamplesStr),
        nth0(1, Argv, OutputFile),
        atom_number(NumSamplesStr, NumSamples),
        generate_samples(NumSamples, OutputFile),
        halt(0)
    ;   writeln('Usage: swipl prolog_generator.pl <num_samples> <output_file>'),
        halt(1)
    ).