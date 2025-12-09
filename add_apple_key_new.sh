#!/bin/bash

APPLE_SIGN_IN_AUTH_KEY_P8_FILE=$1
# Create a Kubernetes secret for Apple Sign-In private key
kubectl create secret generic apple-signin-key \
  --from-file=private-key.p8=${APPLE_SIGN_IN_AUTH_KEY_P8_FILE} \
  --namespace=controller
