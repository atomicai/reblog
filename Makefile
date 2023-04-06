# Smaller is better, but 79 is too little.
LINE_WIDTH=129
NAME := $(shell python setup.py --name)
UNAME := $(shell uname -s)
ISORT_FLAGS=--line-width=${LINE_WIDTH} --profile black
# "" is for multi-lang strings (comments, logs), '' is for everything else.
BLACK_FLAGS=--skip-string-normalization --line-length=${LINE_WIDTH}
PYTEST_FLAGS=-p no:warnings

install:
	pip install -e '.[all]'

index:
	PYTHONPATH=$(shell pwd) python $(shell pwd)/reblog/blog.py --setup

run:
	PYTHONPATH=$(shell pwd) python $(shell pwd)/reblog/blog.py

install-lfs:
ifeq ($(UNAME), Darwin)
	brew install git-lfs
endif
ifeq ($(UNAME), Linux)
	sudo apt-get install git-lfs
endif
	git lfs install

update-lfs:
	git lfs pull

setup-lfs: install-lfs update-lfs

setup-pre-commit:
	pip install -q pre-commit
	pre-commit install
  	# To check whole pipeline.
	pre-commit run --all-files

format:
	isort ${ISORT_FLAGS} --check-only --diff ${NAME} test
	black ${BLACK_FLAGS} --check --diff ${NAME} test

format-fix:
	isort ${ISORT_FLAGS} ${NAME} test
	black ${BLACK_FLAGS} ${NAME} test

test:
	pytest test ${PYTEST_FLAGS} --testmon --suppress-no-test-exit-code

test-all:
	pytest test ${PYTEST_FLAGS}

clean:
	rm -rf *.egg-info
	pyclean $(shell pwd)