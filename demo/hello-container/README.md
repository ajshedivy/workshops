# Lab: Hello from a container

A minimal end-to-end example: write a `Dockerfile`, build an image, run it as a
container, and hit it with `curl`. This is the lab walked through in the
**"Using Podman/Docker containers"** deck (`slides/intro-ibmi.yml`).

The instructions use `podman` everywhere; if you have `docker` instead, the
commands are identical — just substitute `docker` for `podman`.

## What you'll end up with

```
hello-container/
├── app.py             # 8-line Flask web app
├── requirements.txt   # one line: flask==3.0.3
├── Dockerfile         # build recipe for the image
└── README.md          # this file
```

When it's running, `curl http://localhost:8080` returns:

```
Hello from a container!
```

---

## Prerequisites

- Podman (or Docker) installed and working.
  - macOS: `brew install podman && podman machine init && podman machine start`
  - Linux (RHEL/Fedora): `sudo dnf install podman`
  - Linux (Debian/Ubuntu): `sudo apt install podman`

Verify:

```sh
podman --version
podman info | head -5
```

---

## Step 1 — Look at the files

The three files needed to build the image are already in this directory.

### `app.py`

```python
from flask import Flask

app = Flask(__name__)


@app.get("/")
def hello():
    return "Hello from a container!\n"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
```

A trivial Flask app that returns one line of text on `GET /`. `host="0.0.0.0"`
is important — binding to `127.0.0.1` would only accept connections from
*inside* the container.

### `requirements.txt`

```
flask==3.0.3
```

Pinning the version makes the build reproducible.

### `Dockerfile`

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 8080
CMD ["python", "app.py"]
```

Each instruction is one layer in the resulting image:

| Instruction | What it does |
|---|---|
| `FROM python:3.12-slim` | Start from the official slim Python 3.12 image. |
| `WORKDIR /app` | All following instructions run in `/app` inside the image. |
| `COPY requirements.txt .` | Copy just the deps file first, so the next layer is cacheable. |
| `RUN pip install …` | Install Flask. Cached unless `requirements.txt` changes. |
| `COPY app.py .` | Copy the application code. Changes here don't bust the pip-install cache. |
| `EXPOSE 8080` | Document the port the app listens on (informational). |
| `CMD ["python", "app.py"]` | Default command when the container starts. |

---

## Step 2 — Build the image

From this directory:

```sh
podman build -t hello-container .
```

- `-t hello-container` — tag the image with a friendly name.
- The trailing `.` is the *build context* — the directory sent to the builder.
  Anything `COPY` or `ADD` references must live inside it.

You should see each instruction execute as a separate layer, ending with
something like:

```
Successfully tagged localhost/hello-container:latest
```

Verify the image exists:

```sh
podman images
```

Expected output (image IDs and dates will differ):

```
REPOSITORY                  TAG         IMAGE ID      CREATED         SIZE
localhost/hello-container   latest      abc123def456  2 minutes ago   140 MB
```

---

## Step 3 — Run the container

```sh
podman run --rm -p 8080:8080 hello-container
```

Flag breakdown:

| Flag | What it does |
|---|---|
| `--rm` | Remove the container automatically when it exits (keeps things tidy). |
| `-p 8080:8080` | Publish container port 8080 to host port 8080 (`hostPort:containerPort`). |
| `hello-container` | The image to run. |

You should see Flask start up:

```
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:8080
 * Running on http://10.0.2.100:8080
```

The container is now serving on the host's port 8080.

---

## Step 4 — Hit the endpoint

In a **second terminal** (the first one is busy running the container):

```sh
curl http://localhost:8080
```

Expected output:

```
Hello from a container!
```

Or open `http://localhost:8080` in a browser — same result.

Back in the first terminal, you'll see Flask logging the request:

```
127.0.0.1 - - [30/Apr/2026 11:50:00] "GET / HTTP/1.1" 200 -
```

---

## Step 5 — Stop the container

In the first terminal, press `Ctrl-C`. Because we passed `--rm`, the container
is removed immediately.

Confirm:

```sh
podman ps -a
```

Should show no containers (or no `hello-container` ones).

---

## Going further

A few low-effort tweaks once you've got this working:

- **Change the message** in `app.py`, rebuild, and rerun. Notice that the
  `RUN pip install` layer is cached — only the last `COPY` and the image export
  re-execute. That's the layer-caching system at work.

- **Detached mode**: `podman run -d --name hello -p 8080:8080 hello-container`
  runs the container in the background. Use `podman logs hello` to view output
  and `podman stop hello && podman rm hello` to clean up.

- **Inspect the image**: `podman image inspect hello-container` shows the
  metadata baked into the image (env, command, exposed ports, layer history).

- **Push to a registry**: tag with the registry name (`podman tag
  hello-container quay.io/USER/hello-container`) and `podman push` it. Now
  others can `podman pull` and run it.

- **Add a `.dockerignore`**: keeps junk out of the build context. Handy as the
  project grows.

- **Multi-stage builds**: smaller images by separating "builder" and "runtime"
  stages — covered in the *Building images with a Dockerfile* section of the
  deck.

---

## Troubleshooting

**`Error: short-name "python:3.12-slim" did not resolve to an alias`**
On RHEL/Fedora Podman, the short-name policy may require fully-qualified names.
Edit the Dockerfile's `FROM` line to `docker.io/library/python:3.12-slim`, or
configure `~/.config/containers/registries.conf`.

**`bind: address already in use`**
Something else is listening on host port 8080. Pick a different host port:
`podman run --rm -p 9090:8080 hello-container`, then curl
`http://localhost:9090`.

**`curl: (52) Empty reply from server` immediately after `podman run`**
Flask hasn't finished starting yet — wait a couple of seconds and retry.

**Port mapping not working on macOS**
Make sure `podman machine` is running: `podman machine list`. If `Currently
running` is `false`, `podman machine start`.
