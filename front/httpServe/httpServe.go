package httpServe

import (
	"html/template"
	"net/http"
	"log"
	"code.google.com/p/goconf/conf"
	"path/filepath"
	"github.com/v-sh/gotwit/front/httpServe/common"
)

var allTmpl template.Template
var mainTmpl *template.Template

func Run(conf *conf.ConfigFile) {
	initTemplates(conf)
	startServer(conf)
}

func initTemplates(conf *conf.ConfigFile) {
	tmplDir, err := conf.GetString("default", "tmpl_dir");
	if err != nil {
		log.Panicf("not specified tmpl_dir: %s", err)
	}
	tmplPattern, err := conf.GetString("default", "tmpl_pattern")
	if err != nil {
		tmplPattern = "*.tmpl"
	}

	tmplFiles := filepath.Join(tmplDir, tmplPattern)
	allTmpl, err := template.ParseGlob(tmplFiles)
	if err != nil {
		log.Panicf("err parse template:%s", err)
	}
	mainPageTmplName, err := conf.GetString("default", "tmpl_mainpage")
	if err != nil {
		log.Panicf("not specified tmpl_mainpage: %s",err)
	}

	mainTmpl = allTmpl.Lookup(mainPageTmplName)
	if mainTmpl == nil {
		log.Panicf("there is no template '%s' in parsed templates", mainPageTmplName)
	}
}


func startServer(conf *conf.ConfigFile){
	http.Handle("/", http.HandlerFunc(rootHandler))
	host, err := conf.GetString("default", "host")
	if err != nil {
		log.Panic("not specified host");
	}
	port, _ := conf.GetString("default", "port")
	if err != nil {
		log.Panic("not specified port");
	}
	err = http.ListenAndServe(host + ":"+  port, nil)
	if err != nil {
		log.Fatal("ListernAndServe:", err)
	}
	
}



func rootHandler(w http.ResponseWriter, req *http.Request) {
	//collect data

	//output data
	var outdata commonTmpl.PageContainer

	
	mainTmpl.Execute(w, pageContainer);
}
