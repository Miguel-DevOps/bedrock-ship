# ==========================================
# Stage 1: PHP Dependencies (Composer)
# ==========================================
FROM composer:2.8 AS php-builder
WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --classmap-authoritative \
    --no-scripts

COPY . .
RUN composer dump-autoload --optimize --classmap-authoritative --no-dev

# ==========================================
# Stage 2: Production Image (FrankenPHP)
# ==========================================
FROM dunglas/frankenphp:1-php8.3-alpine

# PHP extensions required by WordPress + Bedrock + Acorn
RUN install-php-extensions \
    mysqli \
    pdo_mysql \
    gd \
    intl \
    zip \
    opcache \
    exif

# WP-CLI from official WordPress CLI image
COPY --from=wordpress:cli-php8.3 /usr/local/bin/wp /usr/local/bin/wp

WORKDIR /app
COPY --from=php-builder /app /app

ENV SERVER_NAME=":8080"

# FrankenPHP Caddyfile — php_server handles all PHP requests
RUN printf '{\n\tfrankenphp\n}\n{$SERVER_NAME:localhost} {\n\troot * /app/web\n\tencode zstd br gzip\n\tphp_server\n}\n' > /etc/frankenphp/Caddyfile

# OPcache — aggressive settings for production WordPress
RUN printf "opcache.enable=1\nopcache.enable_cli=0\nopcache.memory_consumption=256\nopcache.interned_strings_buffer=32\nopcache.max_accelerated_files=100000\nopcache.validate_timestamps=0\nopcache.revalidate_freq=0\n" > /usr/local/etc/php/conf.d/zz-opcache.ini

# PHP limits — generous defaults for WordPress admin/media
RUN printf "file_uploads=On\nmemory_limit=256M\nupload_max_filesize=256M\npost_max_size=300M\nmax_execution_time=600\n" > /usr/local/etc/php/conf.d/uploads.ini

# Error logging to stderr (Docker best practice)
RUN printf "error_reporting=E_ERROR|E_WARNING|E_PARSE|E_CORE_ERROR|E_CORE_WARNING|E_COMPILE_ERROR|E_COMPILE_WARNING|E_RECOVERABLE_ERROR\ndisplay_errors=Off\nlog_errors=On\nerror_log=/dev/stderr\n" > /usr/local/etc/php/conf.d/error-logging.ini

# Writable directories — uploads (user content) + cache (Acorn Blade views)
RUN mkdir -p /app/web/app/uploads /app/web/app/cache \
 && chown -R www-data:www-data /app/web/app/uploads /app/web/app/cache \
 && chmod 775 /app/web/app/uploads /app/web/app/cache

# Caddy data/config directories — must be writable by www-data
RUN mkdir -p /data/caddy /config/caddy \
 && chown -R www-data:www-data /data /config \
 && chmod 775 /data /config

# Health check — verify FrankenPHP is serving WordPress
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:8080 || exit 1

USER www-data
EXPOSE 8080
