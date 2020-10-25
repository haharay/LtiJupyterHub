FROM jupyterhub/jupyterhub:1.2

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
 && rm -rf /var/lib/apt/lists/*

 # texlive-generic-recommended \

RUN echo "zh_CN.UTF-8 UTF-8" > /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=zh_CN.UTF-8 \
    && update-locale LC_ALL=zh_CN.UTF-8

ENV LC_ALL zh_CN.UTF-8
ENV LANG zh_CN.UTF-8

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
    matplotlib \
    seaborn \
    sympy \
    numba

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

# 计量经济分析包
RUN pip install statsmodels \
    linearmodels \
    arch \
    tushare \
    pandas-datareader \
    julia \
    diffeqpy \
    jitcode \
    jitcsde \
    cufflinks \
    plotly \
    jieba \
    wordcloud

# 加密与信息安全相关工具
RUN pip install cryptography \
    pynacl


RUN pip install nbgitpuller \
    tornado
RUN pip install git+https://github.com/U4I-fedir-kryvytskyi/ltiauthenticator

EXPOSE 8000
