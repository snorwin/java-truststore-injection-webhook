# Run go fmt against code
fmt:
	go fmt ./...
	gofmt -s -w .

# Run go vet against code
vet:
	go vet ./...

# Run golangci-lint
lint:
	golangci-lint run

# Run go mod tidy
tidy:
	go mod tidy

# Run tests
test: tidy fmt vet
	go test ./...  -coverprofile=coverage.out
	go tool cover -func=coverage.out


# Run tests
release: semver
	@version=$$(semver); \
	git tag -s $$version -m"Release $$version"
	goreleaser --rm-dist

test-release:
	goreleaser --skip-publish --snapshot --rm-dist

mocks: mockgen
	mockgen -destination pkg/mocks/core/mock.go     --package core     k8s.io/client-go/kubernetes/typed/core/v1 CoreV1Interface,SecretInterface
	mockgen -destination pkg/mocks/ssclient/mock.go --package ssclient github.com/bitnami-labs/sealed-secrets/pkg/client/clientset/versioned/typed/sealed-secrets/v1alpha1 BitnamiV1alpha1Interface,SealedSecretInterface

semver:
ifeq (, $(shell which semver))
 $(shell go get -u github.com/bakito/semver)
endif
