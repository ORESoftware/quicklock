#!/usr/bin/env bash

os=$(uname -s)

if [[ "$os" == "Darwin" ]]; then
    gcc src/kqueue_darwin.c -o bin/kqueue_darwin
else
    gcc src/linux_waiter.c -o bin/linux_waiter
fi

chmod u+x lib/*