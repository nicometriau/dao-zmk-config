# Name of the image to build
IMAGE_NAME := dao-zmk-config
TAG := latest

# Default target
all: build

# Build the Docker image
build:
	@echo "🔨 Building Docker image $(IMAGE_NAME):$(TAG)..."
	docker build -t $(IMAGE_NAME):$(TAG) .

# Run the image (optional helper)
run:
	@echo "🚀 Running $(IMAGE_NAME):$(TAG)..."
	docker run --rm \
		-v ./build.yaml:/app/build.yaml \
		-v ./build.sh:/app/build.sh \
		-v ./build:/app/build \
		$(IMAGE_NAME):$(TAG)

.PHONY: all build run
