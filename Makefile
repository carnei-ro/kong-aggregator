VERSION := $(shell grep VERSION src/handler.lua | awk -F'=' '{print $$2}'|tr -d '[:space:]')
NAME := $(shell basename $${PWD})
UID := $(shell id -u)
GID := $(shell id -g)
SUMMARY := $(shell sed -n '/^summary: /s/^summary: //p' README.md)
export UID GID NAME VERSION


build: validate
	@find . -type f -iname "*lua~" -exec rm -f {} \;
	@docker run --rm \
          -v ${PWD}:/plugin \
	  kong /bin/sh -c "apk add --no-cache zip > /dev/null 2>&1 ; cd /plugin ; luarocks make > /dev/null 2>&1 ; luarocks pack ${NAME} 2> /dev/null; chown ${UID}:${GID} *.rock"
	@mkdir -p dist
	@mv *.rock dist/
	@echo -e '\n\n Check "dist" folder \n\n\n'


validate:
	@if [ "x$${VERSION}" == "x" ]; then \
	  echo -e "\n\nNo VERSION found in handler.lua;\nPlease set it in your object that extends the base_plugin.\nEx: plugin.VERSION = \"0.1.0-1\"\n\n"; \
	  exit 1 ;\
	fi
	@if [ ! -f ${NAME}-${VERSION}.rockspec ]; then \
	  make rockspec; \
	fi


rockspec:
	@echo -e 'package = "<NAME>"\nversion = "<VERSION>"\n\nsource = {\n url    = "git@github.com:carnei-ro/${NAME}.git",\n branch = "master"\n}\n\ndescription = {\n  summary = "<SUMMARY>",\n}\n\ndependencies = {\n  "lua ~> 5.1"\n}\n\nbuild = {\n  type = "builtin",\n  modules = {' > rockspec
	@find src/ -type f -iname "*.lua" -exec bash -c 'echo -e \ \ \ \ [\"`echo $${1} | sed -e 's/.lua//g' -e 's/src\//g' | tr '/' '.' | sed "s/^/kong.plugins.$${NAME}/g" `\"] = \"$${1}\",' _ {}  \; >> rockspec
	@echo -e "  }\n}" >> rockspec
	@sed -e "s/<NAME>/${NAME}/" -e "s/<SUMMARY>/${SUMMARY}/" -e "s/<VERSION>/${VERSION}/" rockspec > ${NAME}-${VERSION}.rockspec
	@rm -f rockspec


clean:
	@rm -rf *.rock *.rockspec dist shm
	@find . -type f -iname "*lua~" -exec rm -f {} \;
	@docker-compose down -v


start: validate
	@docker-compose up -d


stop:
	@docker-compose down


kong-logs:
	@docker logs -f `docker ps -qf name=${NAME}_kong_1` 2>&1 || true


kong-bash:
	@docker exec -it `docker ps -qf name=${NAME}_kong_1` bash || true


kong-reload:
	@docker exec -it `docker ps -qf name=${NAME}_kong_1` bash -c "/usr/local/bin/kong reload"


reconfigure: clean start kong-logs




