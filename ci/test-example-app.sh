#!/bin/bash
set -e
set -u

SCRIPTPATH=$( cd "$(dirname "$0")" ; pwd -P )
(
  cd "$SCRIPTPATH/.." || exit
  python manage_examples.py test "$LANGUAGE"
)
