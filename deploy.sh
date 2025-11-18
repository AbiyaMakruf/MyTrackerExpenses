#!/bin/bash

### ===========================
### CONFIG
### ===========================
SERVICE_NAME="tracker-expenses-web"
PROJECT_ID="tracker-expenses-478512"
REGION="asia-southeast1"
REPO="my-expenses"
IMAGE="app"

# Tag otomatis berdasarkan waktu (opsional)
TAG=$(date +%Y%m%d-%H%M)

FULL_IMAGE="$REGION-docker.pkg.dev/$PROJECT_ID/$REPO/$IMAGE:$TAG"


### ===========================
### AUTHENTICATION
### ===========================
echo "🔐 Authenticating Docker to Artifact Registry..."
gcloud auth configure-docker $REGION-docker.pkg.dev


### ===========================
### DOCKER BUILD
### ===========================
echo "🐳 Building Docker image..."
docker build -t $FULL_IMAGE .

if [ $? -ne 0 ]; then
  echo "❌ Docker build failed."
  exit 1
fi


### ===========================
### PUSH IMAGE
### ===========================
echo "📤 Pushing image to Artifact Registry..."
docker push $FULL_IMAGE

if [ $? -ne 0 ]; then
  echo "❌ Docker push failed."
  exit 1
fi


### ===========================
### DEPLOY TO CLOUD RUN
### ===========================
echo "🚀 Deploying to Cloud Run service: $SERVICE_NAME"
gcloud run deploy $SERVICE_NAME \
  --image="$FULL_IMAGE" \
  --region="$REGION" \
  --platform=managed \
  --allow-unauthenticated \
  --port=8080 \
  --cpu=2 \
  --memory=2Gi \
  --use-http2 \
  --async \
  --cpu-boost \
  --env-vars-file=cloudrun.env

if [ $? -ne 0 ]; then
  echo "❌ Deploy failed."
  exit 1
fi


### ===========================
### UPDATE TRAFFIC
### ===========================
echo "🔄 Routing traffic to latest revision..."
gcloud run services update-traffic $SERVICE_NAME \
  --to-latest \
  --region="$REGION"

echo "✅ DONE! Application deployed successfully."
echo "🌐 URL:"
gcloud run services describe $SERVICE_NAME --region="$REGION" --format="value(status.url)"
