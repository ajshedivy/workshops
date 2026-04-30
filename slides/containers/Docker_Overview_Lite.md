# Containers — 30,000ft view

In this section:

* Why containers exist (the problem they solve)

* The shipping-container analogy

* What containers actually do for you in practice

---

## Why the buzz around containers?

* The software industry has changed.

* Before:
  * monolithic applications
  * long development cycles
  * single environment
  * slowly scaling up

* Now:
  * decoupled services
  * fast, iterative improvements
  * multiple environments
  * quickly scaling out

---

## Deployment becomes very complex

* Many different stacks:
  * languages
  * frameworks
  * databases

* Many different targets:
  * individual development environments
  * pre-production, QA, staging…
  * production: on-prem, cloud, hybrid

---

class: pic

## The deployment problem

![problem](images/shipping-software-problem.png)

---

class: pic

## The matrix from hell

![matrix](images/shipping-matrix-from-hell.png)

---

class: pic

## The parallel with the shipping industry

![history](images/shipping-industry-problem.png)

---

class: pic

## Intermodal shipping containers

![shipping](images/shipping-industry-solution.png)

---

class: pic

## A shipping container system for applications

![shipapp](images/shipping-software-solution.png)

---

class: pic

## Eliminate the matrix from hell

![elimatrix](images/shipping-matrix-solved.png)

---

## Escape dependency hell

1. Write installation instructions into an `INSTALL.txt` file.

2. Use that file to write an `install.sh` script that works *for you*.

3. Turn it into a `Dockerfile`, test it on your machine.

4. If the Dockerfile builds on your machine, it builds *anywhere*.

5. Rejoice — no more "works on my machine."

---

## On-board developers in two commands

1. Write Dockerfiles for your application components.

2. Use pre-made images from the registry (PostgreSQL, Redis, …).

3. Describe your stack with a Compose file.

4. On-board somebody with two commands:

```bash
git clone …
podman compose up
```

Spin up dev / integration / QA environments in minutes.
