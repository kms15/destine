SHELL:=/bin/bash

.PHONY: check
check: venv-destine/bin/activate
	source venv-destine/bin/activate && \
		python3 -m pytest \
		--cov=destine \
		--cov-report term-missing \
		--doctest-modules

.PHONY: clean
clean:
	rm -rf venv-destine

.PHONY: black
black: venv-destine/bin/activate
	source venv-destine/bin/activate && \
	 isort destine test
	source venv-destine/bin/activate && \
	 black destine test

.PHONY: container-check
container-check:
	podman run -v .:/app -it --rm debian:stable /bin/bash -c \
	 "cd app && ./install-prereqs.sh && make check"

.PHONY: testwatch
testwatch:
	ls destine/*.py \
		test/*.py \
		Makefile requirements.txt \
		| entr time $(MAKE) check

venv-destine/bin/activate: requirements.txt
	rm -rf venv-destine
	python3 -m venv venv-destine
	source venv-destine/bin/activate && \
	 pip3 install --upgrade pip
	source venv-destine/bin/activate && \
	 pip3 install -r requirements.txt

