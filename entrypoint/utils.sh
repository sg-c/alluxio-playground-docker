#!/bin/bash

eval_read() {
    input_file=$1
    (
        echo "cat <<EOF"
        cat $input_file
        echo " " # deal with EOF correctly
        echo EOF
    ) | sh
}
