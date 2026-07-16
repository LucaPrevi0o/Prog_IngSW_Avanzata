.DEFAULT_GOAL := help

.PHONY: help setup dev test build

help:
	@printf '%s\n' 'Available commands:' \
	  '  make setup  Install frontend and backend dependencies, then prepare the database.' \
	  '  make dev    Run the Rails API and Angular development server together.' \
	  '  make test   Run the backend test suite.' \
	  '  make build  Create the Angular production build.'

setup:
	cd backend && bundle install && bin/rails db:prepare
	cd frontend && npm ci

dev:
	@set -e; \
	if [ -f .env ]; then set -a; . ./.env; set +a; fi; \
	(cd backend && FRONTEND_ORIGIN="$${FRONTEND_ORIGIN:-http://localhost:4200}" bin/rails server) & backend_pid=$$!; \
	(cd frontend && npm start) & frontend_pid=$$!; \
	trap 'kill $$backend_pid $$frontend_pid 2>/dev/null || true' INT TERM EXIT; \
	wait $$backend_pid $$frontend_pid

test:
	cd backend && bundle exec rails test

build:
	cd frontend && npm run build
