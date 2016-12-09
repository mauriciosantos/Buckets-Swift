#!/usr/bin/env bash

# Only generate and run docs once
if [ "$DEPLOY" == "YES" ] && [ "$TRAVIS_REPO_SLUG" == "mauriciosantos/Buckets-Swift" ] && [ "$TRAVIS_PULL_REQUEST" == "false" ] && [ "$TRAVIS_BRANCH" == "master" ]; then
  set -e
  echo -e "Installing Jazzy...\n"
  gem cleanup json
  gem install jazzy
  echo -e "Generating docs...\n"
  jazzy
  echo -e "Publishing docs...\n"
  cp -R Docs $HOME/Docs

  cd $HOME
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "travis-ci"

  # Redirect any output to /dev/null to hide any sensitive credential data that might otherwise be exposed in the logs.
  git clone --quiet --branch=gh-pages https://${GH_TOKEN}@github.com/mauriciosantos/Buckets-Swift.git gh-pages > /dev/null

  cd gh-pages
  git rm -rf *
  cp -Rf $HOME/Docs/. ./
  git add -f .
  git commit -m "Latest docs from successful travis build $TRAVIS_BUILD_NUMBER auto-pushed to gh-pages"
  git push -fq origin gh-pages > /dev/null
  echo -e "Published docs to gh-pages.\n"
fi
