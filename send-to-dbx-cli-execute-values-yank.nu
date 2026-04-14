#!/usr/bin/env nu
xsel -o -b | databricks-repl-go execute --format json --limit 50 | from json | values | get 3 | select ...($in | columns | take 4) | xsel -i -b
