#!/bin/bash

cd "${0%/*}"
git add .
gem build rulers.gemspec
gem install rulers-0.0.3.gem
