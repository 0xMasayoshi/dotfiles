.PHONY: setup rebuild run clean

setup:
	distrobox assemble create --file ./distrobox.ini

rebuild:
	-distrobox rm -f godot-dev
	distrobox assemble create --file ./distrobox.ini

run:
	./start.sh
