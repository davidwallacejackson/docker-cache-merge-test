docker buildx create --name cache-test
docker buildx use cache-test
docker buildx prune -af

BUILDKIT_PROGRESS=plain

echo "Hello!" >> ./test-file

echo "Testing single-stage:"
echo "Building with test-file set to g=rw"
chmod g=rw ./test-file

docker buildx build .

# this will count as a change and re-run the sleep
echo "Building with test-file set to g=r"
chmod g=r ./test-file

docker buildx build .


echo "Testing single-stage with normalized permissions:"
echo "Building with test-file set to g=rw"
docker buildx prune -af
chmod g=rw ./test-file

docker buildx build . -f=Dockerfile.single-with-normalize

echo "Building with test-file set to g=r"
chmod g=r ./test-file

# this will also count as a change and re-run the sleep
docker buildx build . -f=Dockerfile.single-with-normalize


echo "Testing multi-stage:"
echo "Building with test-file set to g=rw"
docker buildx prune -af
chmod g=rw ./test-file

docker buildx build . -f=Dockerfile.multistage

echo "Building with test-file set to g=r"
chmod g=r ./test-file

# this will count as a change to the temp stage, but the
# resulting filesystem after that is the same, and the sleep will not re-run
docker buildx build . -f=Dockerfile.multistage

