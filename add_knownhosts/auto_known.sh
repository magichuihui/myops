#!/bin/bash

key=/home/kyra/keygens/qingdao
port=2323

cat guangzhou | while read line; do
    expect add_known.exp $line $port $key
done
