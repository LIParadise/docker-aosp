DOCKER_IMAGE_NAME    := diy_arch_aosp
DOCKER_IMAGE_TAG     := v1.14
DOCKER_UID           := 1000
DOCKER_GID           := 1000
DOCKER_NSJAIL_BYPASS := --security-opt apparmor=unconfined --security-opt seccomp=unconfined --security-opt systempaths=unconfined

guard-env-%:
	@# https://stackoverflow.com/questions/4728810
	@#
	@# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html
	@# |                        | If set and not null    | If set but null     | If unset         |
	@# | ---------------------- | ---------------------- | ------------------- | ---------------- |
	@# | `${parameter:-word}`   | substitute parameter   | substitute word     | substitute word  |
	@# | `${parameter-word}`    | substitute parameter   | substitute null     | substitute word  |
	@# | `${parameter:=word}`   | substitute parameter   | assign word         | assign word      |
	@# | `${parameter=word}`    | substitute parameter   | substitute null     | assign word      |
	@# | `${parameter:?word}`   | substitute parameter   | error, exit         | error, exit      |
	@# | `${parameter?word}`    | substitute parameter   | substitute null     | error, exit      |
	@# | `${parameter:+word}`   | substitute word        | substitute null     | substitute null  |
	@# | `${parameter+word}`    | substitute word        | substitute word     | substitute null  |
	@ if [ ! "$${$(*):+undef}" = "undef" ]; then \
		echo "env '$(*)' not set, abort."; \
		exit 1; \
	fi

.PHONY: build_image
build_image:
	docker build . -t $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) -f Dockerfile --network host

.PHONY: run_image
run_image: guard-env-AOSP_SRC
	@# https://issuetracker.google.com/issues/123210688?pli=1
	docker run -it --rm $(DOCKER_NSJAIL_BYPASS) --user $(DOCKER_UID):$(DOCKER_GID) -v $${AOSP_SRC}:/aosp $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)
