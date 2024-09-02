#!/bin/bash

# Folders path
source_dir="/docker"
backup_dir="/bck"

# select the last backup
backup_file=$(ls -t "$backup_dir"/docker_backup_*.tar.gz | head -n 1)

# Verify it
if [ -z "$backup_file" ]; then
    echo "Error: The file doesn't exist -> $backup_dir."
    exit 1
fi

# Create the directory if doens't exist
mkdir -p "$source_dir"

# extract the backup
echo "Restore $backup_file in $source_dir..."
tar xzf "$backup_file" -C "$source_dir" \
    && echo "The restore is done succesfully $source_dir."








#################
# Restore volume#
#################


# Array of volumes
volumes=(
    "docker_netbird_caddy_data"
    "docker_netbird_management"
    "docker_netbird_zdb_data"
    "docker_netbird_zitadel_certs"
)

# Volumes backup directory
backup_dir_volume="/bck"

# Restore
restore_volume() {
    local volume=$1

    # Find the last backup.
    local backup_file_volume=$(ls -t "${backup_dir_volume}/${volume}_backup_"*.tar.gz 2>/dev/null | head -n 1)

    if [ -z "$backup_file_volume" ]; then
        echo " $volume backup not found. I'll skip it."
        return 1
    fi

    echo "Restore of $volume from file $backup_file_volume..."
    docker run --rm \
        -v "$volume":/volume \
        -v "$backup_dir_volume":/backup \
        alpine \
        sh -c "rm -rf /volume/* && tar xzf /backup/$(basename "$backup_file_volume") -C /volume"

    if [ $? -eq 0 ]; then
        echo "Restore of $volume done."
    else
        echo "Error during the volume $volume restoring."
        return 1
    fi
}

# Loop per ripristinare ogni volume
for volume in "${volumes[@]}"; do
    restore_volume "$volume"
done

echo "Volumes restore is done."
