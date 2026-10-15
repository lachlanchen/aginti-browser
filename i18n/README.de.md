[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)

[![LazyingArt banner — apps and four buddies](https://lazying.art/media/brand/lazyingart-intro.gif)](https://lazying.art)

# Agentic Browser

Eine lokale agentische Browser-Workbench auf Basis von echtem Chrome/Chromium und Chrome DevTools Protocol. Sie bietet Webapp, klickbare Screenshot-Ansicht, DOM-Beobachtung, CLI und einen `codex exec` Wrapper für sichere Einzelschritte.

## Schnellstart

```bash
python3 -m pip install -r requirements.txt
./run-agentic-browser-vdesktop.sh start
```

Öffne `http://127.0.0.1:8794`.

## Funktionen

- Webapp und CLI steuern denselben Browserdienst.
- Unterstützt headless, Xephyr und Xvfb.
- Beobachtet Screenshot, DOM, Links und sichtbaren Text.
- Sicherheitsregeln blockieren riskante Mirror-, Download- und Direktdatei-URLs.
- Logs werden unter `library/` gespeichert.

Details stehen im [Haupt-README](../README.md).

<!-- support:start -->
[![GitHub Sponsors](https://img.shields.io/badge/GitHub-Sponsors-EA4AAA?style=for-the-badge&logo=githubsponsors&logoColor=white)](https://github.com/sponsors/lachlanchen)
[![LazyingArt Support](https://img.shields.io/badge/LazyingArt-Support-0EA5E9?style=for-the-badge)](https://chat.lazying.art/donate)
[![PayPal Support](https://img.shields.io/badge/PayPal-Support-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen)
[![Stripe Support](https://img.shields.io/badge/Stripe-Support-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400)
<!-- support:end -->
