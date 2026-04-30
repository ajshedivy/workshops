# Building and Running the Slides Locally

A practical guide for building the slide decks in this directory and previewing them in a browser.

If you only want to know *how the system works* (YAML manifests, Markdown chapters, Remark conventions), read [`README.md`](README.md) first.

---

## Prerequisites

| Tool | Required? | Purpose |
|---|---|---|
| Python 3.11+ | yes | Runs `index.py`, `markmaker.py`, `appendcheck.py` |
| [`uv`](https://github.com/astral-sh/uv) | recommended | Manages the Python venv and deps |
| `entr` | optional | Auto-rebuild on file change (`./build.sh forever`) |
| Docker / Podman | optional | Alternative — runs the builder + an nginx server in containers |

Install `uv` (if needed) and `entr` (if you want watch mode):

```sh
# macOS
brew install uv entr
```

---

## One-time setup

From the repo root:

```sh
cd slides
uv venv                                          # creates .venv/
VIRTUAL_ENV="$PWD/.venv" uv pip install -r requirements.txt
```

The `VIRTUAL_ENV=...` prefix is only needed if you have another Python env active in your shell (e.g. conda/miniforge); it tells `uv` to install into the project venv instead of the active one.

Verify:

```sh
.venv/bin/python -c "import yaml, jinja2; print('ok')"
```

---

## Build the slides

One-shot build of every `*.yml` manifest into `*.yml.html`:

```sh
cd slides
./build.sh once
```

`build.sh` auto-activates `slides/.venv` if it exists, so no `PATH` or `VIRTUAL_ENV` prefixes are needed.

What this does:

1. Runs `index.py` to regenerate `index.html` (the deck index page).
2. Runs `markmaker.py` once per `*.yml` manifest, producing `<manifest>.yml.html`.
3. Zips the whole `slides/` directory into `slides.zip`.

After a successful build you should see, among others:

- `intro-fullday.yml.html` — Introduction to Docker and Containers (full day)
- `intro-twodays.yml.html` — same content, two-day pace
- `intro-selfpaced.yml.html` — every chapter, for self-study
- `kube-*.yml.html`, `kadm-*.yml.html`, `swarm.yml.html`, `mlops.yml.html` — orchestration decks

---

## Preview in a browser

The compiled HTML files use ES modules, so loading them via `file://` may fail in some browsers. Serve them over HTTP instead:

```sh
cd slides
./build.sh serve            # defaults to port 8000
./build.sh serve 9000       # or pick a port
```

Under the hood this runs `uv run python -m http.server` from `slides/`, so it picks up `.venv` automatically and doesn't need a separate activation step.

Then open:

- http://127.0.0.1:8000/ — directory index
- http://127.0.0.1:8000/intro-fullday.yml.html — full-day Docker intro
- http://127.0.0.1:8000/index.html — the published landing page

### Remark keyboard shortcuts

| Key | Action |
|---|---|
| `→` / `Space` | Next slide |
| `←` | Previous slide |
| `p` | Toggle presenter notes |
| `c` | Clone deck into a second window (dual-screen presenting) |
| `f` | Fullscreen |
| `?` | Show full shortcut list |

Slide separators in the source: `---` between slides, `???` to start presenter notes for the previous slide.

---

## Watch mode (auto-rebuild)

If `entr` is installed:

```sh
cd slides
./build.sh forever
```

This rebuilds every time a file in `slides/` changes. Run `./build.sh serve` in another terminal and just refresh the browser to see changes.

---

## Alternative: Docker / Podman

If you'd rather not manage a Python env, run everything in containers:

```sh
cd slides
docker compose up
```

This starts two services from `compose.yaml`:

- `builder` — Alpine container with `entr` and the Python deps; runs `./build.sh forever`.
- `www` — nginx serving the `slides/` directory.

Find the published port with `docker compose ps`, then open `http://localhost:<port>/intro-fullday.yml.html`.

Podman works too: `podman compose up` (or `podman-compose up`).

---

## Editing workflow

A typical loop while customizing a deck:

1. Pick or copy a manifest, e.g. `cp intro-fullday.yml mytalk.yml`.
2. Edit `mytalk.yml` to comment/uncomment the chapters you want from `containers/` and `shared/`.
3. Tweak Markdown in those chapters, or add a new one (`containers/My_Topic.md`) and reference it from the manifest.
4. Run `./build.sh once` (or have `forever` running).
5. Reload `http://127.0.0.1:8000/mytalk.yml.html` in the browser.

Useful files to know about:

| Path | What it controls |
|---|---|
| `*.yml` | Deck composition (which chapters, in what order) |
| `containers/*.md` | Per-topic chapter Markdown |
| `shared/*.md` | Reusable bits (`title.md`, `toc.md`, `thankyou.md`, …) |
| `workshop.css` | Slide theme (colors, fonts, layout) |
| `workshop.html` | The Remark template that wraps the compiled Markdown |
| `images/` | Image assets referenced from chapters |

To hide a slide without deleting it, change the preceding `---` separator to `???` — Remark will treat the rest as presenter notes.

---

## Troubleshooting

**`build.sh` exits with `ModuleNotFoundError: yaml` or `jinja2`**
`slides/.venv` is missing or incomplete. Re-run the one-time setup: `uv venv && VIRTUAL_ENV="$PWD/.venv" uv pip install -r requirements.txt`.

**`entr` not found**
Install it (`brew install entr`) or just use `./build.sh once` and rebuild manually.

**Slides load but show only "⏳️ Loading…"**
You're probably opening the file via `file://`. Use `./build.sh serve` instead.

**Images missing or broken**
Check that the path in the Markdown matches a file under `slides/images/`. The `slidechecker.js` script (requires PhantomJS) can scan a built deck for missing images:

```sh
./slidechecker foo.yml.html
```



## Publishing pipeline

Each time we push to `master`, a webhook pings
[Netlify](https://www.netlify.com/), which will pull
the repo, build the slides (by running `build.sh once`),
and publish them to http://container.training/.

Pull requests are automatically deployed to testing
subdomains. I had no idea that I would ever say this
about a static page hosting service, but it is seriously awesome. ⚡️💥


## Extra bells and whistles

You can run `./slidechecker foo.yml.html` to check for
missing images and show the number of slides in that deck.
It requires `phantomjs` to be installed. It takes some
time to run so it is not yet integrated with the publishing
pipeline.
