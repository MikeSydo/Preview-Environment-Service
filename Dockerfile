# Demo Dockerfile for Preview Environment
# Replace this with your actual application Dockerfile.
# The GitHub Actions workflow (preview-build.yml) will build and push
# this image to GHCR tagged as pr-<number> for each pull request.

FROM nginxdemos/hello:plain-text
