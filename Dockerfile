FROM jupyterhub/jupyterhub

LABEL maintainer="Ray <hechunming@qq.com>"

USER root

RUN apt-get update && apt-get install -yq --no-install-recommends \
        python3-pip \
        python3-tk  \
        wget \
    	git
RUN apt-get update && apt-get install -yq --no-install-recommends \
        fonts-dejavu \
        g++ \
        gfortran \
        gcc \
        libc6-dev \
        libffi-dev \
        libgmp-dev \
        libhdf5-dev \
        make \
        xz-utils \
        zlib1g-dev \
        gnupg \
        vim
RUN apt-get update && apt-get install -yq --no-install-recommends \
        texlive-xetex \
        texlive-latex-extra \
        texlive-extra-utils \
        texlive-luatex \
        texlive-fonts-recommended \
        pandoc \
        sudo \
        netbase \
        locales \
        pdfcrack \
 && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -yq --no-install-recommends \
        default-jdk \
        fonts-noto-cjk \
 && rm -rf /var/lib/apt/lists/*

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
RUN python3 -m pip install notebook


ARG R_VERSION=4.0.5
ARG OS_IDENTIFIER=ubuntu-2004
# Install R
RUN wget https://cdn.rstudio.com/r/${OS_IDENTIFIER}/pkgs/r-${R_VERSION}_1_amd64.deb && \
    apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -f -y ./r-${R_VERSION}_1_amd64.deb && \
    ln -s /opt/R/${R_VERSION}/bin/R /usr/bin/R && \
    ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/bin/Rscript && \
    ln -s /opt/R/${R_VERSION}/lib/R /usr/lib/R && \
    rm r-${R_VERSION}_1_amd64.deb && \
    rm -rf /var/lib/apt/lists/*
RUN R -e "install.packages('IRkernel', repos = 'https://mirror.lzu.edu.cn/CRAN/')"
RUN R -e "IRkernel::installspec(user = FALSE)"


ENV JULIA_VER_MAJ 1.6
ENV JULIA_VER_MIN .1
ENV JULIA_VER $JULIA_VER_MAJ$JULIA_VER_MIN
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/$JULIA_VER_MAJ/julia-$JULIA_VER-linux-x86_64.tar.gz \
        && mkdir /usr/local/julia \
        && tar xf julia-$JULIA_VER-linux-x86_64.tar.gz --directory /usr/local/julia --strip-components=1 \
        && ln -s /usr/local/julia/bin/julia /usr/local/bin/julia \
        && rm -f julia-$JULIA_VER-linux-x86_64.tar.gz
ENV JULIA_PKGDIR /usr/share/julia/packages
# install IJulia
ENV JUPYTER=/usr/local/bin/jupyter
RUN julia -e 'empty!(DEPOT_PATH); push!(DEPOT_PATH, "/usr/share/julia"); using Pkg; Pkg.add("PyCall")' \
RUN julia -e 'empty!(DEPOT_PATH); push!(DEPOT_PATH, "/usr/share/julia"); using Pkg; Pkg.add("IJulia")' \

RUN pip install scipy \
    numpy \
    pandas \
    tsfresh \
    pandas-datareader \
    sympy \
    numba \
    scikit-learn \
    patsy \
    dask \
    cython \
    tables \
    tstables  \
    nltk \
    jieba \
    py2neo

RUN pip install matplotlib \
    chineseize-matplotlib \
    seaborn \
    plotly \
    panel

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
    factor_analyzer \
    tushare \
    jitcode \
    jitcsde \
    cufflinks \
    wordcloud \
    matching

# 计量结果导出
RUN pip install git+https://github.com/mwburke/stargazer.git


# 机器学习简化包，很好用，每个都很大，容易错。
RUN pip install pycaret
RUN pip install pyspark
RUN pip install jupyter-book
#RUN pip install pyqlib


#  install R packages
RUN R -e "install.packages('magrittr', repos = 'https://mirror.lzu.edu.cn/CRAN/')"
RUN R -e "install.packages('matchingR', repos = 'https://mirror.lzu.edu.cn/CRAN/')"
RUN R -e "install.packages('rJava',,'http://rforge.net')"
RUN R -e "install.packages('matchingMarkets', repos = 'https://mirror.lzu.edu.cn/CRAN/')"
RUN julia -e 'empty!(DEPOT_PATH); push!(DEPOT_PATH, "/usr/share/julia"); using Pkg; Pkg.add("Miletus")' \
RUN julia -e 'empty!(DEPOT_PATH); push!(DEPOT_PATH, "/usr/share/julia"); using Pkg; Pkg.add("DataDrivenDiffEq")' \
RUN julia -e 'empty!(DEPOT_PATH); push!(DEPOT_PATH, "/usr/share/julia"); using Pkg; Pkg.add("DifferentialEquations")' \
RUN julia -e 'empty!(DEPOT_PATH); push!(DEPOT_PATH, "/usr/share/julia"); using Pkg; Pkg.add("DiffEqFlux")' \
RUN julia -e 'empty!(DEPOT_PATH); push!(DEPOT_PATH, "/usr/share/julia"); using Pkg; Pkg.add("Plots")' \

RUN pip install diffeqpy
RUN python3 -c "import diffeqpy;diffeqpy.install()"

# 加密与信息安全相关工具，解密hashcat\john\pdfcrack在命令行。
RUN pip install cryptography \
    pynacl \
    rsa \
    pycryptodomex

RUN pip install  nbgitpuller \
    tornado

RUN pip install  -U  nbconvert[webpdf]

RUN pip install git+https://github.com/jupyterhub/ltiauthenticator

EXPOSE 8000
