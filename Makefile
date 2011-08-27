server:
	@node server.js

compile-game:
	@node_modules/coffee-script/bin/coffee -cw public/game

.PHONY: compile-game app
