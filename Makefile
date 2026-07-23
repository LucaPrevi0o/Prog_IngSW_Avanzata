.DEFAULT_GOAL := help

.PHONY: help setup dev test-backend build coverage-backend test-frontend coverage-frontend compose-up compose-down

help:
	@printf '%s\n' 'Available commands:' \
	  '  make setup  Install frontend and backend dependencies, then prepare the database.' \
	  '  make dev    Run the Rails API and Angular development server together (reads .env).' \
	  '  make test-backend  Run the backend test suite.' \
	  '  make coverage-backend  Run backend tests with enforced SimpleCov thresholds.' \
	  '  make test-frontend  Run Angular unit tests once.' \
	  '  make coverage-frontend  Run Angular tests with Vitest coverage thresholds.' \
	  '  make compose-up  Build and start the complete containerized stack.' \
	  '  make compose-down  Stop the containerized stack.' \
	  '  make build  Create the Angular production build.'

setup:
	@set -e; \
	if [ -f .env ]; then set -a; . ./.env; set +a; fi; \
	(cd backend && export SEED_ADMIN_EMAIL="$${SEED_ADMIN_EMAIL:-admin@example.com}" SEED_ADMIN_PASSWORD="$${SEED_ADMIN_PASSWORD:-secret123}"; bundle install && bin/rails db:prepare)
	cd frontend && npm ci

dev:
	@set -e; \
	if [ -f .env ]; then set -a; . ./.env; set +a; fi; \
	(cd frontend && API_BASE_URL="$${API_BASE_URL:-http://localhost:3000}" node scripts/write-runtime-config.mjs); \
	(cd backend && FRONTEND_ORIGIN="$${FRONTEND_ORIGIN:-http://localhost:4200}" bin/rails server) & backend_pid=$$!; \
	(cd frontend && npm start) & frontend_pid=$$!; \
	trap 'kill $$backend_pid $$frontend_pid 2>/dev/null || true' INT TERM EXIT; \
	wait $$backend_pid $$frontend_pid

test-backend:
	cd backend && bundle exec rails test

coverage-backend:
	cd backend && COVERAGE=true bundle exec rails test

test-frontend:
	cd frontend && npm test -- --watch=false

coverage-frontend:
	cd frontend && npm run test:ci

compose-up:
	docker compose up --build

compose-down:
	docker compose down

build:
	cd frontend && npm run build
