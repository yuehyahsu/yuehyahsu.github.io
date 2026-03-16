# scaffold_quarto_academic_site.R
# Creates a Quarto academic website ready for GitHub Pages.

# -----------------------------
# 0) USER SETTINGS (edit these)
# -----------------------------
site_dir      <- "site"      # local folder to create
your_name     <- "Sam Hsu"
tagline       <- "Development Economics | Applied Micro | Field Experiments"
affiliation   <- "University of Chicago"
email         <- "yuehya@uchicago.edu"
github_user   <- "yuehyahsu"

# Repo name on GitHub:
# - For a personal site at https://<user>.github.io : repo must be "<user>.github.io"
# - For a project site at https://<user>.github.io/<repo> : repo can be anything
repo_name     <- paste0(github_user, ".github.io")  # OR "academic-website"

# Publish method:
# - "docs"    : render into /docs and GitHub Pages serves that folder (simplest)
# - "ghpages" : publish to gh-pages branch (cleaner; can be automated)
publish_method <- "docs"  # "docs" or "ghpages"

# Optional: social links (leave "" to omit)
twitter_url   <- ""  # "https://twitter.com/..."
scholar_url   <- ""  # "https://scholar.google.com/citations?user=..."
orcid_url     <- ""  # "https://orcid.org/..."

# -----------------------------
# 1) Helpers
# -----------------------------
if (dir.exists(site_dir)) stop("Folder already exists: ", site_dir)

is_user_site <- identical(repo_name, paste0(github_user, ".github.io"))
site_url <- if (is_user_site) {
  sprintf("https://%s.github.io/", github_user)
} else {
  sprintf("https://%s.github.io/%s/", github_user, repo_name)
}

dir.create(site_dir, recursive = TRUE, showWarnings = FALSE)
old <- setwd(site_dir)
on.exit(setwd(old), add = TRUE)

dir.create("assets", recursive = TRUE, showWarnings = FALSE)
dir.create("files", recursive = TRUE, showWarnings = FALSE)

# Only create GH Actions workflow folder for ghpages method
if (publish_method == "ghpages") dir.create(".github/workflows", recursive = TRUE, showWarnings = FALSE)

write_file <- function(path, lines) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(text = lines, con = path, useBytes = TRUE)
}

# -----------------------------
# 2) Core Quarto config
# -----------------------------
output_dir_line <- if (publish_method == "docs") "  output-dir: docs" else NULL

# Build navbar right-side icons conditionally
navbar_right <- c(
  sprintf("      - icon: github\n        href: https://github.com/%s", github_user)
)

if (nzchar(scholar_url)) navbar_right <- c(navbar_right, sprintf("      - text: Scholar\n        href: %s", scholar_url))
if (nzchar(orcid_url))   navbar_right <- c(navbar_right, sprintf("      - text: ORCID\n        href: %s", orcid_url))
if (nzchar(twitter_url)) navbar_right <- c(navbar_right, sprintf("      - icon: twitter\n        href: %s", twitter_url))

quarto_yml <- c(
  "project:",
  "  type: website",
  output_dir_line,
  "",
  "website:",
  sprintf("  title: \"%s\"", your_name),
  sprintf("  site-url: \"%s\"", site_url),
  "  navbar:",
  "    left:",
  "      - href: index.qmd",
  "        text: Home",
  "      - href: research.qmd",
  "        text: Research",
  "      - href: teaching.qmd",
  "        text: Teaching",
  "      - href: talks.qmd",
  "        text: Talks",
  "      - href: cv.qmd",
  "        text: CV",
  "      - href: contact.qmd",
  "        text: Contact",
  "    right:",
  navbar_right,
  "",
  "  page-footer:",
  "    left: \"© {{< meta title >}}\"",
  "    right:",
  "      - text: \"Built with Quarto\"",
  "        href: https://quarto.org",
  "",
  "format:",
  "  html:",
  "    theme: cosmo",
  "    css: styles.css",
  "    toc: true",
  "    link-external-newwindow: true",
  "",
  "execute:",
  "  freeze: auto"
)

