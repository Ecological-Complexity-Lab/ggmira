# ggmira

Plot multilayer networks in [MiRA](https://mira.ecomplab.com/) from R.

Internal development version (Ecological Complexity Lab).

```r
library(emln)
library(ggmira)

net <- load_emln(60)
plot_multilayer(net, bipartite = TRUE, setA_type = "pollinator")
```

During development, point to a local MiRA checkout:

```r
devtools::load_all("~/GitHub/ecomplab/ggmira")
plot_multilayer(net, bipartite = TRUE, mira_path = "~/GitHub/ecomplab/MiRA-dev")
```

Design notes, decisions and the roadmap live in the MiRA repository
(`development` branch, `dev/ggmira/`).
