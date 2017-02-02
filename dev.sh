#!/bin/bash

export RUN_ENV=development

gradle jrubyJar && java -jar ./build/libs/pik-industry-bot-jruby.jar
