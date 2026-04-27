set dotenv-load
set shell := ["bash", "-cu"]

default:
    just --list

up:
    if [ -f .envrc ]; then source .envrc; fi; ./bin/openchamber-slim up

down:
    if [ -f .envrc ]; then source .envrc; fi; ./bin/openchamber-slim down

status:
    if [ -f .envrc ]; then source .envrc; fi; ./bin/openchamber-slim status
