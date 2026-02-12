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

# Step 1: Fetch project info
echo "${CYAN_TEXT}${BOLD_TEXT}Fetching zone, region, and project details...${RESET_FORMAT}"
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)

# Step 2: Enable required services
echo "${MAGENTA_TEXT}${BOLD_TEXT}Enabling required Google Cloud services...${RESET_FORMAT}"
gcloud services enable cloudscheduler.googleapis.com
gcloud services enable run.googleapis.com

# Step 3: Clone repository
echo "${BLUE_TEXT}${BOLD_TEXT}Cloning automation repository...${RESET_FORMAT}"
git clone https://github.com/GoogleCloudPlatform/gcf-automated-resource-cleanup.git
cd gcf-automated-resource-cleanup/

WORKDIR=$(pwd)
cd "$WORKDIR/unused-ip"

# Step 4: Create static IPs
echo "${GREEN_TEXT}${BOLD_TEXT}Creating used and unused static IP addresses...${RESET_FORMAT}"
export USED_IP=used-ip-address
export UNUSED_IP=unused-ip-address

gcloud compute addresses create "$USED_IP" --project="$PROJECT_ID" --region="$REGION"
gcloud compute addresses create "$UNUSED_IP" --project="$PROJECT_ID" --region="$REGION"

gcloud compute addresses list --filter="region:($REGION)"

# Step 5: Create VM with used static IP
echo "${YELLOW_TEXT}${BOLD_TEXT}Creating VM and attaching the used static IP...${RESET_FORMAT}"
export USED_IP_ADDRESS=$(gcloud compute addresses describe "$USED_IP" \
--region="$REGION" --format=json | jq -r '.address')

gcloud compute instances create static-ip-instance \
--zone="$ZONE" \
--machine-type=e2-medium \
--subnet=default \
--address="$USED_IP_ADDRESS"

gcloud compute addresses list --filter="region:($REGION)"

# Step 6: Reset and enable Cloud Functions
echo "${CYAN_TEXT}${BOLD_TEXT}Resetting Cloud Functions API...${RESET_FORMAT}"
gcloud services disable cloudfunctions.googleapis.com
sleep 5
gcloud services enable cloudfunctions.googleapis.com

# Step 7: IAM role binding
echo "${MAGENTA_TEXT}${BOLD_TEXT}Granting Artifact Registry reader role...${RESET_FORMAT}"
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
--member="serviceAccount:$PROJECT_ID@appspot.gserviceaccount.com" \
--role="roles/artifactregistry.reader"

sleep 60

# Step 8: Deploy function
echo "${BLUE_TEXT}${BOLD_TEXT}Deploying unused_ip_function...${RESET_FORMAT}"
gcloud functions deploy unused_ip_function \
    --runtime nodejs20 \
    --region "$REGION" \
    --trigger-http \
    --allow-unauthenticated

export FUNCTION_URL=$(gcloud functions describe unused_ip_function \
--region="$REGION" --format=json | jq -r '.url')

# Step 9: Create App Engine app
echo "${GREEN_TEXT}${BOLD_TEXT}Creating App Engine application...${RESET_FORMAT}"
gcloud app create --region "$REGION"

# Step 10: Create scheduler job
echo "${YELLOW_TEXT}${BOLD_TEXT}Creating Cloud Scheduler job...${RESET_FORMAT}"
gcloud scheduler jobs create http unused-ip-job \
--schedule="* 2 * * *" \
--uri="$FUNCTION_URL" \
--location="$REGION"

sleep 30

# Step 11: Run scheduler job first time
echo "${CYAN_TEXT}${BOLD_TEXT}Running scheduler job (first run)...${RESET_FORMAT}"
gcloud scheduler jobs run unused-ip-job \
--location="$REGION"

gcloud compute addresses list --filter="region:($REGION)"

sleep 30

# Step 12: Run scheduler job second time
echo "${MAGENTA_TEXT}${BOLD_TEXT}Running scheduler job (second run)...${RESET_FORMAT}"
gcloud scheduler jobs run unused-ip-job \
--location="$REGION"

echo
cd

remove_files() {
    for file in *; do
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            if [[ -f "$file" ]]; then
                rm "$file"
                echo "File removed: $file"
            fi
        fi
    done
}

remove_files

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
