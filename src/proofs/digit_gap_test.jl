using Distributions
using Plots
using Printf

# ------------------------------------------------------------
# Extract decimal digits from sample
# ------------------------------------------------------------
function extract_digits(sample::Vector{Float64})::Vector{Char}
    digits = Char[]
    for num in sample
        str_num = string(num)
        if occursin(".", str_num)
            decimal_part = split(str_num, ".")[2]
            append!(digits, collect(decimal_part))
        end
    end
    return digits
end

# ------------------------------------------------------------
# Observed frequencies of gaps
# ------------------------------------------------------------
function get_observed_frequencies(digits::Vector{Char}, max_gap::Int)
    gap_counts = Dict{Char, Vector{Int}}()

    for d in '0':'9'
        gap_counts[d] = Int[]
        last_pos = nothing

        for (i, digit) in enumerate(digits)
            if digit == d
                if last_pos !== nothing
                    push!(gap_counts[d], i - last_pos - 1)
                end
                last_pos = i
            end
        end
    end

    fₒ = zeros(Int, max_gap + 2)

    for d in '0':'9'
        for gap in gap_counts[d]
            if gap <= max_gap
                fₒ[gap + 1] += 1
            else
                fₒ[max_gap + 2] += 1
            end
        end
    end

    total_gaps = sum(fₒ)
    return fₒ, total_gaps
end

# ------------------------------------------------------------
# Plot: Observed vs Expected frequencies
# ------------------------------------------------------------
function plot_digit_gap_frequencies(fₒ, fₑ; filename="digit_gap_frequencies.png")
    k = length(fₒ)
    labels = [string(i-1) for i in 1:k-1]
    push!(labels, "≥$(k-1)")

    p = bar(
        labels,
        fₒ,
        label = "Observed",
        title = "Digit Gap Test — Observed vs Expected Frequencies",
        xlabel = "Gap length",
        ylabel = "Frequency",
        alpha = 0.8
    )

    bar!(labels, fₑ, label = "Expected", alpha = 0.6)

    savefig(p, filename)
end

# ------------------------------------------------------------
# Digit Gap Test
# ------------------------------------------------------------
function digit_gap_test_uniform(sample::Vector{Float64};
                                α::Float64 = 0.05,
                                max_gap::Int = 6,
                                prefix::String = "digit_gap_test")

    digits = extract_digits(sample)
    fₒ, total_gaps = get_observed_frequencies(digits, max_gap)

    # Expected probabilities (geometric distribution)
    pₑ = zeros(Float64, max_gap + 2)
    for i in 0:max_gap
        pₑ[i + 1] = 0.1 * (0.9^i)
    end
    pₑ[end] = 0.9^(max_gap + 1)

    fₑ = pₑ * total_gaps

    # Chi-square statistic
    χ²₀ = sum((fₒ[i] - fₑ[i])^2 / fₑ[i] for i in eachindex(fₒ))

    df = length(fₒ) - 1
    χ²_critical = quantile(Chisq(df), 1 - α)
    p_value = 1 - cdf(Chisq(df), χ²₀)

    plot_digit_gap_frequencies(fₒ, fₑ;
        filename = "$(prefix)_frequencies.png")

    passed = χ²₀ ≤ χ²_critical

    # --------------------------------------------------------
    # Terminal table
    # --------------------------------------------------------
    println()
    println("┌────────────────────────────────────────────────────────────────────┐")
    println("│      Digit Gap Test — Uniform                                      │")
    println("├──────────────────────────────┬─────────────────────────────────────┤")
    println(rpad("│ Significance level α", 31), "│ ", lpad(string(α), 35), " │")
    println(rpad("│ Max gap grouped", 31), "│ ", lpad(string(max_gap), 35), " │")
    println(rpad("│ Total gaps", 31), "│ ", lpad(string(total_gaps), 35), " │")
    println(rpad("│ χ² statistic", 31), "│ ", lpad(@sprintf("%.6f", χ²₀), 35), " │")
    println(rpad("│ χ² critical", 31), "│ ", lpad(@sprintf("%.6f", χ²_critical), 35), " │")
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
