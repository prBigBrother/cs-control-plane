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

profile-host mode="--status":
    ./lib/macbook-a-profile-host.sh {{mode}}

secure-chrome mode="default":
    ./lib/secure-remote-chrome-client.sh {{mode}}

a-profile mode="--status":
    just profile-host {{mode}}

b-chrome mode="default":
    just secure-chrome {{mode}}
