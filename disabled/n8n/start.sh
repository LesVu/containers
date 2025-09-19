#!/bin/bash

if [ ! -d "./data" ]; then
  mkdir -p ./data
fi
docker compose up -d
