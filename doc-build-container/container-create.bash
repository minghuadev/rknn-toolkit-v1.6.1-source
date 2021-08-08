#!/bin/bash

if [ ! -d sharedfiles ]; then mkdir sharedfiles; fi
if [ ! -d buildfiles ]; then mkdir buildfiles; fi
if [ ! -d rk18buildroot ]; then mkdir rk18buildroot; fi

    docker run -td \
         -v $(pwd)/sharedfiles:/home/rk18user/sharedfiles \
         -v $(pwd)/buildfiles:/home/rk18user/buildfiles   \
         -v $(pwd)/rk18buildroot:/home/rk18user/rk18buildroot   \
         --name rk18builder  rk18image


