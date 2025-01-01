#!/bin/bash

# download the MAC address list
curl https://maclookup.app/downloads/csv-database/get-db -o ./assets/network_tools/mac-vendors-export.csv

# generate the app icons
dart run icons_launcher:create
