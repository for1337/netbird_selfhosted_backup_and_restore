#!/bin/bash

###########################
#### Backup dei files #####
###########################

# folders paths
source_dir="/docker"
backup_dir="/bck"
timestamp=$(date +"%Y%m%d_%H%M%S")
backup_file="docker_backup_$timestamp.tar.gz"

# Make directory if doesn't exist
mkdir -p "$backup_dir"

# Backup of the netbirds and Zitadel configuration files
echo "Compression of $source_dir in $backup_dir/$backup_file..."
tar czf "$backup_dir/$backup_file" -C "$source_dir" . \
    && echo "Finish of backup, save as $backup_dir/$backup_file."




###########################
##### Volumes backup ######
###########################

# Volumes array (Zitadel)
volumes=(
    "docker_netbird_caddy_data"
    "docker_netbird_management"
    "docker_netbird_zdb_data"
    "docker_netbird_zitadel_certs"
)

# Destination path of the backup
backup_dir="/bck"
timestamp=$(date +"%Y%m%d_%H%M%S")

# Make folder if doesn't exist
mkdir -p "$backup_dir"

# backup for each volume
for volume in "${volumes[@]}"; do
    echo "Backing up $volume..."
    docker run --rm \
        -v "$volume":/volume \
        -v "$backup_dir":/backup \
        alpine \
        tar czf "/backup/${volume}_backup_$timestamp.tar.gz" -C /volume . \
        && echo "Backup of $volume done."
done

echo "All the backups are done."

