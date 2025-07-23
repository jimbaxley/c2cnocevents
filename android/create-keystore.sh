#!/bin/bash

# Script to create Android signing keystore
# Run this after installing Java

echo "Creating Android signing keystore..."
echo "You'll be prompted for:"
echo "1. Keystore password (remember this!)"
echo "2. Key password (can be same as keystore password)"
echo "3. Your name, organization, etc."

keytool -genkey -v -keystore c2c-noc-events-key.jks \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias c2c-noc-events

echo ""
echo "Keystore created! Now create key.properties file..."
echo "Copy the following to android/key.properties:"
echo ""
echo "storePassword=YOUR_KEYSTORE_PASSWORD"
echo "keyPassword=YOUR_KEY_PASSWORD"
echo "keyAlias=c2c-noc-events"
echo "storeFile=c2c-noc-events-key.jks"
