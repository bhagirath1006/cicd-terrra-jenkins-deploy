FROM php:8.2-fpm

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create a minimal Laravel-like composer.json
RUN printf '{\n  "name": "laravel/project",\n  "require": {"php": "^8.2"},\n  "require-dev": {}\n}\n' > composer.json && \
    composer install --no-dev --no-scripts

# Create a simple index.php
RUN printf '<?php echo "Laravel API is running"; ?>\n' > index.php

EXPOSE 9000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:9000 || exit 1

CMD ["php-fpm"]

CMD ["php-fpm"]
