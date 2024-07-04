#!/usr/bin/env zsh

7z l -ba "$1" | tr -s ' ' | cut -d' ' -f6 | grep --color=never .