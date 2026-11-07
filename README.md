# Setup checklist

1. Create the S3 state bucket (versioning on) and put its name in `terraform/backend.tf`.
2. In AWS, create the GitHub OIDC provider (`token.actions.githubusercontent.com`, audience `sts.amazonaws.com`).
3. Create an IAM role using `iam-github-oidc-trust-policy.json` (edit account ID and repo), attach `iam-github-role-policy.json` (edit state bucket name).
4. GitHub repo secrets: `AWS_ROLE_ARN` (role ARN) and `BACKEND_ENV` (contents of the backend env file).
5. Create a GitHub Environment named `production` (optionally with required reviewers).
6. In the frontend code, use `import.meta.env.VITE_API_URL` as the API base URL.
7. Backend CORS must allow `http://<elastic-ip>:3000`.
8. Copy the `.github`, `terraform`, `ansible` folders and the Dockerfiles into your repo, push to `main`.

The `backend/` and `frontend/` Dockerfiles go next to your existing source code.
