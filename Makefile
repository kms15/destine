SHELL:=/bin/bash

.PHONY: check
check:
	python3 -m unittest -v tests/test_*.py

.PHONY: pedantic
pedantic: .venv/minimal/bin/activate .venv/dev/bin/activate
	# run tests in a minimal environment
	source .venv/minimal/bin/activate && \
		python3 -m unittest -v tests/test_*.py
	# check test coverage
	source .venv/dev/bin/activate && \
		coverage run --branch --source destine -m unittest tests/test_*.py
	source .venv/dev/bin/activate && \
		coverage html --directory=coverage-report
	source .venv/dev/bin/activate && \
		coverage report --show-missing --fail-under=100
	# check code formatting
	source .venv/dev/bin/activate && \
		isort --check-only --profile black . \
		&& black --check .
	echo "### All pedantic checks passed! ###"

.PHONY: clean
clean:
	rm -rf .venv

.PHONY: black
black: .venv/dev/bin/activate
	source .venv/dev/bin/activate && \
		isort --profile black destine tests
	source .venv/dev/bin/activate && \
		black destine tests

.PHONY: watchpedantic
watchpedantic:
	ls destine/*.py \
		tests/*.py \
		Makefile requirements*.txt \
		| entr time $(MAKE) pedantic

.venv/pdm/bin/activate-pdm:
	mkdir -p .venv
	python3 -m venv .venv/pdm
	source .venv/pdm/bin/activate && \
		pip install pdm
	echo "export PDM_PYTHON=$$(pwd)/.venv/pdm/bin/python" > $@
	echo "source $$(pwd)/.venv/pdm/bin/activate" >> $@

.PHONY: update-requirements
update-requirements: .venv/pdm/bin/activate-pdm pyproject.toml
	source .venv/pdm/bin/activate-pdm \
		&& pdm lock -L pdm.lock \
		&& pdm export -L pdm.lock -o requirements.txt \
		&& pdm lock -G dev -L pdm.dev.lock \
		&& pdm export -L pdm.dev.lock -o requirements.dev.txt

.venv/minimal/bin/activate: requirements.txt
	mkdir -p .venv
	rm -rf .venv/minimal
	python3 -m venv .venv/minimal
	source .venv/minimal/bin/activate && \
	 pip3 install -r requirements.txt

.venv/dev/bin/activate: requirements.dev.txt
	mkdir -p .venv
	rm -rf .venv/dev
	python3 -m venv .venv/dev
	source .venv/dev/bin/activate && \
	 pip3 install -r requirements.dev.txt
