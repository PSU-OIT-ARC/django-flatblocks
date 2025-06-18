DEFAULT_GOAL = help
.PHONY := help view-docs test

SHELL=/bin/bash
APP_ENV ?= ""

pipenv_python ?= python3
pipenv = "`pipenv --venv`"
pipenv_bin = "$(pipenv)/bin"
ifneq ($(APP_ENV), "")
  pipenv_bin = "$(APP_ENV)/bin"
endif

ruff_target_python = "py311"


help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install:  ## Installs project dependencies into pipenv
	@pipenv --venv || (pipenv --python $(pipenv_python); pipenv install -e .[all])

documentation: install  ## Builds the currently available documentation.
	@cp README.rst docs/source/introduction.rst
	@cp CHANGELOG.rst docs/source/changelog.rst
	@pipenv run sphinx-build -b html docs/source docs/
	@pipenv run sphinx-build -b latex docs/source docs/build;
	@cd docs/build; make all; cp flatblocks.pdf ../assets/; cd ../../

view-docs: make_pdf=false
view-docs: port=8000
view-docs: documentation  ## Launches a Python HTTP server to view docs
	@$(pipenv_bin)/python -m http.server --bind 0.0.0.0 --dir docs $(port)

update_formatting:  ## Reformats source code given by path. Params 'target_path'
	@echo "Formatting source tree ..."
	@pipenv run ruff format --target-version $(ruff_target_python) flatblocks
	#@git ls-files -z -- 'flatblocks/templates/**/*.html' | xargs -0r pipenv run djade

update_pip_requirements:  ## Updates python dependencies
	@echo "Updating Python release requirements..."; echo ""
	@pipenv --venv || pipenv --python $(pipenv_python)
	@pipenv update --dev
	@pipenv update --outdated || echo "Review the above outdated packages..."
	@pipenv run pip-audit --disable-pip -r <(pipenv requirements --hash)
	@pipenv verify || (echo "Verification failed!" && exit 1)
	@pipenv clean

release: documentation update_formatting ## Performs bookkeeping necessary for a new release
	@echo "Created new release"

test:  ## Run tests
	@$(pipenv_bin)/python runtests.py

upload-dist: install  ## Builds and uploads distribution
	@rm -r ./build || echo "No build assets to remove"
	curl -XGET https://packages.wdt.pdx.edu/publish.sh | VENV=$(pipenv) BUILD_TYPE=bdist_wheel bash -
	@rm -rf ./*.egg-info || echo "No egg assets to remove"
