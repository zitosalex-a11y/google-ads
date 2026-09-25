# Google Ads MCP for Claude Code

This repo connects Claude Code to the Google Ads API through Google's official
[Google Ads MCP server](https://github.com/googleads/google-ads-mcp).

- `.mcp.json` registers the `google-ads` server; `.claude/settings.json` auto-enables it.
- `scripts/google-ads-mcp.sh` starts the server (via `uvx`, falling back to `pipx`)
  from a pinned upstream commit, with credentials taken from environment variables.
- `scripts/get_refresh_token.py` helps you get an OAuth refresh token once.

The server is **read-only**. Its tools are:

| Tool | What it does |
| --- | --- |
| `customers_list_accessible_customers` | Lists the account IDs you can access |
| `search_search` | Runs GAQL queries (campaigns, ad groups, keywords, metrics…) |
| `metadata_get_resource_metadata` | Lists the fields available on a resource |

## Setup

### 1. Developer token
In your Google Ads **manager (MCC)** account go to **Tools → Setup → API Center**,
apply, and copy the developer token. Production accounts need at least *Explorer*
access; a *Test* token only works with test accounts.

### 2. Google Cloud OAuth client
1. In [Google Cloud Console](https://console.cloud.google.com/) create or pick a project.
2. Enable the [Google Ads API](https://console.cloud.google.com/apis/library/googleads.googleapis.com).
3. Set up the **OAuth consent screen**. If it stays in "Testing", add your Google account
   as a test user; refresh tokens for apps in testing expire after 7 days, so
   publish the app for long-lived tokens.
4. **Credentials → Create credentials → OAuth client ID → Desktop app**, then
   download the JSON file (e.g. `client_secret.json`). Don't commit it.

### 3. Refresh token (run once on your own computer)
```sh
uv run --with google-auth-oauthlib scripts/get_refresh_token.py client_secret.json
```
Sign in with the Google account that has access to your Ads accounts. The script prints
`GOOGLE_ADS_CLIENT_ID`, `GOOGLE_ADS_CLIENT_SECRET` and `GOOGLE_ADS_REFRESH_TOKEN`.

### 4. Store the secrets as environment variables

| Variable | Required | Value |
| --- | --- | --- |
| `GOOGLE_ADS_DEVELOPER_TOKEN` | yes | From step 1 |
| `GOOGLE_ADS_CLIENT_ID` | yes | From step 3 |
| `GOOGLE_ADS_CLIENT_SECRET` | yes | From step 3 |
| `GOOGLE_ADS_REFRESH_TOKEN` | yes | From step 3 |
| `GOOGLE_ADS_LOGIN_CUSTOMER_ID` | if you access accounts through a manager account | Manager account ID, digits only |

- **Claude Code on the web:** in the session title bar open the cloud environment menu →
  **Edit**, and add these as environment variables. They apply to new sessions.
- **Local Claude Code:** export them in your shell, or put them in the `env` block of
  `~/.claude/settings.json`. Instead of the three OAuth variables you can also point
  `GOOGLE_APPLICATION_CREDENTIALS` at an ADC file created with
  `gcloud auth application-default login --scopes=https://www.googleapis.com/auth/adwords,https://www.googleapis.com/auth/cloud-platform`.

Never commit secrets to this repo.

### 5. Try it
Start a new Claude Code session in this repo. `/mcp` should show `google-ads` as connected. Then ask:

- "What Google Ads accounts do I have access to?"
- "Show last 30 days' spend, clicks and conversions per campaign for customer 1234567890."

## Updating the server
The upstream commit is pinned in `scripts/google-ads-mcp.sh` (`GOOGLE_ADS_MCP_REF`).
To upgrade, read the upstream changes and then change the SHA.
