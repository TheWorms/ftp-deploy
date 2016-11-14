#! /bin/bash

# @usage: ftpdeploy [folder]
# @example: ftpdeploy  # uses config parameters
# @example: ftpdeploy /assets # uploads only a specific folder/file (./app/assets)

FTP_DEPLOY_USER="user@example.com"  # FTP User
FTP_DEPLOY_HOST="ftp.example.com" # FTP Host

read -p -s "FTP Password:" FTP_DEPLOY_PASS;

FTP_DEPLOY_DEFAULT="app" # specify a source subfolder (./app)
FTP_DEPLOY_ROOT="" # specify a remote upload folder (/public_html)

ftpPath="${FTP_DEPLOY_DEFAULT}$1"
ftpCommand="open -u $FTP_DEPLOY_USER,$FTP_DEPLOY_PASS $FTP_DEPLOY_HOST;" # open FTP connection
ftpCommand="$ftpCommand set ssl:verify-certificate no;" # disable certificate verification
ftpCommand="$ftpCommand mirror -c --script=/dev/null --verbose=1 --parallel=3" # apply lftp mirror command with 3 parallel uploads

ftpCommand="$ftpCommand --exclude .c9/ " # exclude c9 settings folder
ftpCommand="$ftpCommand --exclude .git/ " # exclude .git folders
ftpCommand="$ftpCommand --exclude wp-admin/ --exclude wp-includes/ --exclude-glob wp-*.php" # exclude WP core
ftpCommand="$ftpCommand --exclude-glob *.zip --exclude-glob *.log --exclude-glob *.ini " # exclude .zip .log .ini
ftpCommand="$ftpCommand --exclude ftp_deploy.sh " # exclude this script

ftpCommand="$ftpCommand  -R ${HOME}/workspace/$ftpPath ${FTP_DEPLOY_ROOT}/$ftpPath "

echo "Changes ($ftpPath):"
lftp -c "$ftpCommand"

read -p "Procees with file sync? (y/n) " yn
while true; do
    case $yn in
        [Yy]* ) lftp -c "${ftpCommand/--script=\/dev\/null/ }";  break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
