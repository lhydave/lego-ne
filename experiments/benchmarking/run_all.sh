#!/bin/bash

# Define directories
INPUT_DIR="mathematica-code"
OUTPUT_DIR="analyzer-outputs"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Iterate over all .m files in the input directory
for m_file in "$INPUT_DIR"/*.m; do
    # Get the base filename without the path and extension
    base_filename=$(basename -- "$m_file")
    filename_noext="${base_filename%.*}"
    
    # Define the output file path
    output_file="${OUTPUT_DIR}/${filename_noext}-output.txt"
    
    # Check if the output file already exists
    if [ -f "$output_file" ]; then
        echo "Skipping: $base_filename (output file $output_file already exists)"
        continue
    fi

    # Clear or create the output file
    > "$output_file"
    
    echo "Processing: $base_filename (running 5 times, output to $output_file)"
    
    # Run 5 times and append the results to the same file
    for ((i=1; i<=5; i++)); do
        echo "=== Run #$i ===" >> "$output_file"
        # Run using the source file
        wolframscript -file "$m_file" >> "$output_file" 2>&1
        echo "" >> "$output_file"  # Add a blank line to separate results
        echo "  $i-th run completed."
    done
    
    echo "✓ Done: $base_filename → $output_file"
done