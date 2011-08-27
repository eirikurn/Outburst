compile-game:
	@node_modules/coffee-script/bin/coffee -cw public/game

app:
	@node server.js

.PHONY: compile-game app
