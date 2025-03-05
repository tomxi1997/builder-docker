#!/bin/bash

# Function to list all Docker images
list_all_images() {
    echo "Listing all Docker images:"
    docker images
}

# Function to get the Docker image ID for a given repository name
get_image_id_by_repository() {
    local repository_name=$1
    local image_id=$(docker images --format "{{.ID}} {{.Repository}}" | grep "^.* $repository_name$" | awk '{print $1}')
    
    if [ -n "$image_id" ]; then
        echo "The Docker image ID for repository '$repository_name' is: $image_id"    docker save -o buider-arm64.tar $image_id
	echo "Docker image save sucessfully"
    else
        echo "No Docker image found for repository '$repository_name'."
	echo "Docker image save faild"
    fi
}

# Main script execution
list_all_images
get_image_id_by_repository "builder"
