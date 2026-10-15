[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)

[![LazyingArt banner — apps and four buddies](https://lazying.art/media/brand/lazyingart-intro.gif)](https://lazying.art)

# Agentic Browser

Локальная рабочая среда для агентного браузинга на базе настоящего Chrome/Chromium и Chrome DevTools Protocol. Она предоставляет веб-интерфейс, кликабельный скриншот, наблюдение DOM, CLI и wrapper `codex exec` для безопасного пошагового управления.

## Быстрый старт

```bash
python3 -m pip install -r requirements.txt
./run-agentic-browser-vdesktop.sh start
```

Откройте `http://127.0.0.1:8794`.

## Возможности

- Webapp и CLI управляют одним браузерным сервисом.
- Поддерживаются headless, Xephyr и Xvfb.
- Наблюдение скриншота, DOM, ссылок и видимого текста.
- Политика безопасности блокирует опасные mirror/download/direct-file URL.
- Логи сохраняются в `library/`.

Полная документация находится в [главном README](../README.md).

<!-- support:start -->
[![GitHub Sponsors](https://img.shields.io/badge/GitHub-Sponsors-EA4AAA?style=for-the-badge&logo=githubsponsors&logoColor=white)](https://github.com/sponsors/lachlanchen)
[![LazyingArt Support](https://img.shields.io/badge/LazyingArt-Support-0EA5E9?style=for-the-badge)](https://chat.lazying.art/donate)
[![PayPal Support](https://img.shields.io/badge/PayPal-Support-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen)
[![Stripe Support](https://img.shields.io/badge/Stripe-Support-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400)
<!-- support:end -->
