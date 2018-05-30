#!/usr/bin/env bash


rm -f xxx;
mkfifo xxx;

cat xxx | while read line; do
  echo "from fifo 1: $line";
done &

cat xxx | while read line; do
  echo "from fifo 2: $line";
done &

cat xxx | while read line; do
  echo "from fifo 3: $line";
done &

echo -e "foo\n" > xxx;
echo -e "bar\n" > xxx;
echo -e "baz\n" > xxx;

wait;