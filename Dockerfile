FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

ENV REFRESHED_AT 2024-08-12

LABEL io.k8s.description="Headless VNC Container with Xfce window manager, firefox and chromium" \
      io.k8s.display-name="Headless VNC Container based on Debian" \
      io.openshift.expose-services="6901:http,5901:xvnc" \
      io.openshift.tags="vnc, debian, xfce" \
      io.openshift.non-scalable=true

### Connection ports for controlling the UI:
### VNC port:5901
### noVNC webport, connect via http://IP:6901/?password=vncpassword
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901
EXPOSE $VNC_PORT $NO_VNC_PORT

### Envrionment config
ENV HOME=/workspace \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=/workspace/install \
    NO_VNC_HOME=/workspace/noVNC \
    DEBIAN_FRONTEND=noninteractive \
    VNC_COL_DEPTH=24 \
    VNC_PW=vncpassword \
    VNC_VIEW_ONLY=false \
    TZ=Asia/Seoul
WORKDIR $HOME

### Install necessary dependencies
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    git \
    unzip \
    ffmpeg \
    # jq \
    tzdata && \
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    rm -rf /var/lib/apt/lists/*

### Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
bash miniconda.sh -b -p /opt/conda && \
rm miniconda.sh

### Add Conda to the PATH
ENV PATH /opt/conda/bin:$PATH

### Add all install scripts for further steps
ADD ./src/common/install/ $INST_SCRIPTS/
ADD ./src/debian/install/ $INST_SCRIPTS/
RUN chmod 765 $INST_SCRIPTS/*

### Install some common tools
RUN $INST_SCRIPTS/tools.sh
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

### Install custom fonts
RUN $INST_SCRIPTS/install_custom_fonts.sh

### Install xvnc-server & noVNC - HTML5 based VNC viewer
RUN $INST_SCRIPTS/tigervnc.sh
RUN $INST_SCRIPTS/no_vnc_1.5.0.sh

### Install firefox and chrome browser
RUN $INST_SCRIPTS/firefox.sh

### Install IceWM UI
RUN $INST_SCRIPTS/icewm_ui.sh
ADD ./src/debian/icewm/ $HOME/

### configure startup
RUN $INST_SCRIPTS/libnss_wrapper.sh
ADD ./src/common/scripts $STARTUPDIR
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME

### Create conda environment
RUN conda create -n visomaster python=3.10.13 && conda clean --all -y

### Activate the environment
ENV CONDA_DEFAULT_ENV visomaster
RUN echo "source activate $CONDA_DEFAULT_ENV" >> ~/.bashrc
ENV PATH /opt/conda/envs/$CONDA_DEFAULT_ENV/bin:$PATH


# # FROM nvidia/cuda:12.4.1-cudnn8-runtime-ubuntu20.04
# FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

# # Set working directory
# WORKDIR /app

# # Install system dependencies
# RUN apt-get update && apt-get install -y \
#     python3.10 \
#     python3-pip \
#     git \
#     curl \
#     && rm -rf /var/lib/apt/lists/*

# # Copy requirements file
# #COPY requirements_cu124.txt .
# #COPY requirements_cu118.txt .
RUN git clone https://github.com/visomaster/VisoMaster.git
WORKDIR $HOME/VisoMaster

# Install Python dependencies
# RUN pip3 install --no-cache-dir -r requirements_cu124.txt
RUN pip3 install --no-cache-dir -r requirements_cu118.txt
RUN pip3 install scikit-image

# Copy the rest of the application
# COPY . .

# Download models (you might want to comment this out if you're mounting models volume)
# RUN apt-get update && apt-get install -y \
#     curl \
#     && rm -rf /var/lib/apt/lists/*
#RUN curl -L https://github.com/visomaster/visomaster-assets/releases/download/v0.1.0_dp/ffmpeg.exe -o ./dependencies/ffmpeg.exe
RUN wget -O ./dependencies/ffmpeg.exe https://github.com/visomaster/visomaster-assets/releases/download/v0.1.0_dp/ffmpeg.exe
RUN python3 download_models.py


# # Command to run when starting the container
# CMD ["python3", "main.py"]  # Replace with your actual entry point
### Install jupyterlab
RUN pip install jupyterlab
EXPOSE 8080

### Install filebrowser
RUN wget -O - https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
EXPOSE 8585



# nvidia problem
RUN apt-get update && apt-get install -y \
    libegl1 \
    libgl1-mesa-glx \
    libglib2.0-0
# qt prblem
RUN apt-get update && apt-get install -y \
    libxcb-cursor0 \
    libxcb-xinerama0 \
    libxkbcommon-x11-0 && \
    rm -rf /var/lib/apt/lists/*
    
RUN apt-get update && apt-get install -y \
    libqt5gui5 \
    libqt5core5a \
    libqt5widgets5 \
    libqt5x11extras5 && \
    rm -rf /var/lib/apt/lists/*

# fileman
RUN apt-get update && apt-get install -y \
    pcmanfm && \
    rm -rf /var/lib/apt/lists/*

### Reconfigure startup
COPY ./src/vnc_startup_jupyterlab_filebrowser.sh /dockerstartup/vnc_startup.sh
RUN chmod 765 /dockerstartup/vnc_startup.sh

ENV VNC_RESOLUTION=1280x1024

# ENV QT_QPA_PLATFORM=wayland
ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]
