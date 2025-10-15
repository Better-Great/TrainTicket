#!/bin/bash

# Quick access script to run Token Replacement Service from project root

cd "$(dirname "$0")/ts-token-replacement-service"
./replace-tokens.sh "$@"

