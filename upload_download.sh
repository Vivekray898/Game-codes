#!/bin/bash  

# Check if an argument is provided  
if [ -z "$1" ]; then  
    echo "Usage: download_and_upload.sh {url|file_path}"  
    exit 1  
fi  

# Set variables  
DOWNLOAD_DIR="/home/root__storage/aria2c/"  
RCLONE_REMOTE="one_business:My files/My files/moviez"  
MAPPING_FILE="$DOWNLOAD_DIR/file_mapping.txt"  # File to store unique code mappings  

# Function to generate a unique code  
generate_unique_code() {  
    echo "$(date +%s%N)"  # Using timestamp in nanoseconds as a unique code  
}  

# Function to get the direct download link from Google Drive  
get_google_drive_link() {  
    local file_id="$1"  
    echo "https://drive.google.com/uc?export=download&id=${file_id}"  
}  

# Function to handle SharePoint links  
get_sharepoint_download_link() {  
    local sharepoint_url="$1"  
    echo "$sharepoint_url" | sed 's/:v:/download?/'  
}  

# Check if the argument is a URL or a file path  
if [[ "$1" =~ ^http ]]; then  
    # Check if it's a SharePoint link  
    if [[ "$1" =~ "sharepoint.com" ]]; then  
        URL=$(get_sharepoint_download_link "$1")  
        curl -L -o "$DOWNLOAD_DIR$(basename "$URL")" "$URL"  
        TEMP_FILENAME=$(basename "$URL")  
    # Check if it's a Google Drive link  
    elif [[ "$1" =~ /d/([^/]+) ]]; then  
        FILE_ID="${BASH_REMATCH[1]}"  
        URL=$(get_google_drive_link "$FILE_ID")  
        aria2c --conf-path=/root__storage/.aria2/aria2.conf "$URL" -d "$DOWNLOAD_DIR"  
        TEMP_FILENAME=$(ls "$DOWNLOAD_DIR" | grep -E '\.mp4$' | head -n 1)  # Adjust this if you expect different file types  
    else  
        # It's a regular URL, download the file using aria2c  
        URL="$1"  
        aria2c --conf-path=/root__storage/.aria2/aria2.conf "$URL" -d "$DOWNLOAD_DIR"  
        TEMP_FILENAME=$(basename "$URL")  
    fi  

    # Generate a unique code for the downloaded file  
    UNIQUE_CODE=$(generate_unique_code)  
    FINAL_FILENAME="${UNIQUE_CODE}_$(basename "$TEMP_FILENAME")"  # Rename file with unique code  
    mv "$DOWNLOAD_DIR$TEMP_FILENAME" "$DOWNLOAD_DIR$FINAL_FILENAME"  # Rename the file  

    # Store the mapping of unique code to actual file name  
    echo "$UNIQUE_CODE $FINAL_FILENAME" >> "$MAPPING_FILE"  

else  
    # It's a file path, use the provided file  
    FILE_PATH="$1"  
    if [ ! -f "$FILE_PATH" ]; then  
        echo "Error: File '$FILE_PATH' does not exist."  
        exit 1  
    fi  
    FINAL_FILENAME=$(basename "$FILE_PATH")  
    cp "$FILE_PATH" "$DOWNLOAD_DIR$FINAL_FILENAME"  
fi  

# Upload the file to cloud storage using rclone  
rclone move "$DOWNLOAD_DIR$FINAL_FILENAME" "$RCLONE_REMOTE"  

# Check if the upload was successful  
if [ $? -eq 0 ]; then  
    echo "Upload completed for $FINAL_FILENAME. Deleting local file in 20 seconds..."  
    sleep 20  
    rm -f "$DOWNLOAD_DIR$FINAL_FILENAME"  
    echo "Local file deleted for $FINAL_FILENAME"  
else  
    echo "Error: Upload failed for $FINAL_FILENAME"  
fi  
