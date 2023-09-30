FROM consol/debian-xfce-vnc
ENV REFRESHED_AT 2023-09-29

# Switch to root user to install additional software
USER 0

### Fix TZ select region stuck
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

### Install basic utils
RUN apt-get update -y && apt-get install -y git unzip ffmpeg python3.10 python3-pip python3-tk

### Install cuda toolkit with conda
ENV PATH /opt/conda/bin:$PATH

RUN set -x && \
    wget "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" -O miniconda.sh -q && \
    #echo "${SHA256SUM} miniconda.sh" > shasum && \
    #if [ "${CONDA_VERSION}" != "latest" ]; then sha256sum --check --status shasum; fi && \
    mkdir -p /opt && \
    sh miniconda.sh -b -p /opt/conda && \
    #rm miniconda.sh shasum && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy
	
RUN conda install -y -c "nvidia/label/cuda-11.8.0" cuda-toolkit

### Install Rope
WORKDIR /workspace
RUN git clone https://github.com/Hillobar/Rope.git
WORKDIR /workspace/Rope

# Fix python dependency conflict
RUN sed -i '/numpy/d' requirements.txt
RUN pip install -r ./requirements.txt --no-cache-dir
RUN wget -O /workspace/Rope/models.zip https://github.com/Hillobar/Rope/releases/download/Crystal_Shard/models.zip
RUN unzip /workspace/Rope/models.zip -d /workspace/Rope/models

### Install jupyterlab
RUN pip install jupyterlab
EXPOSE 8080

### Reconfigure startup
ADD --chmod=765 ./src/vnc_startup_jupyterlab.sh /dockerstartup/vnc_startup.sh

## switch back to default user
#USER 1000

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]
