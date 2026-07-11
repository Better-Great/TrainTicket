package main

import (
	"encoding/json"
	"testing"
)

func TestHelloJSON(t *testing.T) {
	raw := hello()
	var items []map[string]string
	if err := json.Unmarshal([]byte(raw), &items); err != nil {
		t.Fatalf("hello() must return valid JSON: %v", err)
	}
	if len(items) < 2 {
		t.Fatalf("expected at least 2 news items, got %d", len(items))
	}
	if items[0]["Title"] == "" || items[0]["Content"] == "" {
		t.Fatal("first item missing Title or Content")
	}
}

func TestPortDefault(t *testing.T) {
	t.Setenv("NEWS_SERVICE_PORT", "")
	t.Setenv("PORT", "")
	if got := port(); got != "12862" {
		t.Fatalf("default port = %s, want 12862", got)
	}
}

func TestPortFromEnv(t *testing.T) {
	t.Setenv("NEWS_SERVICE_PORT", "13000")
	if got := port(); got != "13000" {
		t.Fatalf("port = %s, want 13000", got)
	}
}
