[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)

[![LazyingArt banner — apps and four buddies](https://lazying.art/media/brand/lazyingart-intro.gif)](https://lazying.art)

# Agentic Browser

متصفح محلي يعتمد على Chrome و Chrome DevTools Protocol للتحكم اليدوي والذكي في التصفح. يعرض واجهة ويب، لقطة شاشة قابلة للنقر، عناصر DOM، وسجل تشغيل، ويمكنه استخدام `codex exec` لاختيار خطوة واحدة آمنة في كل مرة.

## تشغيل سريع

```bash
python3 -m pip install -r requirements.txt
./run-agentic-browser-vdesktop.sh start
```

افتح `http://127.0.0.1:8794`.

## الفكرة

- يعمل مع Chrome/Chromium الحقيقي.
- يدعم واجهة ويب وواجهة CLI.
- يعمل في وضع headless أو Xephyr أو Xvfb.
- يمنع التنقل إلى روابط تنزيل أو مرايا غير آمنة.
- يحفظ السجلات في `library/`.

راجع [README الرئيسي](../README.md) للتفاصيل الكاملة.

<!-- support:start -->
[![GitHub Sponsors](https://img.shields.io/badge/GitHub-Sponsors-EA4AAA?style=for-the-badge&logo=githubsponsors&logoColor=white)](https://github.com/sponsors/lachlanchen)
[![LazyingArt Support](https://img.shields.io/badge/LazyingArt-Support-0EA5E9?style=for-the-badge)](https://chat.lazying.art/donate)
[![PayPal Support](https://img.shields.io/badge/PayPal-Support-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen)
[![Stripe Support](https://img.shields.io/badge/Stripe-Support-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400)
<!-- support:end -->
