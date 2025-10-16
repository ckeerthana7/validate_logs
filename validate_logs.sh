#!/usr/bin/bash

read -p "Enter the log directory: " Log

if [ ! -d "$Log" ]; then 
  echo "Directory not found: $Log"
  exit 1
fi

# Default unwanted keyword(s)
UNWANTED_KEYWORDS="DEBUG|TRACE|ERROR"

# Output file for unwanted lines
INVALID_LOG="unwanted_lines.log"

# Clear old unwanted lines file
> "$INVALID_LOG"

echo "Scanning log directory: $Log"
echo "----------------------------------------"

# Process each log file
for file in "$Log"/*.log; do
  [ -e "$file" ] || { echo "No .log files found in $Log."; exit 0; }

  echo "Processing file: $file"

  awk -v invalid="$INVALID_LOG" -v clean="$file.clean" -v keywords="$UNWANTED_KEYWORDS" '
  {
    # Skip empty lines
    if ($0 ~ /^[[:space:]]*$/) next

    # Check if line is unwanted
    if (NF < 9 || $0 ~ keywords) {
      print "[UNWANTED] " $0       # Show on terminal
      print $0 >> invalid           # Save to unwanted file
    } else {
      print $0 >> clean             # Save clean lines
    }
  }' "$file"

  echo "  → Cleaned log saved as: $file.clean"
  echo "----------------------------------------"
done

echo "Unwanted lines saved in: $INVALID_LOG"
echo "Log cleaning completed successfully!"
