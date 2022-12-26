#!/bin/bash

eval_read() {
    input_file=$1

    while IFS= read -r line; do
        eval echo "$line"
    done <$input_file
}
