#!/usr/bin/env bash

# Only publish to COCOAPODS once
if [ "$DEPLOY" == "YES" ] && [ "$TRAVIS_REPO_SLUG" == "mauriciosantos/Buckets-Swift" ] && [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
	echo -e "Publishing to COCOAPODS...\n"
	source ~/.rvm/scripts/rvm
	rvm use default
	pod trunk push
fi
