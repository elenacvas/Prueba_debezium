#!/bin/sh
echo "bbdd stuff"
/app/create_user.sh
echo "importing data"
/app/import_data.sh