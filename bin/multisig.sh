#!/bin/bash

echo "Enter http/https URL of nodeos API service to use, followed by [ENTER]:"
read URL

echo "Enter the proposer, followed by [ENTER]:"
read PROPOSER

echo "Enter the proposal name, followed by [ENTER]:"
read PROPOSAL_NAME

cleos -u $URL multisig review $PROPOSER $PROPOSAL_NAME > /tmp/proposal.json

# JQ filter for extracting setcode actions
SETCODES='.transaction.actions[] | select(.account=="eosio") | select(.name=="setcode")'

for ACCOUNT in $( jq "$SETCODES | .data.account" /tmp/proposal.json )
do

        echo "hash of code proposed for deployment to $ACCOUNT"
        # JQ filter for extracting the code proposed for the current ACCOUNT
        CODE="select(.data.account==$ACCOUNT) | .data.code"
        jq "$SETCODES | $CODE" /tmp/proposal.json | xxd -r -p | sha256sum

done

exit 0