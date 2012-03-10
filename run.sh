#!/bin/sh
screen -d -m -S elfari-webservice ruby elfari-webservice.rb
screen -d -m -S elfari ruby elfari.rb

