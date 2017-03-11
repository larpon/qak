#!/bin/bash

# Uncomment line if it starts with "//" and ends with "//¤qakdbg"
# sed -i 's/^\/\/\+\(.*\/\/¤qakdbg$\)/\1/g' "$1"
find ./ -type f \( -iname "*.qml" -or -iname "*.js" \) -print0 | while IFS= read -r -d $'\0' path; do
    echo "$path"
	sed -i 's/^\/\/\+\(.*\/\/¤qakdbg$\)/\1/g' "$path"
done
