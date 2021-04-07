package main

import (
	"github.com/davecgh/go-spew/spew"
	"github.com/seanhagen/hex_test_backend/backend"
)

func main() {
	s := backend.NewServer()
	spew.Dump(s)
}
