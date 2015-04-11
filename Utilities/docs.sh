#!/usr/bin/env bash
# Generates documentation using Jazzy. https://github.com/realm/jazzy
# Must be run from the current directory.

cd ..
jazzy -o Docs -a Mauricio\ Santos -m Buckets -g https://github.com/mauriciosantos/Buckets-Swift --min-acl public --skip-undocumented -c
rm -rf build
