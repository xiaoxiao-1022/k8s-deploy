# Secrets file for Kubernetes deployment
# This file should contain sensitive information such as passwords, tokens, etc.
# Ensure this file is not committed to version control and only edit initially
# on the deployment server and make sure it is with mod 600 permissions.
# If you need to change the secrets, edit this file and restart the deployment.

# Postgres database password
PG_PASSWORD=

# Sysadmin user password
SYSADMIN_PASSWORD=

# Google login client secret
GOOGLE_LOGIN_CLIENT_SECRET=

# Apple login key file path
APPLE_LOGIN_AUTH_KEY_P8_FILE=

# Send email Account file path
SEND_EMAIL_SERVICE_ACCOUNT_FILE=