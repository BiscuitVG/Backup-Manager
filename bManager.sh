#!/bin/bash

declare userDir="$1"
declare userBackupDir="$2"
declare noBackups="$3"

argValidate() {
    # local validateAllArg
    local -n sourceDir="$1"
    local -n backupDir="$2"
    local -n maxBackups="$3"

    if ! [[ "$backupDir" =~ '/'$ ]]
    then
        backupDir+="/"
    fi

    if [ -z "$sourceDir" ] #checks if the var is empty
    then
        echo "No directory path provided! please provide a directory path that you want to back up." >&2
        sleep 1
        exit 1
    elif [ -d "$sourceDir" ] #checks if the directory exists
    then
        echo "Provided source directory is available!" >&2
        sleep 1
    else
        echo "Provided directory is not valid or doesnt exist!" >&2
        sleep 1
        exit 1
    fi

    if [ -z "$backupDir" ]
    then
        echo "No directory path provided! please provide a directory path that you want to back up." >&2
        sleep 1
        exit 1
    elif [ -d "$backupDir" ]
    then
        echo "Provided backup path is available!" >&2
        sleep 1
    else
        echo "Provided directory is not valid or doesnt exist!" >&2
        sleep 1
        exit 1
    fi

    if [ "$maxBackups" -gt 0 ] && [ "$maxBackups" -le 5 ]
    then
        echo "$maxBackups" archives created at "$backupDir" >&2
    else
        echo "Invalid backups! Not more than 5 backups can be created at a time of the same directory." >&2
        sleep 1
        exit 1
    fi
}

createBackup(){
    local -n sourceDir="$1"
    local -n backupDir="$2"
    local maxBackups="$3" #no need -n(nameref) as will be taking a copy, preventing modifying the orignal value

    local loopCounter=0

    for ((i=0; i<"$maxBackups"; i++ ));
    do
        ((loopCounter++))
        
        local dateVar
        dateVar=$(date '+%Y-%m-%d_%H-%M-%S')

        local backupFileDir
        backupFileDir="$backupDir"backup_"$dateVar"_"$loopCounter"_"source.tar.gz"
        # echo "$backupFileDir"

        # cp -a "$sourceDir" "$backupFileDir" #changed -c to -R to copy sub directories also
        # tar czf "name" "Dir_to_backup"
        tar czf "$backupFileDir" "$sourceDir"

    done
    # echo "$backupDir"
    echo "Archival Complete!"
    sleep 1
}

cleanOldBackups() {
    local -n backupDir="$1"

    if [[ $(find "$backupDir" -mindepth 1 -maxdepth 1 -type d | wc -l) -gt 5 ]]
    then
        ls -Alt "$backupDir" | tail -n +6 | xargs -I{} rm -rf -- "$backupDir/{}"
    else
        echo "Logs deletetion criteria not met: No prev logs deleted!"
    fi
}

argValidate userDir userBackupDir noBackups
createBackup userDir userBackupDir noBackups
cleanOldBackups userBackupDir