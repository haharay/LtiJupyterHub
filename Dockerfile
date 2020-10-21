FROM jupyterhub/jupyterhub:latest

LABEL maintainer="Ray <hechunming@qq.com>"

USER root

ARG JH_ADMIN=adminlti
ARG JH_PWD=1qaz2wsx)OKM

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

# 安装jupyter服务的基础组件。
RUN pip install --upgrade pip
RUN pip install pip -U
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install jupyterlab
RUN pip install scipy \
    numpy \
    pandas \
    matplotlib \
    seaborn \
    sympy \
    numba

RUN useradd $JH_ADMIN --create-home --shell /bin/bash
COPY jupyterhub_config.py /srv/jupyterhub/
RUN chown -R $JH_ADMIN /home/$JH_ADMIN && \
    chmod 700 /home/$JH_ADMIN

RUN echo "$JH_ADMIN:$JH_PWD" | chpasswd

# droits sudo root pour JH_ADMIN !!
RUN groupadd admin && \
    usermod -a -G admin $JH_ADMIN

# 安装大多数时候使用的包，以及用户目录下的包
RUN pip install mobilechelonian \
    nbconvert \
    folium  \
    geopy \
    ipython-sql \
    metakernel \
    pillow \
    nbautoeval \
    jupyterlab-server \
    jupyter_contrib_nbextensions \
    RISE \
    ipythontutor \
    pytutor

RUN jupyter contrib nbextension install --sys-prefix

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


RUN pip install nbgitpuller \
    tornado
RUN pip install git+https://github.com/jupyterhub/ltiauthenticator

EXPOSE 8000
