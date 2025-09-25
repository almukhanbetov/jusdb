#!/bin/sh
set -e

# Установим goose (если нет)
go install github.com/pressly/goose/v3/cmd/goose@latest

# Запустим миграции
/go/bin/goose -dir ./migrations postgres "postgres://postgres:Zxcvbnm123@db:5432/jusdb?sslmode=disable" up
