#!/bin/bash

# Change to the directory containing the compiler in the src directory
cd "$(dirname "$0")"

# Recursively find all .legone files in the tests directory and its subdirectories
find ../tests -type f -name '*.legone' | while read file; do
  # Extract the filename without the path
  filename=$(basename "$file")
  # Get the relative directory path without the filename
  relative_dir=$(dirname "$file" | sed 's|../tests/||')
  # Create the corresponding output directory if it does not exist
  mkdir -p "../results/${relative_dir}"
  # Run the compiler with -p -s -v flags and redirect the output to the corresponding result file
  ./compiler -v -o "test.m" "$file" > "../results/${relative_dir}/${filename%.legone}_result.txt" 2>&1
done
