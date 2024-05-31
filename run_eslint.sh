#!/bin/sh

echo "NODE_PATH: "
echo $NODE_PATH

echo "NPM_CONFIG_PREFIX: "
echo $NPM_CONFIG_PREFIX

echo "contents of NODE_PATH: "
echo $(ls $NODE_PATH)

eslint
