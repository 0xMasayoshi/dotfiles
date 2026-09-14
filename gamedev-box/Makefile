.PHONY: setup run clean

setup:
	distrobox assemble create --file ./distrobox.ini
	chmod +x ./start.sh

clean:
	-distrobox rm -f godot-dev

run:
	./start.sh
