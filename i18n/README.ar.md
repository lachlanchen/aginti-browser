[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)

[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://lazying.art)

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

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://img.shields.io/badge/Donate-LazyingArt-0EA5E9?style=for-the-badge&logo=kofi&logoColor=white)](https://chat.lazying.art/donate) | [![PayPal](https://img.shields.io/badge/PayPal-RongzhouChen-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen) | [![Stripe](https://img.shields.io/badge/Stripe-Donate-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |
