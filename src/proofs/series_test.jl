using Statistics, Distributions

"""
    create_number_pairs(numbers)::Vector{Tuple{Float64,Float64}}

Create pairs of consecutive numbers: (n₁, n₂), (n₂, n₃), ..., (nₙ₋₁, nₙ)
"""
function create_number_pairs(numbers::Vector{Float64})::Vector{Tuple{Float64,Float64}}
    pairs = Tuple{Float64,Float64}[]
    
    for i in 1:(length(numbers)-1)
        push!(pairs, (numbers[i], numbers[i+1]))
    end
    
    return pairs
end

"""
    assign_to_cell(pair::Tuple{Float64,Float64}, grid_size::Int)::Tuple{Int,Int}

Assign a pair (x,y) to a cell in an grid_size × grid_size grid.
Returns (row, column) indices (1-based).
"""
function assign_to_cell(pair::Tuple{Float64,Float64}, grid_size::Int)::Tuple{Int,Int}
    x, y = pair
    
    # Ensure x,y are in [0,1) (they should be for uniform distribution)
    x = clamp(x, 0.0, 0.999999)
    y = clamp(y, 0.0, 0.999999)
    
    # Calculate cell indices
    col = floor(Int, x * grid_size) + 1
    row = floor(Int, y * grid_size) + 1
    
    return (row, col)
end

"""
    series_test(numbers, grid_size=5; alpha=0.05)::NamedTuple

Perform the series test (runs test for 2D pairs).

# Arguments
- `numbers`: Vector of Float64 values in [0,1]
- `grid_size`: Number of cells along each axis (creates grid_size × grid_size grid)
- `alpha`: Significance level (default 0.05)

# Returns
- Named tuple with test results and statistics
"""
function series_test(numbers::Vector{Float64}, grid_size::Int=5; alpha::Float64=0.05)::NamedTuple
    
    n = length(numbers)
    pairs = create_number_pairs(numbers)
    n_pairs = length(pairs)
    
    println("="^60)
    println("PRUEBA DE SERIES")
    println("="^60)
    println("Tamaño de muestra: $n números")
    println("Pares formados: $n_pairs")
    println("Tamaño de cuadrícula: $(grid_size)×$(grid_size) = $(grid_size^2) celdas")
    println()
    
    # Step 1: Create grid and count frequencies
    grid = zeros(Int, grid_size, grid_size)
    
    for pair in pairs
        row, col = assign_to_cell(pair, grid_size)
        grid[row, col] += 1
    end
    
    # Step 2: Expected frequency
    expected_freq = n_pairs / (grid_size^2)
    
    # Step 3: Calculate chi-square statistic
    chi2_stat = 0.0
    
    println("FRECUENCIAS OBSERVADAS POR CELDA:")
    println("-"^40)
    
    # Display grid with frequencies
    for row in 1:grid_size
        row_str = ""
        for col in 1:grid_size
            freq = grid[row, col]
            row_str *= @sprintf("%4d ", freq)
            
            # Add to chi-square
            diff = freq - expected_freq
            chi2_stat += diff^2 / expected_freq
        end
        println("$(lpad(row, 2)): $row_str")
    end
    println()
    
    # Step 4: Display frequency table
    println("TABLA DETALLADA DE FRECUENCIAS:")
    println("-"^75)
    println(" Celda | Fila-Col |  fo   |   fe   | fo-fe  | (fo-fe)² | (fo-fe)²/fe")
    println("-"^75)
    
    cell_counter = 1
    for row in 1:grid_size
        for col in 1:grid_size
            fo = grid[row, col]
            fe = expected_freq
            diff = fo - fe
            diff_sq = diff^2
            chi2_contrib = diff_sq / fe
            
            cell_label = "$row-$col"
            
            @printf(" %4d | %7s | %5d | %7.4f | %7.4f | %9.4f | %11.4f\n",
                    cell_counter, cell_label, fo, fe, diff, diff_sq, chi2_contrib)
            
            cell_counter += 1
        end
    end
    
    @printf(" Total |         | %5d | %7.4f |        |           | %11.4f\n",
            sum(grid), sum(fill(expected_freq, grid_size^2)), chi2_stat)
    println("-"^75)
    println()
    
    # Step 5: Chi-square test
    df = grid_size^2 - 1  # degrees of freedom
    critical_value = quantile(Chisq(df), 1 - alpha)
    p_value = 1 - cdf(Chisq(df), chi2_stat)
    
    # Step 6: Display test results
    println("PRUEBA CHI-CUADRADO:")
    println("-"^40)
    println("χ² observado: $(round(chi2_stat, digits=6))")
    println("χ² crítico (α=$alpha, df=$df): $(round(critical_value, digits=6))")
    println("Valor p: $(round(p_value, digits=6))")
    println()
    
    passed = chi2_stat < critical_value
    
    if passed
        println("✓ DECISIÓN: Se ACEPTA H₀")
        println("  Los números sucesivos son independientes y uniformemente distribuidos")
    else
        println("✗ DECISIÓN: Se RECHAZA H₀")
        println("  Los números sucesivos NO son independientes o NO están uniformemente distribuidos")
    end
    
    println("="^60)
    
    # Return detailed results
    return (
        passed = passed,
        chi2_statistic = chi2_stat,
        critical_value = critical_value,
        p_value = p_value,
        degrees_of_freedom = df,
        grid_size = grid_size,
        n_pairs = n_pairs,
        expected_frequency = expected_freq,
        observed_grid = grid,
        pairs = pairs
    )
end

"""
    series_test_multiple_grids(numbers; grids=[3, 4, 5, 6], alpha=0.05)

Test with multiple grid sizes to be more robust.
"""
function series_test_multiple_grids(numbers::Vector{Float64}; 
                                   grids::Vector{Int}=[3, 4, 5, 6], 
                                   alpha::Float64=0.05)
    
    println("PRUEBA DE SERIES CON MÚLTIPLES TAMAÑOS DE CUADRÍCULA")
    println("="^60)
    
    results = []
    
    for grid_size in grids
        println("\n" * "="^60)
        println("Cuadrícula $(grid_size)×$(grid_size):")
        println("="^60)
        
        result = series_test(numbers, grid_size, alpha=alpha)
        push!(results, result)
    end
    
    # Summary
    println("\n" * "="^60)
    println("RESUMEN DE TODAS LAS PRUEBAS")
    println("="^60)
    
    passed_count = 0
    for (i, grid_size) in enumerate(grids)
        result = results[i]
        symbol = result.passed ? "✓" : "✗"
        println("$symbol $(grid_size)×$(grid_size): χ²=$(round(result.chi2_statistic, digits=3)), p=$(round(result.p_value, digits=4))")
        
        if result.passed
            passed_count += 1
        end
    end
    
    total_tests = length(grids)
    println("\nPruebas que pasan: $passed_count/$total_tests")
    
    if passed_count == total_tests
        println("✓ TODAS las pruebas indican independencia entre números sucesivos")
    elseif passed_count >= total_tests ÷ 2
        println("～ La mayoría de pruebas indican independencia")
    else
        println("✗ La mayoría de pruebas NO indican independencia")
    end
    
    return results
end

"""
    analyze_pair_correlation(pairs)::Float64

Calculate correlation coefficient between consecutive numbers.
"""
function analyze_pair_correlation(pairs::Vector{Tuple{Float64,Float64}})::Float64
    if length(pairs) < 2
        return 0.0
    end
    
    # Extract x and y coordinates
    x_coords = [p[1] for p in pairs]
    y_coords = [p[2] for p in pairs]
    
    # Calculate correlation coefficient
    return cor(x_coords, y_coords)
end