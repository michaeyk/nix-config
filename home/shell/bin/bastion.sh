#!/bin/bash

# Check if the subject argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 \"Subject of the email to 'start' or 'stop' bastion host\""
  exit 1
fi

# Email details
TO="bastion@auto.tsbot.us"
SUBJECT="$1"
# BODY="bash script using msmtp."

# Construct the email message
echo -e "To: $TO\nSubject: $SUBJECT\n\n$BODY" | msmtp $TO

if [ $? -eq 0 ]; then
  echo "Email sent successfully."
else
  echo "Failed to send email."
fi
