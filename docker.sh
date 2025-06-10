#!/bin/bash
docker build -t nodejs_app:$1
docker tag nodejs_app:v1.0 123456789012.dkr.ecr.us-east-1.amazonaws.com/nodejs_app:$1
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/nodejs_app:$1