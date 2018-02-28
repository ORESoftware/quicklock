#!/usr/bin/env bash

set -e;

quicklock -m $(pwd) --pid $$;


node test/server.js

