# Local HTTP server that serves the MiRA web app plus the network (and,
# for mira() plots, the view spec) to the browser.
#
# Adapted from emln::plot_multilayer() (emln 1.2.0). Additions: the
# /api/view.json endpoint, the request handler as its own function (so it
# can be tested without starting a server), and a stricter path check.

NETWORK_ENDPOINT <- "/api/network.json"
VIEW_ENDPOINT <- "/api/view.json"
MAX_PORT_ATTEMPTS <- 50

CONTENT_TYPES <- c(
  html = "text/html; charset=utf-8",
  htm = "text/html; charset=utf-8",
  js = "application/javascript; charset=utf-8",
  mjs = "application/javascript; charset=utf-8",
  css = "text/css; charset=utf-8",
  json = "application/json; charset=utf-8",
  png = "image/png",
  jpg = "image/jpeg",
  jpeg = "image/jpeg",
  svg = "image/svg+xml",
  gif = "image/gif",
  ico = "image/x-icon",
  woff = "font/woff",
  woff2 = "font/woff2"
)
BINARY_EXTENSIONS <- c("png", "jpg", "jpeg", "gif", "ico", "woff", "woff2")

#' Serve MiRA with a network (and optional view spec) and open the browser
#'
#' @param network_json Network JSON string (from `.network_json()`).
#' @param view_json View spec JSON string, or NULL (then `/api/view.json`
#'   returns 404 and MiRA shows its default view).
#' @return The httpuv server handle, invisibly.
#' @keywords internal
#' @noRd
.serve_mira <- function(network_json, view_json = NULL, port = 8080,
                        mira_path = NULL, browser = getOption("browser")) {
  mira_path <- .resolve_mira_path(mira_path)
  message(sprintf("Serving MiRA from: %s", mira_path))

  server <- .start_server(.mira_app(network_json, view_json, mira_path), port)
  url <- sprintf("http://localhost:%d?autoload=true", server$port)
  message(sprintf("Server running at: %s", url))
  message("Call httpuv::stopServer(handle) to stop the server when done.")

  utils::browseURL(url, browser = .resolve_browser(browser))
  invisible(server$handle)
}

#' httpuv app: API endpoints first, then static MiRA files
#' @keywords internal
#' @noRd
.mira_app <- function(network_json, view_json, mira_path) {
  # Evaluate now: the handler runs later, when the plot the arguments were
  # computed from may have been changed or reassigned
  force(network_json)
  force(view_json)
  list(
    call = function(req) {
      path <- req$PATH_INFO
      if (path == NETWORK_ENDPOINT) return(.json_response(network_json))
      if (path == VIEW_ENDPOINT && !is.null(view_json)) return(.json_response(view_json))
      .static_response(path, mira_path)
    },
    onWSOpen = function(ws) {
      ws$close() # No WebSocket support needed
    }
  )
}

.json_response <- function(body) {
  list(
    status = 200L,
    headers = list(
      "Content-Type" = "application/json",
      "Access-Control-Allow-Origin" = "*",
      "Cache-Control" = "no-cache"
    ),
    body = body
  )
}

.static_response <- function(url_path, mira_path) {
  if (url_path == "/" || url_path == "") url_path <- "/index.html"
  file_path <- normalizePath(file.path(mira_path, gsub("^/", "", url_path)), mustWork = FALSE)

  # Only files inside mira_path. Compare against "<mira_path>/" so a sibling
  # directory that shares the prefix (e.g. ".../MiRA-dev") is rejected.
  if (!startsWith(file_path, paste0(mira_path, .Platform$file.sep))) {
    return(list(status = 403L, headers = list(), body = "Forbidden"))
  }
  if (!file.exists(file_path) || dir.exists(file_path)) {
    return(list(status = 404L, headers = list(), body = "Not Found"))
  }

  ext <- tolower(tools::file_ext(file_path))
  ctype <- if (ext %in% names(CONTENT_TYPES)) CONTENT_TYPES[[ext]] else "application/octet-stream"
  body <- if (ext %in% BINARY_EXTENSIONS) {
    readBin(file_path, "raw", file.info(file_path)$size)
  } else {
    paste(readLines(file_path, warn = FALSE), collapse = "\n")
  }
  list(
    status = 200L,
    headers = list("Content-Type" = ctype, "Cache-Control" = "no-cache"),
    body = body
  )
}

#' Start the server on `port`, or the next free port
#' @return list(handle, port)
#' @keywords internal
#' @noRd
.start_server <- function(app, port) {
  for (attempt in seq_len(MAX_PORT_ATTEMPTS)) {
    handle <- tryCatch(
      httpuv::startServer("127.0.0.1", port, app),
      error = function(e) NULL # port in use: try the next one
    )
    if (!is.null(handle)) return(list(handle = handle, port = port))
    port <- port + 1
  }
  stop("Could not find an available port to start the server after ",
       MAX_PORT_ATTEMPTS, " attempts.")
}

# Chrome on macOS needs the `open -a` form
.resolve_browser <- function(browser) {
  is_chrome <- !is.null(browser) && is.character(browser) &&
    tolower(browser) %in% c("chrome", "google chrome")
  if (is_chrome && Sys.info()[["sysname"]] == "Darwin") return("open -a 'Google Chrome'")
  browser
}

#' Resolve path to the MiRA web app
#'
#' Looks first for an installed copy at
#' \code{system.file("MiRA", package = "ggmira")}, then falls back to
#' sibling/dev locations for in-source development.
#' @keywords internal
#' @noRd
.resolve_mira_path <- function(mira_path = NULL) {
  if (!is.null(mira_path)) {
    if (!file.exists(file.path(mira_path, "index.html"))) {
      stop(sprintf("`mira_path` does not contain index.html: %s", mira_path))
    }
    return(normalizePath(mira_path, mustWork = TRUE))
  }

  # 1. Installed package: inst/MiRA
  installed <- system.file("MiRA", package = "ggmira")
  if (nzchar(installed) && file.exists(file.path(installed, "index.html"))) {
    return(normalizePath(installed, mustWork = TRUE))
  }

  # 2. Dev fallbacks (running from the ggmira source tree or a sibling checkout)
  cwd <- getwd()
  candidates <- c(
    file.path(cwd, "inst", "MiRA"),
    file.path(cwd, "..", "ggmira", "inst", "MiRA"),
    file.path(cwd, "..", "MiRA"),
    file.path(dirname(cwd), "MiRA")
  )
  for (cand in candidates) {
    if (file.exists(file.path(cand, "index.html"))) {
      return(normalizePath(cand, mustWork = TRUE))
    }
  }

  stop(
    "Could not find the MiRA web app.\n",
    "Looked in: system.file('MiRA', package = 'ggmira') and: ",
    paste(candidates, collapse = ", "), "\n",
    "If you are developing from source, pass `mira_path = ",
    "'path/to/MiRA'` explicitly."
  )
}
