#!/bin/bash

PATH_BASE="/home/mxchxdx"

for file in $(ls -tr "${PATH_BASE}/Descargas"); do
    FILE=$(/usr/bin/basename "${file}")
    echo ${file}
done