FROM python:3.6-alpine

# Install GDAL2, taken from : https://github.com/GeographicaGS/Docker-GDAL2/blob/master/2.2.3/Dockerfile
ENV ROOTDIR /usr/local/
ENV GDAL_VERSION 2.2.3
ENV OPENJPEG_VERSION 2.2.0

# Load assets
WORKDIR $ROOTDIR/

ADD http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz $ROOTDIR/src/
ADD https://github.com/uclouvain/openjpeg/archive/v${OPENJPEG_VERSION}.tar.gz $ROOTDIR/src/openjpeg-${OPENJPEG_VERSION}.tar.gz

# Install basic dependencies
RUN apk update && apk add \
    alpine-sdk	\
    python2-dev \
    python3-dev \
    py2-numpy \
    py3-numpy \
    libspatialite-dev \
    sqlite \
    postgresql-dev \
    curl-dev \
    proj4-dev \
    libxml2-dev \
    geos-dev \
    poppler-dev \
    libspatialite-dev \
    hdf5-dev \
    wget \
    bash-completion \
    cmake \
    linux-headers \
    --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/

# Compile and install OpenJPEG
RUN cd src && tar -xvf openjpeg-${OPENJPEG_VERSION}.tar.gz && cd openjpeg-${OPENJPEG_VERSION}/ \
    && mkdir build && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$ROOTDIR \
    && make && make install && make clean \
    && cd $ROOTDIR && rm -Rf src/openjpeg*

# Compile and install GDAL
RUN cd src && tar -xvf gdal-${GDAL_VERSION}.tar.gz && cd gdal-${GDAL_VERSION} \
    && ./configure --with-python --with-spatialite --with-pg --with-curl --with-openjpeg=$ROOTDIR \
    && make && make install && ldconfig . \
    && cd $ROOTDIR && cd src/gdal-${GDAL_VERSION}/swig/python \
    && python3 setup.py build \
    && python3 setup.py install \
    && cd $ROOTDIR && rm -Rf src/gdal*
# End GDAL2 install

# Cleanup
RUN apk del --purge alpine-sdk wget bash-completion cmake