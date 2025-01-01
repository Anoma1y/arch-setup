#!/bin/bash

for file in "$@"; do
    basename=$(basename "$file" "${file##*.}")
    dirname=$(dirname "$file")
    pdf_file="$dirname/${basename%.*}.pdf"
    img2pdf "$file" -o "$pdf_file"
done
