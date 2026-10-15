[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)

[![LazyingArt banner — apps and four buddies](https://lazying.art/media/brand/lazyingart-intro.gif)](https://lazying.art)

# Agentic Browser

Chrome/Chromium と Chrome DevTools Protocol を使った、ローカル優先のエージェント型ブラウザ作業台です。Web UI、クリック可能なスクリーンショット、DOM 観察、CLI、`codex exec` による一手ずつの制御を提供します。

## クイックスタート

```bash
python3 -m pip install -r requirements.txt
./run-agentic-browser-vdesktop.sh start
```

`http://127.0.0.1:8794` を開きます。

## 機能

- Webapp と CLI から同じ制御ブラウザを操作。
- headless、Xephyr、Xvfb モードに対応。
- スクリーンショット、DOM、リンク、可視テキストをまとめて観察。
- 安全ポリシーで危険なミラーや直接ダウンロードをブロック。
- 実行ログを `library/` に保存。

詳細は [メイン README](../README.md) を参照してください。

<!-- support:start -->
[![GitHub Sponsors](https://img.shields.io/badge/GitHub-Sponsors-EA4AAA?style=for-the-badge&logo=githubsponsors&logoColor=white)](https://github.com/sponsors/lachlanchen)
[![LazyingArt Support](https://img.shields.io/badge/LazyingArt-Support-0EA5E9?style=for-the-badge)](https://chat.lazying.art/donate)
[![PayPal Support](https://img.shields.io/badge/PayPal-Support-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen)
[![Stripe Support](https://img.shields.io/badge/Stripe-Support-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400)
<!-- support:end -->
