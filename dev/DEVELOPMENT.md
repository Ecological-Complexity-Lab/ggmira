# Developing ggmira

The bundled MiRA in `inst/MiRA` is a copy, made from a MiRA checkout next
to this one (`../MiRA`, on its `main` branch, after the MiRA change is
merged):

```bash
cd ~/GitHub/ecomplab/MiRA
npm run sync:ggmira   # then commit inst/MiRA here
```

To try MiRA changes before syncing, point a plot to the checkout:

```r
devtools::load_all("~/GitHub/ecomplab/ggmira")
p <- mira(net, bipartite = TRUE) + mira_node(size = 8)
print(p, mira_path = "~/GitHub/ecomplab/MiRA-dev")
```

The documentation site (reference pages and articles) is built with
pkgdown into `docs/`, which is not committed:

```r
pkgdown::build_site(examples = FALSE) # examples shown as code, not run
```

The logo (`man/figures/logo.png`) is rendered from `pkgdown/logo/logo.html`
(see the comment there).

## Screenshots

`dev/screenshots.R` retakes the screenshots of Getting started and of the
help pages with the current MiRA (`Rscript dev/screenshots.R`, from this
folder; names as arguments for only some). Retake them after a MiRA change
that shows in them. The RStudio screenshot on the home page
(`man/figures/README-rstudio.png`) is taken by hand: the code is in the
README's Usage; capture only the RStudio window (Cmd+Shift+4, Space,
Option-click) and keep it about 2560 pixels wide.

## Checks

```r
devtools::test()
devtools::check(document = FALSE, args = c("--no-tests", "--no-manual"))
```

The check's only expected NOTE lists files in this folder that are not part
of the package (a tester's scripts and data). Never commit those.

Design notes, decisions and the roadmap live in the
[MiRA repository](https://github.com/Ecological-Complexity-Lab/MiRA)
(`development` branch, `dev/ggmira/`). Please report MiRA issues at
<https://github.com/Ecological-Complexity-Lab/MiRA/issues>.
