import os
from jinja2 import Environment, FileSystemLoader

# Пути
template_dir = 'templates'
zones_dir = 'zones'
main_named_conf = 'dns.d/named.conf'
main_env = Environment(loader=FileSystemLoader(template_dir))

# Загрузка шаблона
template = main_env.get_template('named.conf.j2')

# Считывание переменных окружения из .env
env_vars = {}
with open('.env') as f:
    for line in f:
        line = line.strip()
        if line and not line.startswith('#') and '=' in line:
            key, val = line.split('=', 1)
            env_vars[key.strip()] = val.strip()

# Генерация абсолютных путей include
zone_includes = []
for zone_name in os.listdir(zones_dir):
    zone_path = os.path.join(zones_dir, zone_name)
    include_file = os.path.join(zone_path, 'named.zones.include')

    if os.path.isdir(zone_path) and os.path.isfile(include_file):
        # Абсолютный путь к файлу в BIND окружении
        bind_zone_include_path = f'/var/named/zones/{zone_name}/named.zones.include'
        zone_includes.append(f'include "{bind_zone_include_path}";')

# Рендеринг шаблона
rendered_conf = template.render(
    **env_vars,
    zone_includes=zone_includes
)

# Запись в целевой файл
os.makedirs(os.path.dirname(main_named_conf), exist_ok=True)
with open(main_named_conf, 'w') as f:
    f.write(rendered_conf)

print(f"Конфигурация BIND сгенерирована в: {main_named_conf}")
