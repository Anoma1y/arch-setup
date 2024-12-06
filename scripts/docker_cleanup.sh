#!/bin/bash

echo "Removing unused Docker volumes..."
docker volume prune -f

echo "Removing stopped containers..."
docker container prune -f

echo "Removing unused networks..."
docker network prune -f

echo "Removing dangling images..."
docker image prune -f

echo "Do you want to remove all unused Docker images? (y/n)"
read -r remove_images
if [ "$remove_images" = "y" ] || [ "$remove_images" = "Y" ]; then
    echo "Removing unused Docker images..."
    docker image prune -a -f
else
    echo "Skipping removal of unused images."
fi

echo "Do you want to perform a full Docker system cleanup? (y/n)"
read -r full_cleanup
if [ "$full_cleanup" = "y" ] || [ "$full_cleanup" = "Y" ]; then
    echo "Performing full Docker system cleanup..."
    docker system prune -a --volumes -f
else
    echo "Skipping full system cleanup."
fi

echo "Docker cleanup process complete."
