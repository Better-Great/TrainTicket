package main

import (
	"log"
	"net/http"
	"os"
	"strconv"
)

type News struct {
	Title   string `json:"Title"`
	Content string `json:"Content"`
}

func hello() string {
	return `[
                       {"Title": "News Service Complete", "Content": "Congratulations:Your News Service Complete"},
                       {"Title": "Total Ticket System Complete", "Content": "Just a total test"}
                    ]`
}

func main() {
	addr := "0.0.0.0:" + port()
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			w.WriteHeader(http.StatusMethodNotAllowed)
			return
		}
		w.Header().Set("Content-Type", "application/json; charset=utf-8")
		_, _ = w.Write([]byte(hello()))
	})
	log.Printf("ts-news-service listening on %s", addr)
	log.Fatal(http.ListenAndServe(addr, nil))
}

func port() string {
	if p := os.Getenv("NEWS_SERVICE_PORT"); p != "" {
		if _, err := strconv.Atoi(p); err == nil {
			return p
		}
	}
	if p := os.Getenv("PORT"); p != "" {
		if _, err := strconv.Atoi(p); err == nil {
			return p
		}
	}
	return "12862"
}
