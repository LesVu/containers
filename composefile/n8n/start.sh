#!/bin/bash

if [ ! -d "../../data/n8n" ]; then
  mkdir -p ../../data/n8n/{config,local-files}
fi
docker compose up -d
