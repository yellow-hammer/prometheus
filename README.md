# prometheus

[![OpenYellow](https://openyellow.openintegrations.dev/data/badges/1175541070.svg)](https://openyellow.org/grid?filter=top&repo=1175541070)
[![telegram chat](https://img.shields.io/badge/telegram-chat-green.svg)](https://t.me/wonder_yellow)
[![Ask Devin](https://deepwiki.com/badge.svg)](https://app.devin.ai/org/yellow-hammer/wiki/yellow-hammer/prometheus)

Библиотека сбора метрик Prometheus для OneScript: реестр коллекторов, типы метрик (Counter, Gauge, Histogram,
Summary), Vec-варианты с лейблами и сериализация в [Prometheus Text Format](https://prometheus.io/docs/instrumenting/exposition_formats/).
**Без HTTP** — только логика накопления и сбора метрик. HTTP-сервис отдачи метрик (GET `/metrics`) реализован в
[prometheus-metrics](https://github.com/yellow-hammer/prometheus-metrics) (Autumn, Winow).

## Примеры использования

Подключите библиотеку `#Использовать "prometheus"` и обращайтесь к модулю `Prometheus.*`.

Примеры в каталоге **examples/**:

| Файл                                                    | Описание                                                          |
|---------------------------------------------------------|-------------------------------------------------------------------|
| [Простой.os](examples/Простой.os)                       | Полный обзор: счётчик, индикатор, вектор с лейблами, сбор в текст |
| [СчетчикИИндикатор.os](examples/СчетчикИИндикатор.os)   | Только счётчик и индикатор — минимальный старт                    |
| [ВекторСЛейблами.os](examples/ВекторСЛейблами.os)       | Вектор с лейблами: массив и Соответствие для значений             |
| [ГистограммаИРезюме.os](examples/ГистограммаИРезюме.os) | Гистограмма и резюме, наблюдения через Наблюдать()                |

### Низкоуровневый API (при необходимости)

Для кастомного реестра или тонкой настройки можно использовать модули напрямую: **PrometheusMetrics** (создание и
операции над метриками), **PrometheusVec** (векторы и получение по лейблам), **PrometheusRegistry** (регистрация и
сбор). Тесты в `tests/` покрывают оба варианта — через фасад и низкоуровневый API.

## Для разработчиков

- [CONTRIBUTING.md](CONTRIBUTING.md) — как внести вклад.
- [docs/release.md](docs/release.md) — как выпустить релиз.

## Лицензия

MIT License. Подробности см. в файле [LICENSE](LICENSE).

## Автор

Ivan Karlo (<i.karlo@outlook.com>)

При желании, отблагодарить автора можно по ссылке:

- [Boosty](https://boosty.to/1carlo/donate)
- [Чаевые](https://pay.cloudtips.ru/p/d752cb43)
