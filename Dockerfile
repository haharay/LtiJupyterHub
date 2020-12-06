FROM jupyterhub/jupyterhub:1.2.1

LABEL maintainer="Ray <hechunming@qq.com>"

USER root

RUN apt-get update && apt-get install -yq --no-install-recommends \
        python3-pip \
        python3-tk  \
    	git \
        g++ \
        gcc \
        libc6-dev \
        libffi-dev \
        libgmp-dev \
        make \
        xz-utils \
        zlib1g-dev \
        gnupg \
        vim
RUN apt-get update && apt-get install -yq --no-install-recommends \
        texlive-xetex \
        texlive-fonts-recommended \
        pandoc \
        sudo \
        netbase \
        locales \
	    wget \
        pdfcrack \
 && rm -rf /var/lib/apt/lists/*

 # texlive-generic-recommended \

RUN echo "zh_CN.UTF-8 UTF-8" > /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=zh_CN.UTF-8 \
    && update-locale LC_ALL=zh_CN.UTF-8

ENV LC_ALL zh_CN.UTF-8
ENV LANG zh_CN.UTF-8

# 安装R程序包
ARG R_VERSION=4.0.3
ARG OS_IDENTIFIER=ubuntu-1804
# Install R
RUN wget https://cdn.rstudio.com/r/${OS_IDENTIFIER}/pkgs/r-${R_VERSION}_1_amd64.deb && \
    apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -f -y ./r-${R_VERSION}_1_amd64.deb && \
    ln -s /opt/R/${R_VERSION}/bin/R /usr/bin/R && \
    ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/bin/Rscript && \
    ln -s /opt/R/${R_VERSION}/lib/R /usr/lib/R && \
    rm r-${R_VERSION}_1_amd64.deb && \
    rm -rf /var/lib/apt/lists/*
#  install R packages
RUN R -e "install.packages('IRkernel', repos = 'https://mirror.lzu.edu.cn/CRAN/')"
RUN R -e "install.packages('magrittr', repos = 'https://mirror.lzu.edu.cn/CRAN/')"

COPY jupyterhub_config.py /srv/jupyterhub/

# 安装jupyter服务的基础组件。
RUN pip install --upgrade pip
RUN pip install pip -U
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
RUN npm install -g configurable-http-proxy
RUN python3 -m pip install --upgrade notebook

RUN pip install scipy \
    numpy \
    pandas \
    pandas-datareader \
    matplotlib \
    seaborn \
    sympy \
    numba \
    scikit-learn \
    patsy \
    dask \
    pyspark \
    nltk \
    jieba \
    py2neo

RUN pip install mobilechelonian \
    nbconvert \
    folium  \
    geopy \
    ipython-sql \
    metakernel \
    pillow \
    nbautoeval \
    jupyterlab-server \
    RISE \
    ipythontutor \
    pytutor

# 大概320M，安装有难度
RUN pip install  tensorflow

# 计量经济分析包
RUN pip install statsmodels \
    linearmodels \
    arch \
    factor_analyzer \
    tushare \
    julia \
    diffeqpy \
    jitcode \
    jitcsde \
    cufflinks \
    plotly \
    wordcloud

# 加密与信息安全相关工具，解密hashcat\john\pdfcrack在命令行。
RUN pip install cryptography \
    pynacl \
    rsa

RUN pip install  nbgitpuller \
    tornado
RUN pip install git+https://github.com/jupyterhub/ltiauthenticator

EXPOSE 8000
