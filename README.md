# Yunduan Lin Personal Website

This repository contains the source for [yunduanlin.github.io](https://yunduanlin.github.io), the academic website of Yunduan Lin.

The site uses the [al-folio](https://github.com/alshedivat/al-folio) Jekyll theme as its foundation, with local content for biography, research, publications, teaching, service, and CV.

## Local Development

```bash
bundle install
bundle exec jekyll serve
```

## Deployment

Pushing to `master` runs the GitHub Actions workflow in `.github/workflows/deploy.yml`, builds the Jekyll site, and deploys the generated `_site` output to the `gh-pages` branch.
