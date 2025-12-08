#!/bin/bash

BUCKET="tf-state-202201108659685447"
AWS_REGION="eu-west-2"
STATE_KEY="${1:-linea-k8s-stack.tfstate}"

if [ -z "$STATE_KEY" ]; then
  echo "Usage: $0 <state-key>"
  echo "Example: $0 linea-k8s-stack.tfstate"
  exit 1
fi

echo "Verifying bucket: ${BUCKET}"
if ! aws s3 ls "s3://${BUCKET}" >/dev/null 2>&1; then
  echo "Error: Cannot access bucket '${BUCKET}'"
  exit 1
fi

echo "✓ Bucket accessible"

# Create empty state file in S3
echo "Creating state file: s3://${BUCKET}/${STATE_KEY}"
echo "" | aws s3 cp - "s3://${BUCKET}/${STATE_KEY}" --region "${AWS_REGION}"

if [ $? -eq 0 ]; then
  echo "✓ State file created successfully"
  echo ""
  echo "State file location: s3://${BUCKET}/${STATE_KEY}"
  echo ""
  echo "Configure your backend.tf with:"
  echo "  bucket = \"${BUCKET}\""
  echo "  key    = \"${STATE_KEY}\""
  echo "  region = \"${AWS_REGION}\""
else
  echo "Error: Failed to create state file"
  exit 1
fi