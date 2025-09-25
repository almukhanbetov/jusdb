# ---------------------------
# Stage 1: build
# ---------------------------
FROM golang:1.24-alpine AS build

WORKDIR /app

# Установим нужные утилиты
RUN apk add --no-cache git bash

# Ставим goose (нужно для миграций)
RUN go install github.com/pressly/goose/v3/cmd/goose@latest

# Копируем исходники
COPY . .

# Собираем бинарь приложения
RUN go build -o simplecrud .

# ---------------------------
# Stage 2: runtime
# ---------------------------
FROM alpine:3.19

WORKDIR /app

# Устанавливаем psql клиент для проверки соединения
RUN apk add --no-cache bash postgresql-client

# Копируем бинарь из первого stage
COPY --from=build /app/simplecrud /app/
# Копируем goose (он попадает в /go/bin внутри build stage)
COPY --from=build /go/bin/goose /usr/local/bin/goose
# Копируем миграции
COPY --from=build /app/migrations /app/migrations

EXPOSE 8080

CMD ["/app/simplecrud"]
