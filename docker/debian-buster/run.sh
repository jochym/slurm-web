#!/bin/bash

# EDIT: indicate where your configuration files will be stored
data=$PWD

docker run --rm --name slurm-web \
              -v $data/conf:/etc/slurm-web \
              -v /etc/munge:/etc/munge \
              -v /etc/slurm-llnl:/etc/slurm-llnl \
              -v /etc/passwd:/etc/passwd \
              -v /etc/group:/etc/group \
              -p 8081:80 \
              -d slurm-web
