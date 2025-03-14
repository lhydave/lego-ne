#!/bin/bash

# Get the current directory
current_dir=$(pwd)

# Define the legone-code and mathematica-code directories
legone_dir="${current_dir}/legone-code"
mathematica_dir="${current_dir}/mathematica-code"

# Check if the mathematica-code directory exists, if not create it
if [ ! -d "$mathematica_dir" ]; then
  mkdir "$mathematica_dir"
fi

# Loop through all .legone files in the legone-code directory
for file in "$legone_dir"/*.legone; do
  # Extract the base filename without the extension
  base_filename=$(basename "$file" .legone)

  # Output the test message
  echo "Now processing on $base_filename"

  # Execute the command with the input file and output to the corresponding .m file
  "$current_dir/../src/compiler" "$file" -o "$mathematica_dir/${base_filename}.m"

  
done
