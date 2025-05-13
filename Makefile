RELEASE_DIR := $(PWD)/release

IMG_AMD64 := pause-builder-amd64
IMG_AARCH64 := pause-builder-aarch64

prepare:
	@mkdir -p $(RELEASE_DIR)

build-linux-amd64: prepare
	docker build -f docker/linux/Dockerfile.amd64 -t $(IMG_AMD64) .
	docker run --rm -v $(RELEASE_DIR):/opt $(IMG_AMD64) \
		bash -c "cp -a /usr/local/src/pause-amd64.tar.gz /opt/"

build-linux-aarch64: prepare
	docker build -f docker/linux/Dockerfile.aarch64 -t $(IMG_AARCH64) .
	docker run --rm -v $(RELEASE_DIR):/opt $(IMG_AARCH64) \
		bash -c "cp -a /usr/local/src/pause-aarch64.tar.gz /opt/"

build-linux-all: build-linux-amd64 build-linux-aarch64

.PHONY: build build-pause prepare clean

build:
	@echo "Usage: make build-arch ARCH=[all|amd64|aarch64] OS=[linux|windows]"
	@exit 0

build-pause:
ifeq ($(OS),linux)
ifeq ($(ARCH),all)
	$(MAKE) build-linux-all
else ifeq ($(ARCH),amd64)
	$(MAKE) build-linux-amd64
else ifeq ($(ARCH),aarch64)
	$(MAKE) build-linux-aarch64
else
	@echo "Error: Invalid ARCH. Use: all, amd64, or aarch64"
	@exit 1
endif
else ifeq ($(OS),windows)
	@echo "Warn: Windows distro not implemented yet."
	@exit 1
else
	@echo "Error: Invalid OS. Use: linux or windows"
	@exit 1
endif

clean:
	@rm -rf $(RELEASE_DIR)
	@echo "Cleaned: $(RELEASE_DIR) removed."
