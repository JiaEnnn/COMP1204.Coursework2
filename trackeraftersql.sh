#!/bin/bash

# Full paths for commands
curl_path="/usr/bin/curl"
sqlite3_path="/usr/bin/sqlite3"

# File paths
bitcoin_html="/home/jiaen/Documents/COMP1204Coursework2/bitcoin.html"
database="/home/jiaen/Documents/COMP1204Coursework2/bitcoin_data.db"
log_file="/home/jiaen/Documents/COMP1204Coursework2/script_log.txt"

# Function to log errors
log_error() {
    echo "$1 at $(date)" >> "$log_file"
}

# Function to get Bitcoin rates and insert into database
update_database() {
    # Download the webpage containing Bitcoin rate information
    if ! "$curl_path" -sS https://coinmarketcap.com/currencies/bitcoin/ > "$bitcoin_html"; then
        log_error "Failed to download Bitcoin webpage"
        return 1
    fi
    
    # Extract current Bitcoin to USD rate
    current_rate=$(grep -oP '<span class="sc-f70bb44c-0 jxpCgO base-text">\K\$[\d,.]+' "$bitcoin_html" | head -1)
    low_rate=$(grep -oP '<div class="sc-f70bb44c-0 iQEJet label">Low<\/div><span>\$[\d,.]+' "$bitcoin_html" | grep -oP '\$[\d,.]+')
    high_rate=$(grep -oP '<div class="sc-f70bb44c-0 iQEJet label">High<\/div><span>\$[\d,.]+' "$bitcoin_html" | grep -oP '\$[\d,.]+')

    # Delete data where all rates are null
    "$sqlite3_path" "$database" <<EOF
    DELETE FROM bitcoin_rates WHERE current_rate IS NULL AND low_rate IS NULL AND high_rate IS NULL;
EOF

    # Insert data into table
    "$sqlite3_path" "$database" <<EOF
    INSERT INTO bitcoin_rates (current_rate, low_rate, high_rate) VALUES ('$current_rate', '$low_rate', '$high_rate');
EOF

    if [ $? -eq 0 ]; then
        echo "Data recorded at $(date)" >> "$log_file"
    else
        log_error "Failed to insert data into database"
    fi
}

# Update database and log errors
update_database || exit 1

# Array to store data
data=("$current_rate" "$low_rate" "$high_rate")

# Example usage of data array
echo "Current Rate: ${data[0]}"
echo "Low Rate: ${data[1]}"
echo "High Rate: ${data[2]}"

