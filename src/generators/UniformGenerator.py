import random
import sys

def generate_samples(num_samples, output_file):
    """Generate random numbers in [0,1) and save to file"""
    with open(output_file, 'w') as f:
        for _ in range(num_samples):
            value = random.random()  # [0,1)
            f.write(f"{value}\n")
    print(f"Generated {num_samples} samples in {output_file}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python python_generator_01.py <num_samples> <output_file>")
        sys.exit(1)
    
    num_samples = int(sys.argv[1])
    output_file = sys.argv[2]
    
    generate_samples(num_samples, output_file)