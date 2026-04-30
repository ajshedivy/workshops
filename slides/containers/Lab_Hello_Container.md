# Lab: build and run your first container

End-to-end: write a Dockerfile, build it, run it, hit it with curl.

You can recreate this entirely on your own machine after the talk.

---

## What we'll build

A tiny Python + Flask web app that responds with *"Hello from a container"*.

Three files in one directory:

```
hello/
├── app.py
├── requirements.txt
└── Dockerfile
```

No prior Python knowledge required — the code is six lines.

---

## `app.py`

```python
from flask import Flask

app = Flask(__name__)

@app.get("/")
def hello():
    return "Hello from a container!\n"

app.run(host="0.0.0.0", port=8080)
```

---

## `requirements.txt`

```
flask==3.0.3
```

---

## `Dockerfile`

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 8080
CMD ["python", "app.py"]
```

---

## Build the image

```bash
podman build -t hello-container .
```

* `-t hello-container` tags the image with a friendly name.
* The trailing `.` is the *build context* — the directory we send to the build.

You'll see Podman execute each `Dockerfile` instruction as a layer.

---

## Run the container

```bash
podman run --rm -p 8080:8080 hello-container
```

* `--rm` — remove the container when it exits.
* `-p 8080:8080` — publish container port 8080 to host port 8080.

In another terminal:

```bash
curl http://localhost:8080
# Hello from a container!
```

`Ctrl-C` in the first terminal stops it.

---

## Recap

* You wrote a `Dockerfile` — a recipe for an image.
* `podman build` produced an **image**.
* `podman run` started a **container** from that image.
* The container is just a process; stop it like any other.

### Where to go next

* `podman volume` — persistent data outside the container.
* Multi-stage builds — smaller production images.
* `compose.yaml` — multi-service apps in one file.
* OpenShift / Kubernetes — running this on a cluster.
