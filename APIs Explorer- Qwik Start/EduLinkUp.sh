#!/bin/bash

# Define color variables
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'

# Define text formatting variables
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

# Welcome message
echo "${YELLOW_TEXT}${BOLD_TEXT}╔══════════════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}║                   EDULINKUP LAB AUTOMATION                       ║${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}║              Launching Your Cloud Learning Journey...            ║${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}╚══════════════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo


BLINK_TEXT=$'\033[5m'
NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
REVERSE_TEXT=$'\033[7m'


# Enhanced Color Definitions
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)


BOLD=$(tput bold)
RESET=$(tput sgr0)
UNDERLINE=$(tput smul)


# Get Project ID
echo "${YELLOW}${BOLD}Step 1: Fetching Your Project ID${RESET}"
export BUCKET="$(gcloud config get-value project)"
if [ -z "$BUCKET" ]; then
  echo "${RED}✗ Failed to get project ID. Please ensure you're authenticated.${RESET}"
  exit 1
fi
echo "${GREEN}✓ Your Project ID: ${BUCKET}${RESET}"
echo


# Create Cloud Storage Bucket
echo "${YELLOW}${BOLD}Step 2: Creating Cloud Storage Bucket${RESET}"
BUCKET_NAME="${BUCKET}-bucket-$(date +%s)"
echo "Creating bucket: gs://${BUCKET_NAME}"


gsutil mb -p $BUCKET -l US gs://$BUCKET_NAME || {
  echo "${RED}✗ Failed to create bucket. Common issues:"
  echo "1. Bucket name must be globally unique"
  echo "2. Insufficient permissions"
  echo "3. Invalid project ID${RESET}"
  exit 1
}
echo "${GREEN}✓ Bucket created successfully: gs://${BUCKET_NAME}${RESET}"
echo


# Download Demo Image
echo "${YELLOW}${BOLD}Step 3: Downloading Demo Image${RESET}"
IMAGE_URL="https://raw.githubusercontent.com/eccentriccoder01/Google-Arcade-Labs-EduLinkUp/refs/heads/main/APIs%20Explorer-%20Qwik%20Start/demo-image.jpg"
IMAGE_FILE="demo-image-$(date +%s).jpg"


if ! curl -s -o $IMAGE_FILE -L "$IMAGE_URL"; then
  echo "${YELLOW}⚠️ Using fallback image URL${RESET}"
  IMAGE_URL="https://storage.googleapis.com/gweb-cloudblog-publish/images/Google_Cloud.max-1100x1100.jpg"
  curl -s -o $IMAGE_FILE -L "$IMAGE_URL" || {
    echo "${RED}✗ Failed to download image${RESET}"
    exit 1
  }
fi
echo "${GREEN}✓ Image downloaded: ${IMAGE_FILE}${RESET}"
echo


# Upload Image to Bucket
echo "${YELLOW}${BOLD}Step 4: Uploading Image to Bucket${RESET}"
gsutil cp $IMAGE_FILE gs://$BUCKET_NAME/demo-image.jpg || {
  echo "${RED}✗ Failed to upload image to bucket${RESET}"
  exit 1
}
echo "${GREEN}✓ Image uploaded to gs://${BUCKET_NAME}/demo-image.jpg${RESET}"
echo


# Set Public Access
echo "${YELLOW}${BOLD}Step 5: Configuring Public Access${RESET}"
gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME/demo-image.jpg || {
  echo "${RED}✗ Failed to set public access${RESET}"
  exit 1
}
echo "${GREEN}✓ Image is now publicly accessible${RESET}"
echo


# Generate Public URL
PUBLIC_URL="https://storage.googleapis.com/${BUCKET_NAME}/demo-image.jpg"
echo "${YELLOW}${BOLD}Public Access URL:${RESET}"
echo "${BLUE}${UNDERLINE}${PUBLIC_URL}${RESET}"
echo


# Final message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}╔══════════════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}║                   LAB COMPLETED SUCCESSFULLY!                    ║${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╚══════════════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}📺 SUBSCRIBE TO EDULINKUP FOR MORE CLOUD LABS! 📺${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔗 https://www.youtube.com/@EduLinkUp${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}💡 Keep Learning, Keep Growing! 💡${RESET_FORMAT}"
echo
