# mdroste.github.io

This repository contains the source for mdroste.github.io / mdroste.com. 

It is a modified version of the [Al-Folio](https://github.com/alshedivat/al-folio) 0.7.0 theme for Jekyll.

## Preview on your Mac

In Terminal, run:

```bash
cd /Users/mike/Documents/GitHub/mdroste.github.io
./bin/preview
```

Open <http://localhost:4000>. Leave Terminal running while editing. Jekyll
rebuilds the site when you save a source file, and LiveReload refreshes the
browser. Stop the server with **Control-C**. Run the same command to restart it.
If port 4000 is busy, use `./bin/preview --port 4001` and open
<http://localhost:4001> instead.

The server listens only on this Mac. Saving files, running this preview, and
making local Git commits do not publish anything. The existing GitHub Actions
workflow deploys on pushes to `main` or `master`; `bin/deploy` is also a publishing
script. Use `bin/preview` for local work.

## Where to edit

| What you want to change | Source |
| --- | --- |
| Home page / biography | `_pages/about.md` |
| Research | `_pages/research.md` |
| Teaching and course pages | `_pages/teaching.md`, `_pages/ec2450a.md`, `_pages/ec1011b.md` |
| CV PDF | `files/cv.pdf` |
| Photos | `assets/img/` |
| Colors, fonts, spacing | `_sass/` and `assets/css/main.scss` |
| Page structure, navigation, footer | `_layouts/` and `_includes/` |
| Site-wide settings | `_config.yml` |

Edit the source files above, not `_site/`: Jekyll regenerates `_site/` on each
build. Keep the YAML settings between `---` markers at the top of Markdown files.
After changing either configuration file, stop and restart the preview server.

Some existing links are hard-coded to `https://www.mdroste.com/...` and will
open the public site even while previewing. To inspect a local PDF or course page,
use its local URL (for example, <http://localhost:4000/files/cv.pdf> or
<http://localhost:4000/ec2450a/>). Local edits to PDFs won't appear at public URLs.

## Local dependencies and preview settings

This Mac has a separate Ruby 3.3.11 runtime in `vendor/ruby/`, sourced from
[jdx/ruby's macOS build](https://github.com/jdx/ruby/releases/tag/3.3.11-1).
The download was checked against the release's SHA-256 digest. Jekyll 4.4.1 and
the Gemfile's dependencies are installed in `vendor/bundle/`. `bin/preview`
selects this Ruby automatically; macOS's system Ruby and shell settings are
unchanged. These installed files are ignored by Git and aren't part of a fresh
clone. The local `Gemfile.lock` records the installed gem versions and is also
ignored under this repository's existing policy.

If you change the Gemfile, install dependencies again from the project directory:

```bash
PATH="$PWD/vendor/ruby/bin:$PATH" bundle install
```

`bin/preview` layers `_config.local.yml` over the normal configuration. Locally,
analytics and external blog-feed fetching are disabled, original images are used
instead of generated WebP variants, and the inherited Twitter and Mermaid demo
posts are omitted. This preview therefore needs neither ImageMagick nor the
Mermaid CLI. Production settings and all source posts remain intact. Browser
assets such as fonts and CDN stylesheets may still require an internet connection.
The old theme also produces Sass deprecation warnings; these do not prevent the
preview from building and can be addressed when modernizing its styles.

See [Jekyll's local development documentation](https://jekyllrb.com/docs/)
for more about `serve` and LiveReload.
