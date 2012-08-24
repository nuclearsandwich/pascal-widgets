run: Widgets
	./Widgets

Widgets: lc
	fpc Widgets.pas

# Line count since I apparently need to stay under 300 with comments and blanks.
lc:
	wc -l Widgets.pas

.PHONY: run lc
