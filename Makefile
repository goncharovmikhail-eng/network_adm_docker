.PHONY: all clean build git

clean:
	rm -rf zones/*/
build:
	@echo "[1] Генерация конфигураций..."
	python3 gen_in_yml.py
	python3 render_zones.py
	python3 generate_named_conf.py

	@echo "[2] Сборка и запуск контейнеров..."
	docker compose down 2>/dev/null || true
	docker compose build
	docker compose up -d

git:
	@echo "[3] Работа с git..."

	@git fetch origin

	@if git show-ref --verify --quiet refs/heads/develop; then \
		git switch develop; \
	else \
		git switch -c develop; \
	fi

	@if git ls-remote --exit-code --heads origin develop >/dev/null 2>&1; then \
		echo "Синхронизируемся с origin (жёстко)"; \
		git reset --soft origin/develop || true; \
	fi

	git add .
	git commit -m "add dns zone" || echo "Нечего коммитить"

	git push -u origin develop

all:
	$(MAKE) build
	$(MAKE) git