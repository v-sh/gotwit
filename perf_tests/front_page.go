package main


import (
	"log"
	"net/http"
	"os"
	"time"
)

func main() {
	log.Println("hi")
	results := make(chan int, 10000)

	count := 0;
	go func(){
		<- time.After(time.Minute)
		log.Println(count);
		os.Exit(0)
	}()
	for i := 0; i < 1000; i++ {
		go getter(results, "http://localhost/")
	}
	for i := range results {
		count = count + i
		//log.Println(count)
	}
}

func getter(res chan int, req string){
	for {
		resp, err := http.Get(req)
		if err != nil { 
			log.Print("err = ", err );
		}
		resp.Body.Close()
		res <- 1
	}
}



