#!/bin/sh
compass compile web/assets/ -s compressed
coffee -c -o web/assets/javascripts web/assets/javascripts/