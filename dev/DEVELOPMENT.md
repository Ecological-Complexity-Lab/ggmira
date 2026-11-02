# Developing ggmira

The bundled MiRA in `inst/MiRA` is a copy, made from a MiRA checkout next
to this one (branch `feat/ggmira`):

```bash
cd ~/GitHub/ecomplab/MiRA-dev
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

Design notes, decisions and the roadmap live in the
[MiRA repository](https://github.com/Ecological-Complexity-Lab/MiRA)
(`development` branch, `dev/ggmira/`). Please report MiRA issues at
<https://github.com/Ecological-Complexity-Lab/MiRA/issues>.
