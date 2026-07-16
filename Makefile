.DEFAULT_GOAL := help

.PHONY: help setup dev test build coverage-backend

help:
	@printf '%s\n' 'Available commands:' \
	  '  make setup  Install frontend and backend dependencies, then prepare the database.' \
	  '  make dev    Run the Rails API and Angular development server together (reads .env).' \
	  '  make test   Run the backend test suite.' \
	  '  make coverage-backend  Run backend tests with enforced SimpleCov thresholds.' \
	  '  make build  Create the Angular production build.'

setup:
	cd backend && bundle install && bin/rails db:prepare
	cd frontend && npm ci

dev:
	@set -e; \
	if [ -f .env ]; then set -a; . ./.env; set +a; fi; \
	(cd frontend && API_BASE_URL="$${API_BASE_URL:-http://localhost:3000}" node scripts/write-runtime-config.mjs); \
	(cd backend && FRONTEND_ORIGIN="$${FRONTEND_ORIGIN:-http://localhost:4200}" bin/rails server) & backend_pid=$$!; \
	(cd frontend && npm start) & frontend_pid=$$!; \
	trap 'kill $$backend_pid $$frontend_pid 2>/dev/null || true' INT TERM EXIT; \
	wait $$backend_pid $$frontend_pid

test:
	cd backend && bundle exec rails test

coverage-backend:
	cd backend && COVERAGE=true bundle exec rails test

build:
	cd frontend && npm run build
