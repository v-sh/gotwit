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
}

func GetPageContainer() (res PageContainer) {
	res.Head.Buttons = []HeadNavBtn{
		{Href: "feed"},
		{Href: "mypage"},
		{Href: "search"},
		{Href: ""}
	}
	return res
}
