ROOTDIR=./rell
CONFDIR=${ROOTDIR}/config
PROJECT=chromia_project
TEST_PROJECT=${PROJECT}_test
ENV?=local
export CHR_CLI_VERSION := 0.8.5

.PHONY: start
start: setenv
	docker compose -p ${PROJECT} up blockchain -d

.PHONY: test
test: setenv
	docker compose -p ${TEST_PROJECT} -f docker-compose-test.yml up \
		--abort-on-container-exit
	docker compose -p ${TEST_PROJECT} down

.PHONY: update
update: setenv
	docker compose -p ${PROJECT} run --rm blockchain_update

.PHONY: restart
restart: stop clear start

.PHONY: clear
clear:
	docker compose -p ${PROJECT} down -v

.PHONY: stop
stop:
	docker compose -p ${PROJECT} down

.PHONY: setenv
setenv:
	${CONFDIR}/generate_config.sh ${ROOTDIR} ${CONFDIR} ${ENV} ${MODULES}

.PHONY: install
install:
	npm install
	npm run install:rell-modules
