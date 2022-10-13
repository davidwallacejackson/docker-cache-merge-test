# Docker cache "merge" test

Just run `./test.sh`. On the first run, the prune will fail (because the builder isn't running yet), and on subsequent runs the create will fail (because the builder already exists), but it's safe to ignore these errors.

The test builds three trivial dockerfiles, two times each. Each dockerfile performs some version of:

- `COPY` a file to the target filesystem
- `RUN sleep 1`

After the first build, it changes the permissions of the `COPY`d file and reruns, to simulate permissions getting corrupted on other operating systems.

The first Dockerfile, which performs a single-stage build, loses its cache when permissions change as expected, and reruns the `sleep 1`.

The second, which performs a single-stage build but uses a `RUN chmod` after the `COPY` to normalize permissions on the file, does not detect that the resulting filesystem after `RUN` is equivalent in both iterations, so it does re-run the `sleep 1` (this surprised me! I kind of thought Docker would figure it out)

The third, which performs the `COPY` and the `RUN chmod` in a temp stage and then copies the result of _that_ to the final stage where the sleep is performed, successfully sidesteps the problem. That is, the cache for the temp stage is invalidated (no big deal, since it takes next to no time), but Docker then detects that the two different inputs to the temp stage have produced equivalent filesystems, and it considers the `RUN sleep 1` a valid cache in build 2 (because it already ran against an equivalent filesystem).
