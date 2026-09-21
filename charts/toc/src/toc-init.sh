#!/bin/sh

base_path="/opt/ems-platform/config/users"
username_key="ems-username"
password_key="ems-password"

# Read secret contents
username=$(cat "$base_path/$username_key")
password=$(cat "$base_path/$password_key")

# Prepare JSON payload
json_payload="{\"aoaUser\":{\"username\":\"$username\",\"password\":\"$password\"}}"

# Send request
curl -X POST "http://toc-headless:7001/init" \
     -H "Content-Type: application/json" \
     -d "$json_payload"