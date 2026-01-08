import random
import sys

def generate_samples(num_samples, output_file):
    """Generate random integers in {1,2,3,4,5,6} (dice) and save to file"""
    with open(output_file, 'w') as f:
        f.write(f"{num_samples}\n")
        f.write("1 6\n")
        for _ in range(num_samples):
            value = random.randint(1, 6)  # {1,2,3,4,5,6}
            f.write(f"{value}\n")
    print(f"Generated {num_samples} samples in {output_file}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python python_generator_dice.py <num_samples> <output_file>")
        sys.exit(1)
    
    num_samples = int(sys.argv[1])
    output_file = sys.argv[2]
    
    generate_samples(num_samples, output_file)