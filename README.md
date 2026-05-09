<div align="center">

<img src="docs/assets/logo.png" width="180" alt="Bedrock Ship Logo Made By Developmi" />

# Bedrock Ship - WordPress, Production Ready | Developmi

*Secure, modern WordPress boilerplate in a single Docker image - clone, build, deploy in minutes.*

![PHP](https://img.shields.io/badge/PHP_8.3-777BB4?style=for-the-badge&logo=php&logoColor=white)
![FrankenPHP](https://img.shields.io/badge/FrankenPHP-FFD93C?style=for-the-badge&logo=caddy&logoColor=black)
![Bedrock](https://img.shields.io/badge/Bedrock-Roots.io-525DDC?style=for-the-badge)
![Docker](https://img.shields.io/badge/Docker-READY-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Status](https://img.shields.io/badge/Status-Production_Active-brightgreen?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT_©_Miguel_Lozano_|_Developmi-blue?style=for-the-badge)
![Maintainer](https://img.shields.io/badge/Maintainer-Miguel_Lozano-black?style=for-the-badge)
![Role](https://img.shields.io/badge/Cloud_&_Infrastructure_Engineer-333?style=for-the-badge)

</div>

---

## 📋 Table of contents

- [🎯 Overview](#-overview)
- [⚡ Quick start](#-quick-start)
- [🐳 Production build](#-production-build)
- [🛠️ Customizing](#-customizing)
- [🏗️ Project structure](#-project-structure)
- [🔧 Environment variables](#-environment-variables)
- [🔒 Security](#-security)
- [📄 License](#-license)
- [🤝 Contributing](#-contributing)
- [🤝 Contact & support](#-contact--support)

---

## 🎯 Overview

A **production-ready Docker image** of [Bedrock](https://roots.io/bedrock/) - the modern, secure WordPress boilerplate by [Roots.io](https://roots.io/) - served by [FrankenPHP](https://frankenphp.dev).

It includes **Acorn**, the Laravel integration layer for WordPress, so you get Blade templates, service containers, and all the Laravel goodies right out of the box.

**This is NOT the standard (insecure) WordPress image.** Bedrock moves WordPress core out of the web root, manages plugins/themes via Composer, and stores secrets in environment variables - the way modern applications should.

---

## What's inside

| Layer | Technology |
|-------|------------|
| **Server** | [FrankenPHP](https://frankenphp.dev) (Go + PHP 8.3, Caddy, HTTP/3-ready) |
| **WordPress** | Bedrock structure ([Roots.io](https://roots.io/bedrock/)) |
| **Framework** | [Acorn 6.x](https://roots.io/acorn/) - Laravel in WordPress |
| **Build** | Docker multi-stage (< 150 MB final image) |
| **Security** | Rootless container (www-data), port 8080, OPcache, env-based config |

**Deliberately NOT included** (add these to fit YOUR project):
- Sage theme (you pick your theme)
- Caddy WAF / reverse proxy (add in front if needed)
- Redis / object cache (plugin territory)
- S3 uploads (plugin territory)

---

## ⚡ Quick start

```bash
# 1. Clone
git clone https://github.com/Miguel-DevOps/bedrock-ship.git && cd bedrock-ship

# 2. Configure your environment
cp .env.example .env
# Edit .env - set MARIADB_ROOT_PASSWORD and DATABASE_URL at minimum

# 3. Start everything
docker compose up -d

# 4. Open WordPress installer
open http://localhost:8080
```

That's it. No PHP, no Composer, no Node.js needed locally.

---

## 🐳 Production build

Build the standalone image for any registry:

```bash
# Build
docker build -t bedrock-ship:latest .

# Run (with external database)
docker run -d \
  -p 8080:8080 \
  -e DATABASE_URL=mysql://user:pass@host:3306/dbname \
  -e WP_HOME=https://mysite.com \
  -e WP_SITEURL=https://mysite.com/wp \
  -e AUTH_KEY=... \
  -e SECURE_AUTH_KEY=... \
  # ... (all salts)
  bedrock-ship:latest
```

Or pull the pre-built image from GHCR:

```bash
docker run -d \
  -p 8080:8080 \
  -e DATABASE_URL=mysql://user:pass@host:3306/dbname \
  -e WP_HOME=https://mysite.com \
  -e WP_SITEURL=https://mysite.com/wp \
  -e AUTH_KEY=... \
  # ... (all salts)
  ghcr.io/miguel-devops/bedrock-ship:latest
```

See `.env.example` for the full list of environment variables.

---

## 🛠️ Customizing

### Add a theme

```bash
composer require wpackagist-theme/your-theme
```

Then activate it via WP admin or WP-CLI:

```bash
docker compose exec app wp theme activate your-theme
```

### Add plugins

```bash
composer require wpackagist-plugin/your-plugin
```

### Add Sage later

When you're ready for Sage:

```bash
composer require roots/sage
```

Then extend the `Dockerfile` with a Node.js build stage for asset compilation.

---

## 🏗️ Project structure

```
├── config/                # Bedrock PHP configuration
│   ├── application.php    # Base config (DB, URLs, salts)
│   └── environments/      # Per-environment overrides
├── web/
│   ├── wp/                # WordPress core (Composer, not in git)
│   ├── app/               # Content directory (themes, plugins, uploads)
│   │   └── mu-plugins/    # Must-use plugins (autoloader, disallow-indexing)
│   ├── wp-config.php      # Bootstrap (do not edit)
│   └── index.php          # Front controller
├── Dockerfile             # Multi-stage production image
├── docker-compose.yml     # Local dev (app + MariaDB)
├── scripts/               # Setup, build, backup utilities
└── .env.example           # Environment template
```

---

## 🔧 Environment variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | Yes | `mysql://user:pass@host:port/dbname` |
| `WP_HOME` | Yes | Site URL (e.g. `https://mysite.com`) |
| `WP_SITEURL` | Yes | WordPress URL (e.g. `https://mysite.com/wp`) |
| `WP_ENV` | No | `development`, `staging`, `production` (default) |
| `AUTH_KEY` - `NONCE_SALT` | Yes | WordPress salts (8 variables) |

See `.env.example` for the complete reference.

---

## 🔒 Security

This project follows a coordinated disclosure policy.
If you discover a vulnerability, **do not open a public issue**.
See [SECURITY.md](./SECURITY.md) for reporting instructions and response timelines.

### Key security features

- **Rootless container:** runs as `www-data` (UID 82), never as root
- **OPcache hardened:** timestamp validation disabled in production
- **File modifications disabled:** `DISALLOW_FILE_MODS` prevents admin panel code edits
- **Secrets via environment variables:** no credentials in code or config files
- **Multi-stage Docker build:** no build tools in the final image

---

## Credits

This project orchestrates and dockerizes the incredible work of:

- **[Roots.io](https://roots.io)** - Bedrock, Acorn, and the modern WordPress ecosystem
- **[FrankenPHP](https://frankenphp.dev)** - Kévin Dunglas & contributors

---

## 📄 License

Copyright © 2026 Miguel Lozano | Developmi. All rights reserved.

Licensed under the [MIT License](./LICENSE.md).

---

## 🤝 Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](./CONTRIBUTING.md) before opening a pull request.
This project follows [Conventional Commits](https://www.conventionalcommits.org/) and the Developmi engineering standard.

---

## 🤝 Contact & support

**Maintained by:** Miguel Lozano | Developmi

- **Role:** Cloud & Infrastructure Engineer | FinOps & Bare Metal Specialist | AI Sovereignty Strategist under NIST/DORA Standards
- **Philosophy:** *Security is not a feature; it is the baseline.*
- **Project:** [github.com/Miguel-DevOps/bedrock-ship](https://github.com/Miguel-DevOps/bedrock-ship)
- **Website:** [developmi.com](https://developmi.com)
- **GitHub:** [Miguel-DevOps](https://github.com/Miguel-DevOps)
- **LinkedIn:** [Miguel Lozano](https://www.linkedin.com/in/miguel-dev-ops)

---

© 2026 Miguel Lozano | Developmi. All rights reserved.
