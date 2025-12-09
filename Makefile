generate: clean
	mkdir gen
	bash ./generate.sh

clean:
	rm -rf gen