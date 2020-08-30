FROM jupyterhub/jupyterhub

LABEL maintainer="Ray <hechunming@scujcc.edu.cn>"

USER root

ARG JH_ADMIN=adminjh
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
        texlive-generic-recommended \
        pandoc \
        sudo \
        netbase \
        locales \
	wget \
 && rm -rf /var/lib/apt/lists/*

RUN echo "zh_CN.UTF-8 UTF-8" > /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=zh_CN.UTF-8 \
    && update-locale LC_ALL=zh_CN.UTF-8

ENV LC_ALL zh_CN.UTF-8
ENV LANG zh_CN.UTF-8

ARG R_VERSION=4.0.2
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
RUN R -e "install.packages('estudy2', repos = 'https://mirror.lzu.edu.cn/CRAN/')"
RUN R -e "install.packages('magrittr', repos = 'https://mirror.lzu.edu.cn/CRAN/')"

    

RUN pip install --upgrade pip
RUN pip install pip -U
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install jupyter
RUN pip install scipy \
    numpy \
    pandas \
    matplotlib \
    tensorflow \
    keras \
    numba

RUN useradd $JH_ADMIN --create-home --shell /bin/bash

# julia及相关程序包，来自https://github.com/docker-library/julia/blob/c5b96cfa3cc8dadf388a692efb280ee3c76951a3/1.4/buster/Dockerfile
ENV JULIA_PATH /srv/julia
ENV PATH $JULIA_PATH/bin:$PATH
ENV JULIA_VERSION 1.5.0
RUN	curl -fL -o julia.tar.gz  https://julialang-s3.julialang.org/bin/linux/x64/1.5/julia-1.5.0-linux-x86_64.tar.gz; 
RUN	mkdir "$JULIA_PATH"; \
	tar -xzf julia.tar.gz -C "$JULIA_PATH" --strip-components 1; \
	rm julia.tar.gz; 
RUN julia -e 'using Pkg;Pkg.add("IJulia")'

# Install nbgrader

RUN pip install SQLAlchemy nbgrader nbconvert && \ 
    jupyter nbextension install --sys-prefix --py nbgrader --overwrite && \
    jupyter nbextension enable --sys-prefix --py nbgrader && \
    jupyter serverextension enable --sys-prefix --py nbgrader && \
    jupyter nbextension disable --sys-prefix formgrader/main --section=tree && \
    jupyter serverextension disable --sys-prefix nbgrader.server_extensions.formgrader

COPY nbgrader_config.py /home/$JH_ADMIN/.jupyter/nbgrader_config.py
COPY jupyterhub_config.py /srv/jupyterhub/

RUN mkdir -p /home/$JH_ADMIN/.jupyter && \
    mkdir /home/$JH_ADMIN/source
COPY header.ipynb /home/$JH_ADMIN/source
RUN chown -R $JH_ADMIN /home/$JH_ADMIN && \
    chmod 700 /home/$JH_ADMIN

RUN mkdir -p /srv/nbgrader/exchange && \
    chmod ugo+rw /srv/nbgrader/exchange

RUN echo "$JH_ADMIN:$JH_PWD" | chpasswd

# droits sudo root pour JH_ADMIN !!
RUN groupadd admin && \
    usermod -a -G admin $JH_ADMIN

# Paquets pip

RUN pip install mobilechelonian \
    xgboost \
    nbconvert \
    seaborn \
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
    talib-binary \
    diffeqpy \
    sympy \
    cufflinks \
    plotly \
    jieba \
    wordcloud
   
# config R
RUN R -e "IRkernel::installspec(user = FALSE)"
RUN R -e "install.packages('estudy2', repos = 'https://mirror.lzu.edu.cn/CRAN/')"

RUN pip install jupyterhub-ltiauthenticator \
    tornado==5.1.1
# Creation des exemples

#COPY --chown=1000 exemples /home/$JH_ADMIN/exemples

# Dossier feedback
RUN mkdir /srv/feedback && \
    chmod 4777 /srv/feedback

# Creation des comptes
#COPY comptes.csv /root
#COPY import_comptes.sh /usr/bin
#COPY killJup.sh /usr/bin
#COPY checkmem.sh /usr/bin
#RUN chmod 755 /usr/bin/*.sh
#RUN /usr/bin/import_comptes.sh /root/comptes.csv


EXPOSE 8000
