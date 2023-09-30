# Rope-docker-headless-vnc-container 

This is a docker for running [Rope](https://github.com/Hillobar/Rope) using [headless VNC environments](https://github.com/ConSol/docker-headless-vnc-container). Useful for running Rope on cloud GPU services like runpod.io or vast.ai.

The Docker image is installed with the following components:
* [**Rope**](https://github.com/Hillobar/Rope)
* JupyterLab (default http port `8080`)
* VNC-Server (default VNC port `5901`)
* [**noVNC**](https://github.com/novnc/noVNC) - HTML5 VNC client (default http port `6901`)
* CUDA Toolkit 11.8
* Pytorch 2.0.1+cu118
* Desktop environment [**Xfce4**](http://www.xfce.org)
* Browsers:
  * Mozilla Firefox
  * Chromium

## Usage
- Run command with mapping to local port `5901` (vnc protocol), `6901` (vnc web access), and `8080` (JupyterLab):

      docker run -d -p 5901:5901 -p 6901:6901 -p 8080:8080  -e VNC_PASSWORDLESS=true asyafiqe/rope_vnc:latest

    For more options, please check [ConSol's docker-headless-vnc-container github](https://github.com/ConSol/docker-headless-vnc-container).
- Build an image from scratch:

      docker build -t asyafiqe/rope_vnc .

- Vast.ai template:
    Put `asyafiqe/rope_vnc:latest` in image path/tag.
    Docker options:
    ```
    -p 5901:5901 -p 6901:6901 -p 8080:8080 -e VNC_PASSWORDLESS=true
    ```
    In Launch Mode select 'Run interactive shell server, SSH'. Check 'Use direct SSH connection'.
    On-start Script:
    
    ```
    env | grep _ >> /etc/environment; echo 'starting up'
    /dockerstartup/vnc_startup.sh
    sleep infinity
    ```
- Runpod.io template:
    * Container image: `asyafiqe/rope_vnc:latest`.
    * Docker command: 
    ```
    -p 5901:5901 -p 6901:6901 -p 8080:8080
    ```
    * Container disk: minimum 20GB
    * Volume disk: personal preference
    * Volume mount path: `/workspace`
    * Expose http ports: `5901,6901,8080`
    * Environment Variables: key: `VNC_PASSWORDLESS`, value `true`
