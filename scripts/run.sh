#!/bin/bash

readonly flutter="${FLUTTER_BIN:-flutter}"

"${flutter}" run "$@" -t example/main.dart

