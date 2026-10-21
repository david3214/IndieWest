# IndieWest website

The IndieWest publisher site: a home page, a page per product, and each product's documentation. It's plain HTML and CSS with no JavaScript, hosted on GitHub Pages. The only build step renders product documentation from Markdown; it needs Node.js 18 or newer and nothing else.

Site address once published: <https://david3214.github.io/IndieWest/>

## Layout

```text
index.html                         Home page: introduction, Tools, Contact
tools/card-hand-toolkit/index.html Product page (hand-written)
tools/card-hand-toolkit/docs/      Documentation (GENERATED - don't edit)
assets/site.css                    All styles, shared by every page
assets/img/<product>/              Web-sized product images
assets/favicon.svg, favicon-32.png, apple-touch-icon.png
docs-src/<product>/                Verbatim copy of the product's Unity Documentation folder
scripts/docs.mjs                   Documentation import / build / check
scripts/docs.config.json           Which products have docs, and where they come from
scripts/docs-template.html         Page shell around each generated docs page
scripts/export-images.ps1          Makes web-sized JPEGs from marketing images
scripts/vendor/                    Build-time libraries, vendored: marked 15.0.12 (Markdown) and highlight.js 11.11.1 (C# highlighting)
.nojekyll                          Tells GitHub Pages to serve files as they are
```

All links are relative and name the file they point to (`index.html` included), so the site works at `username.github.io/`, at `username.github.io/IndieWest/`, and when opened straight from disk. Keep that convention when adding links: write `tools/<slug>/index.html`, not `tools/<slug>/`.

## Preview locally

Open `index.html` in a browser. Everything works from disk.

To preview exactly as GitHub Pages serves it, run this from the folder *above* the repository and open <http://localhost:8000/IndieWest/>:

```sh
python -m http.server 8000
```

## Publish on GitHub Pages

1. Commit the site and push `main` to `github.com/david3214/IndieWest`. The repository must be public (or on a plan that allows Pages for private repositories).
2. On GitHub, open the repository's **Settings → Pages**.
3. Under **Build and deployment**, set **Source** to **Deploy from a branch**.
4. Set **Branch** to `main` and the folder to `/ (root)`, then select **Save**.
5. Wait for the **pages build and deployment** run on the **Actions** tab to finish (a minute or two), then open <https://david3214.github.io/IndieWest/>.

Each later push to `main` republishes the site. Generated documentation is committed, so GitHub doesn't need to run any build.

## Update the documentation

The Markdown files in the Unity project are the source of truth. Never edit `docs-src/` or `tools/*/docs/` by hand.

1. Edit the docs in the Unity project (`Assets/CardHandToolkit/Documentation/`).
2. Import, build and check:

   ```sh
   node scripts/docs.mjs import card-hand-toolkit
   node scripts/docs.mjs build card-hand-toolkit
   node scripts/docs.mjs check card-hand-toolkit
   ```

   Leave out the product name to process every product. If the Unity project isn't at the path in `scripts/docs.config.json`, pass `--source "<path to the Documentation folder>"` to `import`.
3. Review the diff (`docs-src/` shows exactly what changed in the Markdown), then commit.

What each step does:

- **import** copies every file except Unity `.meta` files into `docs-src/<product>/`, unchanged, and writes `IMPORT.json` with the source path, import time and a SHA-256 for each file. It lists what was added, changed or removed.
- **build** renders `docs-src/<product>/` into the product's `docs/` folder:
  - Each top-level Markdown file becomes a page: `QuickStart.md` becomes `quickstart.html` (lowercase), and `README.md` becomes the docs home page. Markdown in subfolders, such as `Images/README.md`, is treated as a maintainer note and isn't published.
  - Links between Markdown files, such as `API.md#zones--play`, become links between pages. So do links to this site's own published address (`siteUrl` in `scripts/docs.config.json`), such as `https://david3214.github.io/IndieWest/tools/card-hand-toolkit/docs/api.html#concepts`, which the docs use so they also work inside Unity. These are made relative and checked like any other internal link. Other external links are left alone.
  - Headings get the same IDs GitHub gives them, so existing anchors keep working. Raw HTML anchors such as `<a id="quick-start-art">` are kept.
  - Code blocks keep their exact text. Blocks marked ` ```csharp ` get syntax highlighting at build time (no JavaScript on the page); unmarked blocks stay plain. To highlight another language, vendor its highlight.js grammar and register it at the top of `scripts/docs.mjs`.
  - Images, including raw `<img>` tags, load lazily and get a height so the page doesn't jump while they load. Wide code and tables scroll inside their own box.
  - The version shown on every page comes from the first version heading in `CHANGELOG.md` (for example `## 1.0.0`). Headings such as `## Unreleased` are skipped.
  - The build refuses to run if any check below fails, and only ever deletes files it generated itself.
