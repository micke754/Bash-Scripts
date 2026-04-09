#!/usr/bin/env nu
xsel -b | databricks-repl-go execute --format json --limit 10 | from json | values | get 3 | select ...($in | columns | take 4)
