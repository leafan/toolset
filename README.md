# Basic Docker Toolset 

This is a basic toolset in docker version, to help programmers creating an environment easily.

# Support List
- [x] mysql
- [x] mongo
- [x] redis

We'll add more and more useful basic software here, and if you need something which are not here, just kindly email us.
Surely, patch is much more preferred...

# Prerequisite

+ ubuntu 18 operating system preferred, also support other Linux based os
+ install basic software such as docker.io etc..
    ```
    sudo apt update
    sudo apt install -y docker.io && sudo apt install -y docker-compose
    sudo apt install -y make
    cp .env.example .env
    ```
+ modify /etc/docker/daemon.json, set the max log size to avoid some disk errors
    ```
    {
        "log-opts":{ "max-size" :"100m","max-file":"1"}
    }
    ```

# USAGE

## Basic Use

To run them, you should install the prerequisite first, then just run: make, it will start automatically.
Below is the detail usage for basic commands:
```
make        # Create the containers, run them all
make run    # Same as make which is the default command
make stop   # Stop the containers
make ps     # List all of the containers in this project
make logs   # View output from containers
make logsf  # View the latest 100 lines output and forcely to follow the newest logs
```

if you just want to view one container logs, or run one container, just add an variable APP in the end of commands:

```
make logsf APP=mysql    # just show the mysql logs
make one APP=mysql      # just start the mysql container
make restart APP=mysql  # just restart the mysql container
make stop APP=mysql     # just stop the mysql container
```

## Configure
All of the config files are under ${pwd}/config/${app_name}, which ${app_name} means the container name, such as mysql etc..
You can configure them follow the official documents, here pass... 

## Data directory
The container data will be exported under ${pwd}/data/${app_name}, also ${app_name} means the container name.
If you want to delete the data, just do: make stop && rm -rf data/${app_name} && make run

# Contact

If you want any further information, feel free to contact me at  **leafan@qq.com** ...
