package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	// 📌 Получаем DATABASE_URL из переменных окружения
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		log.Fatal("❌ DATABASE_URL is not set")
	}

	// 📌 Подключаемся к PostgreSQL через pgxpool
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatalf("❌ Failed to create pgx pool: %v", err)
	}
	defer pool.Close()

	if err := pool.Ping(ctx); err != nil {
		log.Fatalf("❌ Failed to ping DB: %v", err)
	}
	log.Println("✅ Connected to DB")

	// 📌 Создаём Gin
	r := gin.Default()

	// --- Healthcheck endpoint ---
	r.GET("/healthz", func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
		defer cancel()

		var result int
		if err := pool.QueryRow(ctx, "SELECT 1").Scan(&result); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"status": "error",
				"db":     err.Error(),
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"status": "ok",
			"db":     "connected",
		})
	})

	// 📌 Стартуем сервер
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("🚀 Starting server on :%s\n", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("❌ Server failed: %v", err)
	}
}
