# Deployment — GitHub Pages (manual step, because the GitHub App could not create a repo)

## What happened when this package was built

- GitHub identity was confirmed as `technicalboy2023` (connected).
- Creating a repository via the Muse GitHub App returned:
  `403 Resource not accessible by integration`.
- That means the App does not have permission to create repositories
  in that account, even though the user approved the attempt.
- No repository was created, and no live Pages URL exists yet.
- Do not use a Pages URL until you have created the repo and
  opened the deployed site yourself.

## Manual deployment (5–10 minutes, in a browser)

1. On GitHub, create a new public repository named
   `ec2-windows11-guide`. Do not add a README, .gitignore, or
   licence in the web form — this package already contains them.
2. Upload this whole folder to that repository, keeping the
   folder structure exactly as it is (`docs/`, `scripts/`,
   `website/`, `.github/workflows/pages.yml`, etc.).
   Easiest: clone the empty repo, copy the files in, commit, push.
3. In the repository: Settings → Pages → Build and deployment →
   Source: **GitHub Actions**.
4. Open the Actions tab. The `Deploy documentation to GitHub Pages`
   workflow should run on push to `main`. Wait for it to succeed.
5. Open the Pages URL shown in Settings → Pages (expected form:
   `https://technicalboy2023.github.io/ec2-windows11-guide/` —
   confirm the exact URL GitHub shows, do not guess it in a message).
6. Check on the live site: sidebar links, search, every Copy button,
   dark/light toggle, scroll progress, and a narrow mobile viewport.
7. Only after step 6 passes, share the live URL as verified.

## Alternative: let Muse push after App installation

1. Install the Muse GitHub App on the new repository (account
   owner / organisation admin step).
2. Come back to this chat and ask Muse to push this folder.
3. Muse will then use the snapshot-push procedure, which requires
   the repository to be confirmed empty or its head SHA to match.

## Updating the documentation later

Edit `docs/` first, mirror command changes in `website/index.html`
and `scripts/`, run `bash -n scripts/*.sh`, test the website
locally with `python3 -m http.server` in `website/`, commit, push
to `main`, and re-verify the live site. A push alone is not proof
the site updated — open it and check.