write_file("_quarto.yml", quarto_yml)

# .nojekyll is recommended for the docs/ method (harmless otherwise) :contentReference[oaicite:1]{index=1}
write_file(".nojekyll", "")

# Keep repo clean (don’t track build artifacts)
gitignore <- c(
  "/.quarto/",
  "/_site/",
  "/_cache/",
  "/.Rproj.user/",
  "/*.Rproj",
  ".DS_Store"
)
# IMPORTANT: do NOT ignore /docs if publish_method == "docs" (we want to commit docs/)
if (publish_method != "docs") gitignore <- c(gitignore, "/docs/")
write_file(".gitignore", gitignore)

# -----------------------------
# 3) Styling
# -----------------------------
styles_css <- c(
  "/* Minimal academic styling */",
  ".title { margin-bottom: 0.2rem; }",
  ".subtitle { margin-top: 0; opacity: 0.85; }",
  ".hero { margin-top: 1rem; margin-bottom: 1.5rem; }",
  ".meta-line { opacity: 0.85; }",
  "a { text-decoration-thickness: 0.08em; text-underline-offset: 0.18em; }",
  ".cv-link { font-weight: 600; }"
)
write_file("styles.css", styles_css)

# -----------------------------
# 4) Pages
# -----------------------------
index_qmd <- c(
  "---",
  sprintf("title: \"%s\"", your_name),
  sprintf("subtitle: \"%s\"", tagline),
  "page-layout: full",
  "---",
  "",
  ":::{.hero}",
  sprintf("**%s**  ", affiliation),
  "",
  sprintf("- Email: [%s](mailto:%s)", email, email),
  sprintf("- GitHub: <https://github.com/%s>", github_user),
  if (nzchar(scholar_url)) sprintf("- Google Scholar: <%s>", scholar_url) else NULL,
  if (nzchar(orcid_url)) sprintf("- ORCID: <%s>", orcid_url) else NULL,
  ":::", 
  "",
  "## About",
  "",
  "Write a 3–6 sentence research statement here. Aim for: (i) your core questions, (ii) your identifying variation / method, (iii) your main substantive areas, (iv) what you’re doing now.",
  "",
  "## Selected work (high signal)",
  "",
  "- **Paper title** (with coauthors) — *Journal/Status*  \n  Short one-line contribution. [[PDF](files/paper1.pdf)] [[Code](https://github.com/your/repo)]",
  "- **Paper title** — *Working paper*  \n  Short one-line contribution. [[Draft](files/paper2.pdf)]",
  "",
  "## Current projects",
  "",
  "- Project A: one-sentence summary, what’s novel, what’s next.",
  "- Project B: one-sentence summary, what you’ve learned so far."
)
write_file("index.qmd", index_qmd[!vapply(index_qmd, is.null, logical(1))])

research_qmd <- c(
  "---",
  "title: \"Research\"",
  "bibliography: publications.bib",
  "---",
  "",
  "## Working papers",
  "",
  "- **Title** (with X, Y) — *2026*  \n  2–3 lines: question, identification, headline result. [[PDF](files/wp1.pdf)]",
  "",
  "## Publications",
  "",
  "This list is generated from `publications.bib`. Add bib entries and they’ll appear here.",
  "",
  "---",
  "nocite: '@*'",
  "",
  "::: {#refs}",
  ":::"
)
write_file("research.qmd", research_qmd)

teaching_qmd <- c(
  "---",
  "title: \"Teaching\"",
  "---",
  "",
  "## Courses",
  "",
  "- **Course title**, role, term/year — 1 line summary. [[Syllabus](files/syllabus.pdf)]",
  "- **Course title**, role, term/year — 1 line summary.",
  "",
  "## Advising / mentoring",
  "",
  "- What you advise on, and how students should approach you (brief and concrete)."
)
write_file("teaching.qmd", teaching_qmd)

