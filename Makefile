# Default test pattern
PATTERN ?= test_*.py
IMAGE_NAME := test-scout

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME) .

# Run the script directly in Codespaces
test:
	./entrypoint.sh $(PATTERN)

# Run in container using current directory
run: build
	docker run --rm \
		-v $(PWD):/workspace \
		-w /workspace \
		-e STRICT_MODE=$(STRICT_MODE) \
		$(IMAGE_NAME) $(PATTERN)

# Run a series of tests for different repo states
test-suite:
	@echo "\n🔬 Test 1: No Python files present"
	rm -f test_*.py *.py
	./entrypoint.sh $(PATTERN)

	@echo "\n🔬 Test 2: Python files present, but no test files"
	echo "print('Hello, world')" > app.py
	./entrypoint.sh $(PATTERN)
	rm -f app.py

	@echo "\n🔬 Test 3: Python files and matching test files present"
	echo "print('Hello, world')" > app.py
	echo "def test_sample(): pass" > test_utils.py
	./entrypoint.sh $(PATTERN)
	rm -f app.py test_utils.py

	@echo "\n🔬 Test 4: STRICT_MODE enabled with no test files (expected failure)"
	echo "print('just a script')" > lonely.py
	-STRICT_MODE=true ./entrypoint.sh $(PATTERN) || echo "⚠️ Expected failure occurred"
	rm -f lonely.py

	@echo "\n✅ Test suite complete!"
