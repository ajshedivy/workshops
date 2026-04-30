# Podman and Docker

Two tools, one ecosystem.

---

## The short version

* **Docker** defined the modern container ecosystem.
  * `Dockerfile`, `docker build`, `docker run`, Docker Hub.
  * The OCI image format started here.

* **Podman** runs the same OCI containers, but:
  * No daemon — each `podman` command is just a process.
  * Rootless by default — no privileged socket required.
  * `systemd`-friendly — generate unit files with `podman generate systemd`.

* Default container engine on **RHEL 8+ / Linux on Power**.

---

## The CLI is a drop-in

For everything in this talk, `docker` and `podman` are interchangeable:

```bash
podman pull alpine
podman run --rm -it alpine
podman build -t myapp .
```

You can even run:

```bash
alias docker=podman
```

---

## A note on the slides ahead

* The slides ahead show `docker` commands.

* That's how the world writes them in docs and Stack Overflow.

* Mentally substitute `podman` — it works the same.
