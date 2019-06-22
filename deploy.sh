#!/bin/sh

rsync -e "ssh -p 23" --delete -rzvP ./public/ www-publish@wangernumb.squarelemon.com:/data/www/blog.squarelemon.com/
