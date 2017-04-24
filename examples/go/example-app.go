package main

import (
	"fmt"
	"net/http"
	"os"
)

const (
	// PortVar = name of env variable for the port to listen on
	PortVar = "PORT"
)

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "<p>Hello World! I'm a go application</p>")
}

func main() {
	// bind handler function to root
	http.HandleFunc("/", handler)

	var port string
	if port = os.Getenv(PortVar); port == "" {
		port = "8080"
	}

	fmt.Printf("Listening at port %v\n", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		panic(err)
	}
}
