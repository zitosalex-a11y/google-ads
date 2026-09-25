#!/usr/bin/env python3
"""Obtain a Google Ads API OAuth refresh token.

Run this once on your own computer (it opens a browser to sign in):

    uv run --with google-auth-oauthlib scripts/get_refresh_token.py client_secret.json

client_secret.json is the "Desktop app" OAuth client you downloaded from
Google Cloud Console. Copy the printed values into your environment secrets.
"""
import sys

from google_auth_oauthlib.flow import InstalledAppFlow

SCOPES = ["https://www.googleapis.com/auth/adwords"]


def main() -> None:
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    flow = InstalledAppFlow.from_client_secrets_file(sys.argv[1], SCOPES)
    creds = flow.run_local_server(port=0, prompt="consent", access_type="offline")
    print()
    print(f"GOOGLE_ADS_CLIENT_ID={creds.client_id}")
    print(f"GOOGLE_ADS_CLIENT_SECRET={creds.client_secret}")
    print(f"GOOGLE_ADS_REFRESH_TOKEN={creds.refresh_token}")


if __name__ == "__main__":
    main()
