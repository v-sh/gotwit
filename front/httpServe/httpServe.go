package httpServe

import (
	"html/template"
	"net/http"
	"log"
	"code.google.com/p/goconf/conf"
	"path/filepath"
	//"github.com/v-sh/gotwit/front/httpServe/common"
	//"github.com/v-sh/gotwit/front/rsessions"
)

var registerTmpl *template.Template
var loginTmpl *template.Template
var myInfoTmpl *template.Template
var feedTmpl *template.Template
var userSearchTmpl *template.Template

func Run(conf *conf.ConfigFile) {
	initTemplates(conf)
	startServer(conf)
}

func getTemplate(tmplDir string, contentTmplName string) (resTmpl *template.Template) {
	tmplFiles := filepath.Join(tmplDir, "*.tmpl")
	allTmpl, err := template.ParseGlob(tmplFiles)
	if err != nil {
		log.Panicf("err parse template:'%s'", err)
	}
	contentTmpl, err := allTmpl.ParseFiles(filepath.Join(tmplDir, "content", contentTmplName + ".tmpl"))
	if contentTmpl == nil {
		log.Panicf("err parse content template:'%s', err = '%s'",contentTmplName, err)
	}
	resTmpl = allTmpl.Lookup("main_page")
	if resTmpl == nil {
		log.Panicf("error in lookup mainpage in '%s' template", contentTmplName)
	}
	return
}

func initTemplates(conf *conf.ConfigFile) {
	tmplDir, err := conf.GetString("default", "tmpl_dir");
	if err != nil {
		log.Panicf("not specified tmpl_dir: %s", err)
	}

	registerTmpl = getTemplate(tmplDir, "register")
	loginTmpl = getTemplate(tmplDir, "login")
}


func startServer(conf *conf.ConfigFile){
	http.Handle("/", http.HandlerFunc(rootHandler))
	http.Handle("/login/", http.HandlerFunc(loginHandler))
	http.Handle("/register/", http.HandlerFunc(registerHandler))
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


	http.Redirect(w, req, "/login", http.StatusTemporaryRedirect)
	//mainTmpl.Execute(w, pageContainer);
}

func loginHandler(w http.ResponseWriter, req *http.Request) {
	log.Printf("login request: %s", req)
	loginTmpl.Execute(w, "")
}

func registerHandler(w http.ResponseWriter, req *http.Request) {
	registerTmpl.Execute(w, "")
}
