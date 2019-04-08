#!/bin/bash
DATADIR=data
mkdir -p $DATADIR
for i in {1979..2004}
do
    if [ ! -f "$DATADIR"/mort$i-homicide.csv.xz ]; then
        TEMPFILE=$(mktemp).zip
        wget -O "$TEMPFILE" http://www.nber.org/mortality/$i/mort$i.csv.zip
        unzip -p "$TEMPFILE" > "$TEMPFILE".csv
        # the files has a column named ucod with the ICD-10 codes,
        # we need to find it's number to be able to filter
        col_number=$(awk -F',' ' { for (i = 1; i <= NF; ++i) print i, $i; exit } ' "$TEMPFILE".csv | grep ucod\" | sed 's|"ucod"||g')
        # filter to include only homicides and non-terrorism
        # operations of war/legal interventions ICD codes
        if [ $i -le 1978 ]; then
            csvgrep -c "$col_number" -f icd8-homicide-codes.txt "$TEMPFILE".csv >> "$DATADIR"/mort$i-homicide.csv
        else
            if [ $i -le 1998 ]; then
                csvgrep -c "$col_number" -f icd9-homicide-codes.txt "$TEMPFILE".csv >> "$DATADIR"/mort$i-homicide.csv
            else
                csvgrep -c "$col_number" -f icd10-homicide-codes.txt "$TEMPFILE".csv >> "$DATADIR"/mort$i-homicide.csv
            fi
        fi
        xz -9 "$DATADIR"/mort$i-homicide.csv
        rm -f "$TEMPFILE" "$TEMPFILE".csv
    fi
done
