#!/bin/bash

sudo reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
