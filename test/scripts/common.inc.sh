#!/bin/bash

PROJECT="__PROJECT__"

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( cd "${SCRIPTS_DIR}/../../" && pwd )"
TEST_ENV_DIR="$( cd "${PROJECT_DIR}/test/env" && pwd )"
TEST_EXE="${PROJECT_DIR}/build/test/${PROJECT}_test"
