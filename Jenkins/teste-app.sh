#!/bin/bash

# Variaveis para uso
RESULT="`wget -qO- http://localhost:8090`"
wget -qO- http://localhost:8090

if [ $? -eq 0 ] then
    echo "ok - serviço no ar!"
else if [[ $RESULT == *"Number"* ]] then
    echo "ok - serviço no ar!"
    echo $RESULT
else
    echo "CRITICAL - serviço fora do ar!"
    exit 1
fi
