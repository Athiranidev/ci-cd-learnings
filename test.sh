#!/bin/bash

echo "Installing dependencies..."
python3 -m pip install -r requirements.txt

echo "Running tests..."
pytest
