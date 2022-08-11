#!/bin/sh

echo "${HOST_IP}" > etc/gwsetup_only

cd share/data

(
  ../dist/gw/gwsetup \
    -p 2316 \
    -gd ../dist/gw \
    -lang ${LANGUAGE} \
    -only ../../etc/gwsetup_only 2>&1 | tee -a ${HOME}/gwsetup.log
) &

../dist/gw/gwd \
  -lang ${LANGUAGE} \
  -hd ../dist/gw \
  -p 2317 \
  -log ${HOME}/geneweb.log
