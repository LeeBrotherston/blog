#!/bin/sh

rsync -e "ssh -p 23" --delete -rzvP /Users/lee/hugo/squarelemon/public/ www-publish@wangernumb.squarelemon.com:/data/www/blog.squarelemon.com/
