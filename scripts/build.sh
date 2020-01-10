#!/bin/bash

readonly flutter="${FLUTTER_BIN:-flutter}"

"${flutter}" build "$@" -t example/main.dart

