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

	@if git show-ref --verify --quiet refs/heads/develop; then \
		echo "Локальная ветка develop есть"; \
		git switch develop; \
	else \
		echo "Создаём локальную ветку develop"; \
		git switch -c develop; \
	fi

	@echo "Пробуем подтянуть изменения с origin..."
	@git pull --rebase origin develop 2>/dev/null || echo "Нет удалённой ветки — ок"

	git add .
	git commit -m "add dns zone" || echo "Нечего коммитить"

	@echo "Пушим..."
	git push -u origin develop

all:
	$(MAKE) build
	$(MAKE) git