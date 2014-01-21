package rsessions

import (
	"github.com/gorilla/sessions"
)


var Store = sessions.NewCookieStore([]byte("kjsd2hgi3rez3aeltkxv"))
