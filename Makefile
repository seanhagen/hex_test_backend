#!make

EMPTY :=
SPACE := $(EMPTY) $(EMPTY)
COMMA :=,

NOW=$(shell date +"%s")

GO_BUILD_ENV:=CGO_ENABLED=0 GOOS=linux GOARCH=amd64

OUTPUT="./server"
DEBUG_OUTPUT="./debug"

LDFLAGS=
LDFLAGBUILD=-ldflags "$(LDFLAGS) -s -w"
LDFLAGDEBUG=-ldflags "$(LDFLAGS)"

SOURCEDIR=.
SOURCES := $(shell find $(SOURCEDIR) -name '*.go')

SERVICES=game


PROTO_DIR=proto
PROTOCMD=protoc
PROTOC=$(PROTOCMD) $(IMPORTS)
IMPORTS=-I"./${PROTO_DIR}/"

PROTO_FILES_IN=$(shell find "$(PROTO_DIR)" -name '*.proto')
VALID_FILES_IN=$(shell find "$(PROTO_DIR)" -name '*.proto'| grep -vE "/service")

PB_FILES=$(subst protos,go,$(PROTO_FILES_IN:.proto=.pb.go))

GO_PROTO_OUT=$(PB_FILES)
GO_PROTO_OUT_DIR=pb

test:
	echo $(PROTO_FILES_IN)

$(OUTPUT):   $(SOURCES)
	$(GO_BUILD_ENV) go build -a ${LDFLAGBUILD} -o ${OUTPUT} -installsuffix cgo .


$(PB_FILES): $(VALID_FILES_IN)
	@mkdir -p $(dir $@)
	$(eval Y=$(subst go/,,$@))
	$(eval Y=$(patsubst %/,%,$(dir $Y)))
	$(eval T=$(subst go/,protos/,$@))
	$(eval T=$(subst pb.go,proto,$T))
	@echo "Generating $@ from $T"
	$(PROTOCMD) $(IMPORTS) --go-grpc_out=paths=source_relative:$(GO_PROTO_OUT_DIR)  $(T)
	$(PROTOCMD) $(IMPORTS) --go_out=paths=source_relative:$(GO_PROTO_OUT_DIR) $(T)

pbs:  $(PB_FILES)
