# SigNoz MCP

The shared OpenCode profiles connect to the local SigNoz MCP HTTP endpoint at
`http://127.0.0.1:47831/mcp`. Docker is used rather than a host binary: it
keeps the server version and its credentials out of OpenCode configuration,
and binds the service to localhost only.

OpenCode supplies the configured `SIGNOZ_URL` and `SIGNOZ_API_KEY` to that
endpoint through request headers; `.envrc` loads the untracked `.env` file so
the profile can interpolate them without committing credentials.

## Setup

1. Create a SigNoz service-account API key with the least privileges needed.
2. Add these values to the untracked root `.env` file:

   ```dotenv
   SIGNOZ_URL=https://signoz.example.com
   SIGNOZ_API_KEY=replace-with-service-account-key
   ```

3. Start the server from the control-plane root:

   ```bash
   docker compose --env-file .env -f config/signoz-mcp.compose.yml up -d
   ```

4. Restart OpenCode, then ask it to list SigNoz services or alerts.

Stop it with:

```bash
docker compose --env-file .env -f config/signoz-mcp.compose.yml down
```

The container image follows SigNoz's documented `latest` tag. Update it with:

```bash
docker compose --env-file .env -f config/signoz-mcp.compose.yml pull
docker compose --env-file .env -f config/signoz-mcp.compose.yml up -d
```
