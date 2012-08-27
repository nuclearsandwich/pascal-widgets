run: Widgets
	./Widgets < widgets.in

Widgets: lc
	fpc Widgets.pas

# Line count since I apparently need to stay under 300 with comments and blanks.
lc:
	wc -l Widgets.pas

test: Widgets
	./Widgets < widgets.in > actual.out
	diff sample.out actual.out
	rm actual.out

.PHONY: run lc
