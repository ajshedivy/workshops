
class: title

# Understanding container images

![image](images/title-understanding-docker-images.png)

---

## Objectives

In this section we'll explain:

* What an image is.

* What a layer is.

* The difference between an image and a container.

* How to pull images and use tags.

---

## What is an image?

* An image = files + metadata.

* The files form the root filesystem of the container.

* The metadata tells the engine things like:
  * the command to run when the container starts
  * environment variables
  * exposed ports

* Images are made of *layers*, conceptually stacked on top of each other.

* Each layer can add, change, or remove files.

* Layers are *shared* between images to save disk, network, and memory.

---

class: pic

## The read-write layer

![layers](images/container-layers.jpg)

---

## Image vs container

* An **image** is a read-only filesystem.

* A **container** is an encapsulated set of processes running in a
  read-write copy of that filesystem.

* `podman run` (or `docker run`) starts a container from an image.

* Many containers can run from the same image — they share the read-only layers.

---

class: pic

## Multiple containers sharing the same image

![layers](images/sharing-layers.jpg)

---

## Mental model

* Images are like **classes**.

* Layers are like **inheritance**.

* Containers are like **instances**.

If you've used object-oriented languages, that analogy holds up well.

---

## So how do I make an image?

* Almost always: write a `Dockerfile` and run `podman build` (or `docker build`).

* Less common: run a container, change it, and `podman commit` to a new image.

* `Dockerfile` is the *preferred* method — repeatable, version-controlled, reviewable.

We'll write one in the next section.

---

## Where do images live?

* On your machine, after a `pull` or `build`.

* On a **registry** — a service that hosts images.

  * Docker Hub (`docker.io`) — the default public registry.
  * Quay (`quay.io`) — Red Hat / IBM-hosted, popular with Podman.
  * Your own private registry (`registry.example.com:5000/…`).

* Image names include the registry, namespace, name, and a tag:

  ```
  quay.io/podman/hello:latest
  ```

---

## Pulling an image

```bash
$ podman pull debian:bookworm
```

* The engine downloads each layer from the registry.

* `:bookworm` is the **tag** — which Debian we want.

* If you omit the tag, the engine assumes `:latest`.

---

## When to (not) use tags

**Don't** specify a tag:

* When testing or prototyping.
* When you want the most recent version.

**Do** specify a tag:

* When putting something into a script.
* When going to production.
* To make sure the same version runs everywhere.
* To make builds reproducible later.

Same idea as pinning versions in `pip install`, `npm install`, `go.mod`, etc.

---

## Section recap

You can now:

* Explain what an image is and how layers work.

* Tell an image apart from a container.

* Pull an image from a registry and pick a tag.

Next: writing a `Dockerfile` to build your own.