- **check** confirms that every internal link, anchor and image resolves, that every code block matches the Markdown, and that the generated files are up to date. It also warns if the Unity docs have changed since the last import.

Page titles and the order of the docs navigation are set in `scripts/docs.config.json`. A new Markdown file that isn't listed there is still built, and appears at the end of the navigation under its first heading.

## Add a product or a game

- **Product page:** copy `tools/card-hand-toolkit/` to `tools/<new-slug>/` (games go under `games/<slug>/`) and edit its `index.html`. Pages two folders deep reach shared files with `../../`.
- **Home page:** copy the `<article class="product-card">` block inside the Tools section of `index.html`. For the first game, uncomment the Games section and add a **Games** link to the header on every page (including `scripts/docs-template.html`).
- **Images:** export web-sized copies of finished marketing images:

  ```powershell
  powershell -ExecutionPolicy Bypass -File scripts/export-images.ps1 -OutDir assets/img/<slug> "<path>\Image.png"
  ```

  This writes `<name>-1600.jpg` and `<name>-800.jpg`. Use real captures only.
- **Documentation:** add an entry to `products` in `scripts/docs.config.json` (slug, name, source folder, snapshot folder, output folder, product page and page titles), then run `import` and `build`.

## Editing checklist

Before or at launch:

- [ ] **Asset Store URL.** Add the "View on the Asset Store" button: search for `ASSET_STORE_URL` in `index.html` and `tools/card-hand-toolkit/index.html`, and replace each comment with the link.
- [ ] **Release status.** Both pages say "Available now". Publish the site when the Asset Store listing goes live.
- [ ] **Discord invite.** <https://discord.gg/rC7wVukEpu> is used for contact and support (taken from the Quick Start). Make sure the invite never expires.
- [ ] **Support email (optional).** There's no email on the site. To add one, put a `mailto:` button in the Contact section of `index.html`.
- [ ] **Custom domain (optional).** The canonical and social-preview URLs use `https://david3214.github.io/IndieWest/`. If the address changes, search for `david3214.github.io` and update them, including `siteUrl` in `scripts/docs.config.json` and the links in the Unity docs.

Already set:

- **Tutorial video:** <https://youtu.be/L_v_jIwN_XA>, the same link as the Setup Wizard and Quick Start. It appears on the product page.
- **Documentation version:** read from `CHANGELOG.md` on each build (currently 1.0.0).

## Third-party code

Both libraries are used only by the build script, and no page loads them. Both are unmodified.

- `scripts/vendor/marked.esm.js`: [marked](https://github.com/markedjs/marked) 15.0.12 (SHA-256 `29e25cdf1a06075c90e9885af06ddd23fb22a5424ed23a61dda986c73a8af641`). MIT license, in `scripts/vendor/marked.LICENSE.md`.
- `scripts/vendor/highlight/`: [highlight.js](https://highlightjs.org/) 11.11.1, `core.min.js` (SHA-256 `bfcca5550cb9d62482162e1d1fb90c822d2d35036b556544817441b795b7103c`) and `csharp.min.js` (SHA-256 `4a4af1a69c7d9122679f82f7f6fc6f4d0ab494f8dedc2874f8820d3bb0a23285`). BSD-3-Clause license, in `scripts/vendor/highlight/LICENSE`.
