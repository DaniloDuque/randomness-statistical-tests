using Distributions
using Plots
using Printf

# ------------------------------------------------------------
# Plot: Observed vs Expected Poker Frequencies
# ------------------------------------------------------------
function plot_poker_frequencies(f_obs::Vector{Int},
                                f_exp::Vector{Float64};
                                filename::String = "poker_test_frequencies.png")

    labels = [
        "All Different",
        "One Pair",
        "Two Pairs",
        "Three of a Kind",
        "Full House",
        "Four of a Kind",
        "Five of a Kind"
    ]

    p = bar(
        labels,
        f_obs,
        label = "Observed",
        title = "Poker Test — Observed vs Expected Frequencies",
        ylabel = "Frequency",
        xlabel = "Hand category",
        alpha = 0.8,
        legend = :topright,
        rotation = 20
    )

    bar!(labels, f_exp, label = "Expected", alpha = 0.6)

    savefig(p, filename)
end


# ------------------------------------------------------------
# Poker Test — Uniform [0,1)
# ------------------------------------------------------------
function poker_test_uniform(sample::Vector{Float64};
                            α::Float64 = 0.05,
                            prefix::String = "poker_test")

    println("DEBUG: Starting poker_test_uniform")
    println("DEBUG: sample type = ", typeof(sample))
    println("DEBUG: α type = ", typeof(α))
    println("DEBUG: prefix type = ", typeof(prefix))

    # --------------------------------------------------------
    # Step 1: Observed frequencies
    # --------------------------------------------------------
    f_obs = zeros(Int, 7)

    for number_val in sample
        str_representation = string(number_val)
        if !occursin(".", str_representation)
            continue
        end

        decimal_part = split(str_representation, ".")[2]

        # TAKE FIRST 5 DIGITS SAFELY (NO `end` MISUSE)
        available_digits = min(length(decimal_part), 5)
        if available_digits == 0
            continue
        end
        digit_array = [decimal_part[position] for position in 1:available_digits]

        while length(digit_array) < 5
            push!(digit_array, '0')
        end

        digit_counts = Dict{Char, Int}()
        for digit_char in digit_array
            digit_counts[digit_char] = get(digit_counts, digit_char, 0) + 1
        end

        count_values = sort(collect(values(digit_counts)), rev = true)

        if count_values == [5]
            f_obs[7] += 1
        elseif count_values == [4, 1]
            f_obs[6] += 1
        elseif count_values == [3, 2]
            f_obs[5] += 1
        elseif count_values == [3, 1, 1]
            f_obs[4] += 1
        elseif count_values == [2, 2, 1]
            f_obs[3] += 1
        elseif count_values == [2, 1, 1, 1]
            f_obs[2] += 1
        else
            f_obs[1] += 1
        end
    end

    sample_size = length(sample)
    println("DEBUG: n = ", sample_size, ", type = ", typeof(sample_size))

    # --------------------------------------------------------
    # Step 2: Expected probabilities
    # --------------------------------------------------------
    p_exp = [
        0.3024,  # All different
        0.5040,  # One pair
        0.1080,  # Two pairs
        0.0720,  # Three of a kind
        0.0090,  # Full house
        0.0045,  # Four of a kind
        0.0001   # Five of a kind
    ]

    f_exp = p_exp .* sample_size

    # --------------------------------------------------------
    # Step 3: Chi-square statistic
    # --------------------------------------------------------
    χ2 = sum(((f_obs[i] - f_exp[i])^2 / f_exp[i]) for i in 1:7)

    dof = 6
    χ2_critical = quantile(Chisq(dof), 1 - α)
    p_value = 1 - cdf(Chisq(dof), χ2)

    passed = χ2 ≤ χ2_critical

    # --------------------------------------------------------
    # Step 4: Plot
    # --------------------------------------------------------
    plot_poker_frequencies(
        f_obs,
        f_exp;
        filename = "$(prefix)_frequencies.png"
    )

    # --------------------------------------------------------
    # Step 5: Terminal table
    # --------------------------------------------------------
    println()
    println("┌────────────────────────────────────────────────────────────────────┐")
    println("│        Poker Test — Uniform.                                       │")
    println("├──────────────────────────────┬─────────────────────────────────────┤")
    println(rpad("│ Significance level α", 31), "│ ", lpad(string(α), 35), " │")
    println(rpad("│ Sample size n", 31), "│ ", lpad(string(sample_size), 35), " │")
    println(rpad("│ χ² statistic", 31), "│ ", lpad(@sprintf("%.6f", χ2), 35), " │")
    println(rpad("│ χ² critical", 31), "│ ", lpad(@sprintf("%.6f", χ2_critical), 35), " │")
    println(rpad("│ p-value", 31), "│ ", lpad(@sprintf("%.6f", p_value), 35), " │")
    println("├──────────────────────────────┼─────────────────────────────────────┤")
    println(rpad("│ Decision", 31), "│ ",
            lpad(passed ? "ACCEPT H₀" : "REJECT H₀", 35), " │")
    println("├──────────────────────────────┼─────────────────────────────────────┤")
    println(rpad("│ Saved plot", 31), "│ ",
            lpad("$(prefix)_frequencies.png", 35), " │")
    println("└──────────────────────────────┴─────────────────────────────────────┘")
    println()

    return nothing
end
