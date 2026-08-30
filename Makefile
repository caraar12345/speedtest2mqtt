GIT_HASH ?= $(shell git log --format="%h" -n 1)

_BUILD_ARGS_BUILD_VERSION ?= $(shell yq .version config.yaml)
_BUILD_ARGS_BUILD_REVISION ?= ${GIT_HASH}
_BUILD_ARGS_BUILD_TIME ?= $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
_BUILD_ARGS_SPEEDTEST_URL_TEMPLATE ?= "https://install.speedtest.net/app/cli/ookla-speedtest-"
# Bumping this pulls in a newer Ookla CLI on the next build. Home Assistant
# only surfaces an update to users when config.yaml's `version` also
# changes, so bump that alongside this (the check-version target below
# will refuse to push otherwise).
_SPEEDTEST_VERSION ?= 1.2.0

PLATFORMS ?= linux/arm64,linux/amd64,linux/armhf,linux/i386
LOCAL_PLATFORM ?= linux/amd64
GITHUB_USERNAME ?= caraar12345
GITHUB_REPO ?= home-assistant-addons
ADDON_NAME ?= speedtest-mqtt

# CI runs `make build` on every push to main, and always tags the image
# with config.yaml's version. If that version isn't bumped, a genuinely
# different image silently overwrites the previously published one under
# the same tag, and Home Assistant never shows users an update. Refuse to
# push in that case; set FORCE=1 to override deliberately.
check-version:
	@if [ "$(FORCE)" != "1" ] && docker manifest inspect ghcr.io/${GITHUB_USERNAME}/${GITHUB_REPO}/${ADDON_NAME}:${_BUILD_ARGS_BUILD_VERSION} >/dev/null 2>&1; then \
		echo "error: version ${_BUILD_ARGS_BUILD_VERSION} (from config.yaml) is already published for ${ADDON_NAME}." >&2; \
		echo "       Bump config.yaml's version before merging, or re-run with FORCE=1 to override." >&2; \
		exit 1; \
	fi

build: check-version
	docker buildx build --push \
		--platform $(PLATFORMS) \
		-t ghcr.io/${GITHUB_USERNAME}/${GITHUB_REPO}/${ADDON_NAME}:${_BUILD_ARGS_BUILD_REVISION} \
		-t ghcr.io/${GITHUB_USERNAME}/${GITHUB_REPO}/${ADDON_NAME}:${_BUILD_ARGS_BUILD_VERSION} \
		-t ghcr.io/${GITHUB_USERNAME}/${GITHUB_REPO}/${ADDON_NAME}:latest \
		--build-arg BUILD_TIME=${_BUILD_ARGS_BUILD_TIME} \
		--build-arg BUILD_REVISION=${_BUILD_ARGS_BUILD_REVISION} \
		--build-arg BUILD_VERSION=${_BUILD_ARGS_BUILD_VERSION} \
		--build-arg SPEEDTEST_URL_TEMPLATE=${_BUILD_ARGS_SPEEDTEST_URL_TEMPLATE} \
		--build-arg SPEEDTEST_VERSION=${_SPEEDTEST_VERSION} .

build_local:
	docker buildx build --load \
		--platform $(LOCAL_PLATFORM) \
		-t ghcr.io/${GITHUB_USERNAME}/${GITHUB_REPO}/${ADDON_NAME}:${_BUILD_ARGS_BUILD_REVISION} \
		--build-arg BUILD_TIME=${_BUILD_ARGS_BUILD_TIME} \
		--build-arg BUILD_REVISION=${_BUILD_ARGS_BUILD_REVISION} \
		--build-arg BUILD_VERSION=${_BUILD_ARGS_BUILD_VERSION} \
		--build-arg SPEEDTEST_URL_TEMPLATE=${_BUILD_ARGS_SPEEDTEST_URL_TEMPLATE} \
		--build-arg SPEEDTEST_VERSION=${_SPEEDTEST_VERSION} .
