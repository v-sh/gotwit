package commonTmpl

import (
//	"log"
)

type HeadNavBtn struct {
	Href string
}

type HeadNav struct {
	Buttons []HeadNavBtn
}

type PageContainer struct{
	Head HeadNav
	SubName string
}

func GetPageContainer() (res PageContainer) {
	res.Head.Buttons = []HeadNavBtn{
		{Href: "feed"},
		{Href: "mypage"},
		{Href: "search"},
		{Href: ""},
	}
	res.SubName = "sub1"
	return res
}
