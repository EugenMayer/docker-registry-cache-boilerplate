#!/bin/bash 
set -e

echo "Updating docker images"
docker-compose pull

echo "Applying needed updates"
docker-compose up -d