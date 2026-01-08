import java.io.FileWriter;
import java.io.IOException;
import java.util.Random;

public class UniformGenerator {
    public static void main(String[] args) {
        if (args.length < 2) {
            System.out.println("Usage: java JavaGenerator <num_samples> <output_file>");
            System.exit(1);
        }
        
        int numSamples = Integer.parseInt(args[0]);
        String outputFile = args[1];
        
        generateSamples(numSamples, outputFile);
    }
    
    public static void generateSamples(int numSamples, String outputFile) {
        Random random = new Random();
        
        try (FileWriter writer = new FileWriter(outputFile)) {
            writer.write(numSamples + "\n");
            writer.write("0 1\n");
            for (int i = 0; i < numSamples; i++) {
                double value = random.nextDouble(); // [0,1)
                writer.write(value + "\n");
            }
            System.out.println("Generated " + numSamples + " samples in " + outputFile);
        } catch (IOException e) {
            System.err.println("Error writing to file: " + e.getMessage());
        }
    }
}
