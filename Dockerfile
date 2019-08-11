from python:3.7 as builder 

RUN curl -o micro.tar.gz -J -L https://github.com/zyedidia/micro/releases/download/v1.4.1/micro-1.4.1-linux64.tar.gz
RUN tar xf micro.tar.gz -C /tmp --strip-components=1


RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends \
 gfortran \
 swig \
 libatlas-base-dev liblapack-dev \
 libhdf5-dev libfftw3-dev \
 libxft-dev \
 libxml2-dev libxslt-dev zlib1g-dev \
 libpng-dev \
 libxext-dev build-essential

ENV CFLAGS "-I/usr/include/hdf5/serial"
RUN git clone git://github.com/microquake/nlloc.git
RUN cd nlloc && make

COPY pyproject* /
RUN pip install virtualenv
RUN virtualenv -p python3.7 ve
RUN /ve/bin/pip install poetry
RUN /ve/bin/poetry install

FROM python:3.7

RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends \
 swig \
 libatlas3-base \
 libhdf5-103 libfftw3-dev \
 libxft-dev \
 libxml2 libxslt-dev \
 libpng-dev \
 libsndfile1 \
 graphviz \
 libxext-dev

COPY --from=builder nlloc/fmm2grid nlloc/fpfit2hyp nlloc/Grid2GMT \
    nlloc/Grid2Time nlloc/GridCascadingDecimate nlloc/hypoe2hyp \
    nlloc/interface2fmm nlloc/Loc2ddct nlloc/LocSum nlloc/NLDiffLoc \
    nlloc/NLLoc nlloc/oct2grid nlloc/PhsAssoc nlloc/scat2latlon \
    nlloc/Time2Angles nlloc/Time2EQ nlloc/Vel2Grid nlloc/Vel2Grid3D /usr/bin/

COPY --from=builder /ve /ve
COPY --from=builder /tmp/micro /usr/bin/micro

RUN mkdir -p /app
WORKDIR /app
