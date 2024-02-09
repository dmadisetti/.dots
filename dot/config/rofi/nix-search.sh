#!/usr/bin/env bash

# Rofi prompt for search query
searchQuery=$(echo "" | rofi -dmenu -p "Nix package search")

# Search for the package using nix
searchResult=$(nix search nixpkgs "$searchQuery")

# Split into array by line
IFS=$'\n' read -rd '' -a lines <<< "$searchResult"

# Iterate over lines to handle potential missing description
results=""
currentLine=""
for (( i=0; i<${#lines[@]}; i++ ))
do
    # If line starts with "*", it's a new package
    if [[ ${lines[$i]} == \** ]]
    then
        # Add previous line to results
        if [[ -n $currentLine ]]
        then
            results+="$currentLine\n"
        fi

        # Start new line with package name
        currentLine=$(echo "${lines[$i]}" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" | cut -c 3-)
    else
        # Otherwise it's a description, append to current line
        currentLine+=" $(echo "${lines[$i]}" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g")"
    fi
done

# Add last line to results
results+="$currentLine"

# Present the result in rofi
selectedPackage=$(echo -e "$results" | rofi -dmenu -i -p "Search Results for $searchQuery")

# If a package was selected
if [ -n "$selectedPackage" ]
then
    # Extract package name from selected line
    packageName=$(echo "$selectedPackage" | awk '{print $1}')

    # Generate URL
    packageURL="https://search.nixos.org/packages?channel=23.05&show=${packageName}&from=0&size=50&sort=relevance&type=packages&query=${searchQuery}"

    # Option to either print the URL or open it in a web browser
    echo "Selected package URL: $packageURL"
    # To open the URL in the web browser, uncomment the following line:
    # xdg-open "$packageURL"
fi

