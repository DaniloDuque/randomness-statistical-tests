#!/bin/bash
# Script to generate random number samples from all generators
# Usage: ./run_all_generators.sh [num_samples]
# Default to 1 million samples if not specified
NUM_SAMPLES=${1:-1000000}

# Create resources directory if it doesn't exist
mkdir -p ./resources

echo "========================================"
echo "Generating $NUM_SAMPLES samples for each language"
echo "========================================"

# Java Generator [0,1)
echo ""
echo "1. Java Generator [0,1)..."
if [ -f "UniformGenerator.java" ]; then
    javac UniformGenerator.java
    java UniformGenerator $NUM_SAMPLES ./resources/java_uniform_0_1.txt
    rm UniformGenerator.class
else
    echo "   ERROR: Java Generator.java not found"
fi

# Erlang Generator [0,1)
echo ""
echo "2. Erlang Generator [0,1)..."
if [ -f "UniformGenerator.erl" ]; then
    escript UniformGenerator.erl $NUM_SAMPLES ./resources/erlang_uniform_0_1.txt
else
    echo "   ERROR: Erlang Generator not found"
fi

# Python Generator [0,1)
echo ""
echo "3. Python Generator [0,1)..."
if [ -f "UniformGenerator.py" ]; then
    python3 UniformGenerator.py $NUM_SAMPLES ./resources/python_uniform_0_1.txt
else
    echo "   ERROR: Python Uniform Generator not found"
fi

# Python Generator {1,2,3,4,5,6}
echo ""
echo "4. Python Generator {1,2,3,4,5,6} (dice)..."
if [ -f "SixSidedUniformGenerator.py" ]; then
    python3 SixSidedUniformGenerator.py $NUM_SAMPLES ./resources/python_dice_1_6.txt
else
    echo "   ERROR: Python six sided uniform generator not found"
fi

# C Generator {1,2,3,4}
echo ""
echo "5. C Generator {1,2,3,4}..."
if [ -f "FourSidedUniformGenerator.c" ]; then
    gcc FourSidedUniformGenerator.c -o c_gen_4
    ./c_gen_4 $NUM_SAMPLES ./resources/c_discrete_1_4.txt
    rm c_gen_4
else
    echo "   ERROR: C Four Sided generator not found"
fi

# C Generator {1,2,3,4,5,6,7,8}
echo ""
echo "6. C Generator {1,2,3,4,5,6,7,8}..."
if [ -f "EightSidedUniformGenerator.c" ]; then
    gcc EightSidedUniformGenerator.c -o c_gen_8
    ./c_gen_8 $NUM_SAMPLES ./resources/c_discrete_1_8.txt
    rm c_gen_8
else
    echo "   ERROR: C Eight sided generator not found"
fi

# Racket Generator [1,20]
echo ""
echo "7. Racket Generator [1,20]..."
if [ -f "UniformGenerator.rkt" ]; then
    racket UniformGenerator.rkt $NUM_SAMPLES ./resources/racket_integer_1_20.txt
else
    echo "   ERROR: UniformGenerator.rkt not found"
fi

# Prolog Generator [0,1)
echo ""
echo "8. Prolog Generator [0,1)..."
if [ -f "UniformGenerator.pl" ]; then
    swipl UniformGenerator.pl $NUM_SAMPLES ./resources/prolog_uniform_0_1.txt
else
    echo "   ERROR: UniformGenerator.pl not found"
fi

echo ""
echo "========================================"
echo "Generation Complete!"
echo "========================================"
echo ""
echo "Generated files in ./resources/:"
ls -lh ./resources/
echo ""
echo "File sizes:"
du -h ./resources/*