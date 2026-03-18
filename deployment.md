# Deployment Guide (Scripts)

This document explains how to use the deployment scripts in `scripts/`:
- `deploy-backend.sh`
- `deploy-frontend.sh`

## What these scripts do

- Install required packages (`nodejs`, `nginx`, `git`, `mysql-client` for backend)
- Clone/update app repo: `https://github.com/pravinmishraaws/book-review-app.git`
- Build and run services with `pm2`
- Configure Nginx (frontend script)

## Prerequisites

- Ubuntu EC2 instances with internet access
- SSH access to instances
- Security groups/NACLs allow required traffic
- Terraform infrastructure already applied (ALB, DB, EC2)

## 1) Prepare scripts

From this repo root:

```bash
chmod +x scripts/deploy-backend.sh scripts/deploy-frontend.sh
```

## 2) Configure backend script

Open `scripts/deploy-backend.sh` and update these variables at the top:

- `DB_HOST` → your RDS endpoint
- `DB_PASS` → your DB password
- `ALLOWED_ORIGINS` → your **public ALB DNS** (without `http://`)

Also review if needed:

- `DB_USER` (currently `admin`)
- `DB_NAME` (currently `book_review_db`)
- `JWT_SECRET` (replace default)

## 3) Run backend deployment

SSH into your backend/app EC2 instance and run:

```bash
cd /path/to/book-review-terraform-iac
./scripts/deploy-backend.sh
```

Verify backend:

```bash
pm2 status
pm2 logs bk-backend --lines 100
```

## 4) Configure frontend script

Open `scripts/deploy-frontend.sh` and update:

- `PUBLIC_ALB_DNS` → your public ALB DNS (without `http://`)
- `INTERNAL_ALB_DNS` → your internal ALB DNS (without `http://`)

## 5) Run frontend deployment

SSH into your frontend EC2 instance and run:

```bash
cd /path/to/book-review-terraform-iac
./scripts/deploy-frontend.sh
```

Verify frontend/Nginx:

```bash
pm2 status
sudo nginx -t
sudo systemctl status nginx --no-pager
```

## 6) Post-deployment checks

- Open frontend using the public endpoint
- Test login/register and API-backed pages
- Check `/api/` requests are proxied successfully

## Common troubleshooting

- `Permission denied`: run `chmod +x` again.
- PM2 app not up: inspect logs with `pm2 logs`.
- Nginx fails test: run `sudo nginx -t` and fix syntax in generated config.
- CORS issues: confirm backend `ALLOWED_ORIGINS` matches frontend domain.
- DB connection issues: verify `DB_HOST`, `DB_USER`, `DB_PASS`, SG rules, and DB reachability.
