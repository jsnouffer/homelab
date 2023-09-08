#!/bin/sh

/opt/recipes/venv/bin/gunicorn \
  -b :8080 \
  --access-logfile - \
  --error-logfile - \
  --log-level INFO \
  recipes.wsgi