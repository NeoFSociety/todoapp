include .env 
export

export PROJECT_ROOT = $(CURDIR)

env-up:
	@docker compose up -d todoapp-postgres

env-down:
	@docker compose down todoapp-postgres

env-cleanup:
	@powershell -Command "Write-Host 'WARNING: This will delete ALL database data!' -ForegroundColor Yellow; Read-Host 'Press Enter to continue or Ctrl+C to cancel'"
	docker compose down todoapp-postgres
	@powershell -Command "if (Test-Path out\pgdata) { Remove-Item -Recurse -Force out\pgdata; Write-Host 'SUCCESS: Data cleared' -ForegroundColor Green } else { Write-Host 'INFO: Folder already empty' -ForegroundColor Cyan }"


migrate-create:
	@if "$(seq)"=="" ( \
		echo "Error: parameter seq is required. Example: make migrate-create seq=create_users_table" && \
		exit 1 \
	)
	docker compose run --rm todoapp-postgres-migrate create -ext sql -dir /migrations -seq "$(seq)"

migrate-action:
	@if "$(action)"=="" ( \
		echo "Error: parameter action is required. Example: make migrate-action action=up" && \
		exit 1 \
	)
	docker compose run --rm todoapp-postgres-migrate \
		-path /migrations \
		-database "postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@todoapp-postgres:5432/$(POSTGRES_DB)?sslmode=disable" \
		$(action)

migrate-up:
	@make migrate-action action=up

migrate-down:
	@make migrate-action action=down	

env-port-forward:
	@docker compose up -d port-forwarder

env-port-close:
	@docker compose down port-forwarder

