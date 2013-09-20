package main

import (
	"log"
	"code.google.com/p/goconf/conf"
	"flag"
	"github.com/v-sh/gotwit/front/httpServe"
)

var confFileName string
var mainConf *conf.ConfigFile

func main() {
	flag.Parse()
	var err error
	mainConf, err = conf.ReadConfigFile(confFileName)
	
	httpServe.Run(mainConf)
	if err != nil {
		log.Panicf("Error reading config file: err %s", err);
	}
}

func init() {
	flag.StringVar(&confFileName, "c", "/usr/local/etc/gotwit/front.conf", 
		"config file");
}




