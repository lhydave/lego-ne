#!/bin/bash

# Define the directory containing the log files and the output file path
DATA_DIR="analyzer-outputs"
OUTPUT_FILE="${DATA_DIR}/summarize.txt"

# Ensure the output directory exists
mkdir -p "$DATA_DIR"

# Clear the previous summary file or create a new one
> "$OUTPUT_FILE"

echo "Processing files in ${DATA_DIR}..."
echo "Filename Average_Result Average_Time" > "$OUTPUT_FILE"
echo "---------------------------------------" >> "$OUTPUT_FILE"

# Loop through each .txt file in the specified directory
for file in "${DATA_DIR}"/*.txt; do
    # Check if the file exists to avoid errors with no-match globs
    [ -e "$file" ] || continue

    # Use awk to extract data, calculate averages, and format the output
    # - It finds lines with "result" and "time", extracts the numbers.
    # - The backtick and subsequent numbers (e.g., `20.) are removed using gsub.
    # - It sums the results and times.
    # - In the END block, it calculates the averages and prints them.
    # - The filename is passed as a variable 'filename' to awk.
    awk -v filename="$(basename "$file")" '
        /Optimization result:/ {
            # Remove backtick and everything after it from the number
            gsub(/`.*$/, "", $3)
            total_result += $3
            count++
        }
        /Optimization completed in/ {
            # Remove backtick and everything after it from the number
            gsub(/`.*$/, "", $4)
            total_time += $4
        }
        END {
            if (count > 0) {
                avg_result = total_result / count
                avg_time = total_time / count
                printf "%-25s %-20.10f %-20.6f\n", filename, avg_result, avg_time
            }
        }
    ' "$file" >> "$OUTPUT_FILE"
done

echo "Analysis complete. Results are in ${OUTPUT_FILE}"