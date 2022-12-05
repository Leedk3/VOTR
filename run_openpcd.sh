#!/bin/bash

name='votr-docker'

echo "Launching docker and status ..."


# Map host's display socket to docker
DOCKER_ARGS+=("-v /tmp/.X11-unix:/tmp/.X11-unix")
DOCKER_ARGS+=("-v $HOME/.Xauthority:/home/admin/.Xauthority:rw")
DOCKER_ARGS+=("-e DISPLAY")
DOCKER_ARGS+=("-e NVIDIA_VISIBLE_DEVICES=all")
DOCKER_ARGS+=("-e NVIDIA_DRIVER_CAPABILITIES=all")

if docker ps -a --format '{{.Names}}' | grep -w $name &> /dev/null; then
	if docker ps -a --format '{{.Status}}' | egrep 'Exited' &> /dev/null; then
		echo "Container is already running. Attach to ${name}"
		docker start $name 	
		docker exec -it $name bash 
	elif docker ps -a --format '{{.Status}}' | egrep 'Created' &> /dev/null; then
		echo "Container is already created. Start and attach to ${name}"
		docker start $name 	
		docker exec -it $name bash
	elif docker ps -a --format '{{.Status}}' | egrep 'Up' &> /dev/null; then
		echo "Docker is already running"
		docker exec -it $name bash
	fi 
else

	echo "Starting ..."
	echo "docker run --name ${name} votr-docker"
	docker run --name $name -it --rm \
		--privileged \
		${DOCKER_ARGS[@]} \
		--runtime nvidia \
		--user="admin" \
		-v /dev/*:/dev/* \
		-v /home/$USER/Data/Dataset/3D_data/kitti:/VOTR/data/kitti:rw \
		-v /home/$USER/Data/Dataset/3D_data:/VOTR/data:rw \
		-v /home/$USER/VOTR/checkpoints:/VOTR/checkpoints:rw \
		-v /home/$USER/VOTR/tools:/VOTR/tools:rw \
		-v /home/$USER/VOTR/setup.py:/VOTR/setup.py:rw \
		-v /home/$USER/VOTR/output:/VOTR/output:rw \
		-v /home/$USER/VOTR/pcdet:/VOTR/pcdet:rw \
		-v /home/$USER/VOTR/build:/VOTR/build \
		-v /home/$USER/VOTR/pcdet.egg-info:/VOTR/pcdet.egg-info \
		--gpus all \
		--network=host \
		$name \
		/bin/bash
fi
		# -e ROS_HOSTNAME=127.0.0.1 \
		# -e ROS_MASTER_IP=https://${ROS_HOSTNAME}:11311 \
		# -e ROS_IP=172.17.0.1 \
		# -p ${ROS_HOSTNAME}:11311:11311 \
		# -v /media/$USER/waymo:/OpenPCDet/data/waymo \


