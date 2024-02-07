SHELL:=/bin/bash

.PHONY: check
check: .venv/test/bin/activate
	source .venv/test/bin/activate && \
		python3 -m pytest \
		--cov=destine \
		--cov-report term-missing \
		--doctest-modules

.PHONY: clean
clean:
	rm -rf .venv

.PHONY: black
black: .venv/dev/bin/activate
	source .venv/dev/bin/activate && \
	 isort destine test
	source .venv/dev/bin/activate && \
	 black destine test

.PHONY: testwatch
testwatch:
	ls destine/*.py \
		test/*.py \
		Makefile requirements.txt \
		| entr time $(MAKE) check

.venv/pdm/bin/pdm:
	mkdir -p .venv
	python3 -m venv .venv/pdm
	.venv/pdm/bin/pip install pdm

.PHONY: update-requirements
update-requirements: .venv/pdm/bin/pdm pyproject.toml
	.venv/pdm/bin/pdm lock -L pdm.lock
	.venv/pdm/bin/pdm export -L pdm.lock -o requirements.txt
	.venv/pdm/bin/pdm lock -G dev -L pdm.dev.lock
	.venv/pdm/bin/pdm export -L pdm.dev.lock -o requirements.dev.txt
	.venv/pdm/bin/pdm lock -G test -L pdm.test.lock
	.venv/pdm/bin/pdm export -L pdm.test.lock -o requirements.test.txt

.venv/test/bin/activate: requirements.test.txt
	mkdir -p .venv
	rm -rf .venv/test
	python3 -m venv .venv/test
	source .venv/test/bin/activate && \
	 pip3 install -r requirements.test.txt

.venv/dev/bin/activate: requirements.dev.txt
	mkdir -p .venv
	rm -rf .venv/dev
	python3 -m venv .venv/dev
	source .venv/dev/bin/activate && \
	 pip3 install -r requirements.dev.txt
