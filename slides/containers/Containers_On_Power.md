# Containers and IBM Power

What runs where, and why an IBM i developer should care.

---

## Where do containers actually run?

* **IBM i**: does *not* run containers natively.
  * No container engine; it's not the OS runtime model.

* **AIX**: also not a container runtime.

* **Linux on Power** (RHEL, SLES, Ubuntu on `ppc64le`):
  * Runs Podman, Docker, and OpenShift natively.
  * Same OCI images as x86 (when built multi-arch).

* So on the Power box that hosts your IBM i workload, you can stand up a Linux LPAR alongside it and run containers there.

---

## Why should an IBM i developer care?

* **Modernization sidecars** — REST / GraphQL fronts, Node / Python / Java services that talk to Db2 for i.

* **Linux-side dev tooling** — build pipelines, observability, API gateways.

* **Same Power hardware, same data center** — no need to leave the platform.

* **Skills transfer 1:1** to OpenShift on Power, and to any x86 cloud.

* Today we'll learn the fundamentals on your laptop. Everything you see runs identically on a Linux LPAR.
