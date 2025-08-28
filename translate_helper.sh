#!/bin/bash

# Directories
EN_DIR="application/Espo/Resources/i18n/en_US"
NO_DIR="application/Espo/Resources/i18n/nb_NO"

# First, find and copy missing files
comm -23 <(ls "$EN_DIR" | sort) <(ls "$NO_DIR" | sort) | while read -r file; do
  echo "Copying missing file: $file"
  cp "$EN_DIR/$file" "$NO_DIR/$file"
done

# Now, merge the JSON files
for no_file in "$NO_DIR"/*.json; do
  file_name=$(basename "$no_file")
  en_file="$EN_DIR/$file_name"

  if [ -f "$en_file" ]; then
    echo "Processing file: $file_name" # Added logging
    # Use jq to merge the two files. The English file is the base,
    # and the Norwegian file overwrites the keys.
    # This will keep existing Norwegian translations and add missing keys from English.
    jq -s '.[1] * .[0]' "$no_file" "$en_file" > "$no_file.tmp"
    if [ $? -eq 0 ]; then
      mv "$no_file.tmp" "$no_file"
    else
      echo "Error processing $file_name"
      rm -f "$no_file.tmp"
      exit 1
    fi
  fi
done

echo "Translation merge complete."
