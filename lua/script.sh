#!/bin/bash

# Para cada container, obtemos seu ID, Names, e IPAddress e formatamos o resultado como JSON
docker ps -a --format '{{.ID}}' | while read id; do
  docker inspect $id --format '{"ID": "{{.Id}}", "Name": "{{.Name}}", "IPAddress": "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}"}'
  # docker inspect $id --format '{{json .}}' | jq -r '"ID: \(.Id), Name: \(.Name), IPAddress: " + (.NetworkSettings.Networks | map(.IPAddress) | join(" "))'
done

