# Build Hive image

`cd` to this directory.

    cd alluxio-playground-docker/dockerfile/hive

Build the image with cached layers.

    docker build -t alluxio-playground-docker/hive:3.1.3 . 2>&1 | tee  ./build-log.txt

Build the image without cached layers.

    docker build --no-cache -t alluxio-playground-docker/hive:3.1.3 . 2>&1 | tee  ./build-log.txt
