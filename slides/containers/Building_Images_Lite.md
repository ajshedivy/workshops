
class: title

# Building images with a Dockerfile

![Construction site with containers](images/title-building-docker-images-with-a-dockerfile.jpg)

---

## Objectives

By the end of this section you'll be able to:

* Write a `Dockerfile`.

* Build an image from a `Dockerfile`.

* Read a build's output and understand what happened.

---

## `Dockerfile` overview

* A `Dockerfile` is a **build recipe** for a container image.

* It contains a series of instructions telling the engine how the image is constructed.

* `podman build` (or `docker build`) reads a `Dockerfile` and produces an image.

---

## `Dockerfile` example

```dockerfile
FROM python:alpine
WORKDIR /app
RUN pip install Flask
COPY rng.py .
ENV FLASK_APP=rng FLASK_RUN_HOST=:: FLASK_RUN_PORT=80
CMD ["flask", "run"]
EXPOSE 80
```

Each line is one instruction → one **layer** in the resulting image.

---

## Writing your first `Dockerfile`

The `Dockerfile` lives in a **new, empty directory**.

```bash
$ mkdir myimage
$ cd myimage
$ vim Dockerfile        # or any editor
```

---

## A minimal `Dockerfile`

```dockerfile
FROM ubuntu
RUN apt-get update
RUN apt-get install -y figlet
```

* `FROM` — the base image to start from.

* `RUN` — execute a command during the build (must be non-interactive).

* Each `RUN` produces a new layer.

---

## Build it

```bash
$ podman build -t figlet .
```

* `-t figlet` — tag the image with a name.

* `.` — the *build context*, the directory sent to the builder.

The context is also where `COPY` and `ADD` look for files.

---

## What happens during a build?

* The builder reads the `Dockerfile` line by line.

* For each instruction it:
  1. Creates a temporary container from the previous layer.
  2. Runs the instruction in that container.
  3. Commits the result as a new layer.

* The final layer + metadata = your new image.

You'll see lines like `[1/3]`, `[2/3]`, `[3/3]` from BuildKit, or
`Step 1/3` from the older builder — same idea.

---

## The caching system

Run the same build twice — the second one is instantaneous. Why?

* The builder snapshots after each step.

* Before running a step, it checks if it has already built **the same instruction
  on the same input**.

* If yes, reuse the cached layer.

* If no (or anything earlier changed), rebuild from there onwards.

You can force a clean rebuild with `--no-cache`.

---

## Running the image

```bash
$ podman run -ti figlet
root@91f3c974c9a1:/# figlet hello
 _          _ _       
| |__   ___| | | ___  
| '_ \ / _ \ | |/ _ \ 
| | | |  __/ | | (_) |
|_| |_|\___|_|_|\___/ 
```

The image you just built behaves like any other — `pull`-ed, `run`, `tag`, `push`.

---

## Shell syntax vs exec syntax

`RUN`, `CMD`, and `ENTRYPOINT` accept two forms:

* **Shell syntax** — plain string:
  ```dockerfile
  RUN apt-get install -y figlet
  ```
  Runs through `/bin/sh -c "…"`. Easy to write; expands `$VARS`.

* **Exec syntax** — JSON list:
  ```dockerfile
  RUN ["apt-get", "install", "-y", "figlet"]
  ```
  No shell involved. No variable expansion, no `&&` chaining,
  but no extra `sh` process either.

For `CMD` / `ENTRYPOINT`, **prefer exec syntax** — it makes signal
handling work correctly in the running container.

---

## Section recap

You can now:

* Write a `Dockerfile` with `FROM`, `RUN`, `COPY`, `CMD`.

* Build it with `podman build -t name .`.

* Read the build output and understand the layer + cache model.

* Pick between shell and exec syntax.

Next: we'll do all of this end-to-end in the lab.
