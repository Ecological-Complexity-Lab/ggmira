# Contributing to ggmira

## MiRA’s app in `inst/MiRA`: change it in MiRA, then sync

`inst/MiRA` is a copy of
[MiRA](https://github.com/Ecological-Complexity-Lab/MiRA)’s web app. Do
not edit it here. A fix made only here is lost at the next sync, and the
website never gets it.

To change anything in the app (its JavaScript, CSS, `index.html` or the
manual):

1.  Make the change in MiRA, on a branch, and merge it to MiRA’s `main`.

2.  With MiRA and ggmira checked out side by side, run in MiRA:

    ``` sh
    npm run sync:ggmira
    ```

    This replaces `inst/MiRA` and records the MiRA commit in
    `inst/MiRA/MIRA_COMMIT`.

3.  Commit `inst/MiRA` in ggmira, with any R changes that go with it.

If ggmira needs the app to behave differently from the website, MiRA
handles that with the URL ggmira opens it with. `?autoload=true` means
MiRA was opened from R, `?pane=rstudio` means RStudio’s Viewer pane, and
`?save=true` means
[`mira_save()`](https://ggmira.ecomplab.com/reference/mira_save.md).

The `mira-bundle` check fails a pull request if `inst/MiRA` is not an
unedited sync of a commit on MiRA’s `main`.
