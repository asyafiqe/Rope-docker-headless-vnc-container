# Rope-docker-headless-vnc-container 

This is a docker for running [**Rope**](https://github.com/Hillobar/Rope) using [**headless VNC environments**](https://github.com/ConSol/docker-headless-vnc-container). Useful for running Rope on cloud GPU services like [Runpod.io](https://www.runpod.io/) or [Vast.ai](https://vast.ai/).

The Docker image is installed with the following components:
* [**Rope**](https://github.com/Hillobar/Rope) Pearl-00
* JupyterLab (default http port `8080`)
* VNC-Server (default VNC port `5901`)
* [**noVNC**](https://github.com/novnc/noVNC) 1.5.0 - HTML5 VNC client (default http port `6901`)
* CUDA Toolkit 11.8
* Pytorch 2.0.1+cu118
* Desktop environment [**Xfce4**](http://www.xfce.org)
* [**fiebrowser**](https://github.com/filebrowser/filebrowser) (default http port `8585`)
*  Mozilla Firefox

![screenshot2](https://github.com/user-attachments/assets/2ecad65f-3795-4d95-8568-d8bf33ed1966)

## Usage
- Run command with mapping to local port `5901` (vnc protocol), `6901` (vnc web access), `8080` (JupyterLab), and `8585` (filebrowser):

      docker run -d --gpus all -p 5901:5901 -p 6901:6901 -p 8080:8080 -p 8585:8585 -e VNC_PASSWORDLESS=true -e VNC_RESOLUTION=1024x768 asyafiqe/rope_vnc:latest

    For more options, please check [ConSol's docker-headless-vnc-container github](https://github.com/ConSol/docker-headless-vnc-container).
- Build an image from scratch:

      docker build -t asyafiqe/rope_vnc .

- [Vast.ai](https://vast.ai/) template:
    Put `asyafiqe/rope_vnc:latest` in image path/tag.
    Docker options:
    ```
    -p 5901:5901 -p 6901:6901 -p 8080:8080 -p 8585:8585 -e VNC_PASSWORDLESS=true  -e VNC_RESOLUTION=1024x768
    ```
    In Launch Mode select 'Run interactive shell server, SSH'. Check 'Use direct SSH connection'.
    On-start Script:
    
    ```
    env | grep _ >> /etc/environment; echo 'starting up'
    /dockerstartup/vnc_startup.sh
    sleep infinity
    ```
    ![vast ai_template](https://github.com/user-attachments/assets/28079139-db32-4f5a-97a8-af99d8d6244a)

- [Runpod.io](https://www.runpod.io/) template:
    * Container image: `asyafiqe/rope_vnc:latest`.
    * Docker command: 
    ```
    -p 5901:5901 -p 6901:6901 -p 8080:8080 -p 8585:8585
    ```
    * Container disk: minimum 30GB
    * Volume disk: personal preference
    * Volume mount path: `/workspace`
    * Expose http ports: `6901,8080,8585`
    * Expose TCP ports: `5901`
    * Environment Variables: key: `VNC_PASSWORDLESS`, value `true`
    ![runpod io_template](https://github.com/user-attachments/assets/1e07306a-5958-4c2d-938d-8c80c68b221e)
