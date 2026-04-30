# Adam's Workshops

Personal workshop and presentation materials

Each workshop is a slide deck assembled from modular Markdown chapters via a
YAML manifest.

## Quick start

```sh
cd slides

# 1. One-time setup (uses uv to manage Python deps)
uv venv
VIRTUAL_ENV="$PWD/.venv" uv pip install -r requirements.txt

# 2. Build all decks (manifest *.yml -> *.yml.html)
./build.sh once

# 3. Serve locally and preview in a browser
./build.sh serve
# then open http://127.0.0.1:8000/<deck>.yml.html
```

For watch mode (auto-rebuild on file change), `./build.sh forever` — requires
`entr` (`brew install entr`).

Full build instructions, troubleshooting, and editing workflow live in
[`slides/BUILDING.md`](slides/BUILDING.md).

## Repository layout

```
slides/
├── *.yml                  # Manifests — one per deck
├── containers/            # Container & Docker chapters (Markdown)
├── k8s/                   # Kubernetes chapters
├── shared/                # Reusable chapters (title, TOC, thank-you, …)
├── images/                # Image assets
├── workshop.css           # Slide theme
├── workshop.html          # Remark template
├── markmaker.py           # Compiler: YAML manifest → HTML
└── build.sh               # `once` | `forever` | `serve`

dockercoins/, k8s/, stacks/, prepare-labs/, …
                           # Sample apps, Compose files, lab-environment
                           # provisioning scripts inherited from upstream
```

## My decks

| Deck | Manifest | Audience |
|---|---|---|
| Using Podman/Docker containers | `slides/intro-ibmi.yml` | IBM i developers — 50-min intro |
| *(more to come)* | | |

To author a new deck:

1. Copy an existing manifest, e.g. `cp slides/intro-ibmi.yml slides/mytalk.yml`.
2. Edit the chapter list (`content:`) in the new manifest.
3. Add or override chapters in `slides/containers/` or `slides/shared/`.
4. Run `./build.sh once` (or `./build.sh forever` for live reload).

## Attribution

The Markdown→HTML build pipeline, the `slides/` directory layout, and the
container / Kubernetes chapter library all originate from
[jpetazzo/container.training](https://github.com/jpetazzo/container.training)
by [Jérôme Petazzoni](https://hachyderm.io/@jpetazzo) and contributors —
licensed under the terms in [`LICENSE`](LICENSE).

The original chapters (`slides/containers/*.md`, `slides/k8s/*.md`,
`slides/shared/*.md`, etc.) and the build tooling (`slides/markmaker.py`,
`slides/build.sh`, `slides/workshop.html`, `slides/workshop.css`) are
upstream's work. Custom chapters and manifests authored for personal
workshops are mixed in alongside them.

When publishing or presenting derived materials, please retain attribution
to the upstream project per the license.
