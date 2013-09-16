package main

import (
	"html/template"
	"net/http"
	"log"
	"code.google.com/p/goconf/conf"
)

var templ = template.Must(template.New("mainPage").Parse(mainPage))
var _, _ = templ.Parse(innerDiv)

func main() {
	http.Handle("/", http.HandlerFunc(rootHandler))
	err := http.ListenAndServe("localhost:10001", nil)
	if err != nil {
		log.Fatal("ListernAndServe:", err)
	}
}

func rootHandler(w http.ResponseWriter, req *http.Request) {
	templ.Execute(w, req.FormValue("s"));
}


const mainPage = `
<html>
<head>
<title>GoTwit</title>
</head>
<body>
HI, HERE WILL BE SOMETHING =)!
{{template "innerDiv"}}
</body>
</html>
`

const innerDiv = `
{{define "innerDiv"}}
<div>
HIIIII!!!
</div>
{{end}}
`
