package main

import (
	"html/template"
	"net/http"
	"log"
	"code.google.com/p/goconf/conf"
	"flag"
	"path/filepath"
)

var allTmpl template.Template
var mainTmpl *template.Template//= template.Must(template.New("mainPage").Parse(mainPage))
//var _, _ = templ.Parse(innerDiv)
var confFileName string
var mainConf *conf.ConfigFile

func main() {
	flag.Parse()
	var err error
	mainConf, err = conf.ReadConfigFile(confFileName)
	
	initTemplates()
	startServer()
	if err != nil {
		log.Panicf("Error reading config file: err %s", err);
	}
}

func initTemplates() {
	tmplDir, err := mainConf.GetString("default", "tmpl_dir");
	if err != nil {
		log.Panicf("not specified tmpl_dir: %s", err)
	}
	tmplPattern, err := mainConf.GetString("default", "tmpl_pattern")
	if err != nil {
		tmplPattern = "*.tmpl"
	}

	tmplFiles := filepath.Join(tmplDir, tmplPattern)
	allTmpl, err := template.ParseGlob(tmplFiles)
	if err != nil {
		log.Panicf("err parse template:%s", err)
	}
	mainPageTmplName, err := mainConf.GetString("default", "tmpl_mainpage")
	if err != nil {
		log.Panicf("not specified tmpl_mainpage: %s",err)
	}

	mainTmpl = allTmpl.Lookup(mainPageTmplName)
	if mainTmpl == nil {
		log.Panicf("there is no template '%s' in parsed templates", mainPageTmplName)
	}
}

func startServer(){
	http.Handle("/", http.HandlerFunc(rootHandler))
	host, err := mainConf.GetString("default", "host")
	if err != nil {
		log.Panic("not specified host");
	}
	port, _ := mainConf.GetString("default", "port")
	if err != nil {
		log.Panic("not specified port");
	}
	err = http.ListenAndServe(host + ":"+  port, nil)
	if err != nil {
		log.Fatal("ListernAndServe:", err)
	}
	
}

func init() {
	flag.StringVar(&confFileName, "c", "/usr/local/etc/gotwit/front.conf", 
		"config file");
}

func rootHandler(w http.ResponseWriter, req *http.Request) {
	mainTmpl.Execute(w, req.FormValue("s"));
}