talks_qmd <- c(
  "---",
  "title: \"Talks\"",
  "---",
  "",
  "## Upcoming",
  "",
  "- *Seminar name*, Institution — Month Year (scheduled)",
  "",
  "## Selected past talks",
  "",
  "- **Talk title**, Venue — Month Year. [[Slides](files/slides.pdf)]",
  "- **Talk title**, Venue — Month Year."
)
write_file("talks.qmd", talks_qmd)

cv_qmd <- c(
  "---",
  "title: \"CV\"",
  "---",
  "",
  "Upload your CV PDF to `files/cv.pdf` and it will be served by the site.",
  "",
  "- [Download CV (PDF)](files/cv.pdf){.cv-link}"
)
write_file("cv.qmd", cv_qmd)

contact_qmd <- c(
  "---",
  "title: \"Contact\"",
  "---",
  "",
  sprintf("- **Email:** [%s](mailto:%s)", email, email),
  sprintf("- **GitHub:** <https://github.com/%s>", github_user),
  "",
  "Optional:",
  "",
  "- Add office hours, a Calendly link, mailing address (if you want), seminar availability, etc."
)
write_file("contact.qmd", contact_qmd)

# -----------------------------
# 5) Publications (BibTeX)
# -----------------------------
publications_bib <- c(
  "@article{your2025paper,",
  sprintf("  title = {%s},", "A Great Paper Title"),
  sprintf("  author = {%s},", paste0(your_name, " and Coauthor, A.")),
  "  journal = {Journal Name},",
  "  year = {2025},",
  "  volume = {12},",
  "  number = {3},",
  "  pages = {45--67},",
  "  doi = {10.1234/example-doi}",
  "}",
  "",
  "@unpublished{your2026wp,",
  "  title = {A Working Paper Title},",
  sprintf("  author = {%s},", your_name),
  "  note = {Working paper},",
  "  year = {2026}",
  "}"
)
write_file("publications.bib", publications_bib)

# Placeholder CV so links don't 404 locally
write_file("files/README.txt", "Put PDFs here (e.g., cv.pdf, papers, slides).")

# -----------------------------
# 6) Optional: GitHub Actions deploy (gh-pages)
# -----------------------------
if (publish_method == "ghpages") {
  # This matches Quarto's documented GitHub Action for publishing to gh-pages. :contentReference[oaicite:2]{index=2}
  publish_yml <- c(
    "on:",
    "  workflow_dispatch:",
    "  push:",
    "    branches: main",
    "",
    "name: Quarto Publish",
    "",
    "jobs:",
    "  build-deploy:",
    "    runs-on: ubuntu-latest",
    "    permissions:",
    "      contents: write",
    "    steps:",
    "      - name: Check out repository",
    "        uses: actions/checkout@v4",
    "",
    "      - name: Set up Quarto",
    "        uses: quarto-dev/quarto-actions/setup@v2",
    "",
    "      - name: Render and Publish",
    "        uses: quarto-dev/quarto-actions/publish@v2",
    "        with:",
    "          target: gh-pages",
    "        env:",
    "          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}"
  )
  write_file(".github/workflows/publish.yml", publish_yml)
}

# -----------------------------
# 7) Quick README
# -----------------------------
readme <- c(
  "# Academic website (Quarto + GitHub Pages)",
  "",
  "## Local preview",
  "1. Install Quarto: https://quarto.org",
  "2. Run: `quarto preview`",
  "",
  "## Publish",
  "- docs/ method: render to docs and configure GitHub Pages to publish from /docs.",
  "- gh-pages method: use `quarto publish gh-pages` and/or the included GitHub Action."
)
write_file("README.md", readme)

message("Done. Created site in: ", normalizePath(getwd(), winslash = "/"))
message("Next: run `quarto preview` in this folder.")
