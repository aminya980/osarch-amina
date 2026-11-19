#!/bin/sh
# Lab 5: convert staff-broken.csv from KZ-1048 (RK1048) to UTF-8 with BOM, keep CRLF
in=evidence/staff-broken.csv
out=evidence/staff-fixed.csv
iconv -f RK1048 -t UTF-8 "$in" > "$out"                      # 1. encoding (CRLF bytes are kept)
printf '\357\273\277' | cat - "$out" > tmp && mv tmp "$out"   # 2. add BOM EF BB BF
