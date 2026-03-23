# GCP User Access Guide (Human Account)

**Audience:** Platform / DevOps engineer who needs to **view**, and in some cases **create/edit** GCP resources, but **admins will not grant full project Owner/Editor** and may **refuse networking-related IAM**.

**Important:** In GCP, “no networking permissions” usually means you **cannot** safely manage or troubleshoot:
- VPC, subnets, Serverless VPC Access connectors  
- Private Service Access / Service Networking  
- Cloud Armor policies attached to backend services  
- Load balancers, NEGs, forwarding rules  
- Some Cloud Run + private DB connectivity issues (you can still *see* errors, but not fix infra)

This doc gives **role bundles** admins can assign to your **user** (`user:you@company.com`).

---

## 1) Two ways you might work

### A) Recommended: you use **service accounts** for Terraform / pipelines
- Your **user** only needs **read access** (Viewer) + maybe Secret/Artifact “day‑to‑day” tasks.
- All dangerous changes go through CI using `ci-*@...iam.gserviceaccount.com`.

### B) You run Terraform locally with **your user credentials**
- Your user needs permissions **similar to the Terraform service account** (often broad).
- If admins refuse networking IAM, you **cannot** fully apply stacks like `project/`, `load_balancer/`, parts of `application/` (NEG + Armor).

---

## 2) Minimum safe pack — **Read-only / support** (no create)

Ask admins to grant **project-level**:

| Role | Why |
|------|-----|
| `roles/viewer` | Read most resources in the project |
| `roles/logging.viewer` | View logs (Cloud Run, LB, SQL errors) |
| `roles/monitoring.viewer` | View metrics dashboards |
| `roles/cloudtrace.user` | View traces (optional) |
| `roles/browser` | Lets you browse resources in console cleanly (optional) |

**Optional read-only extras (nice to have):**

| Role | Why |
|------|-----|
| `roles/cloudsql.viewer` | Inspect Cloud SQL instances/settings |
| `roles/redis.viewer` | Inspect Redis |
| `roles/run.viewer` | Inspect Cloud Run services/jobs |
| `roles/artifactregistry.reader` | List/pull images (read) |
| `roles/secretmanager.viewer` | See secret **metadata** (not secret values) |
| `roles/compute.viewer` | See VPC/LB/NEG objects read-only (if allowed) |

> `secretmanager.viewer` does **not** reveal secret values. Values require `secretAccessor`.

---

## 3) “I need to **create/edit** app resources” (without full Editor)

This pack focuses on **runtime operations**, not VPC creation.

### 3.1 Cloud Run operations (deploy new revisions, scale, traffic)

| Role | What you can do |
|------|------------------|
| `roles/run.developer` | Deploy/update Cloud Run services/jobs in permitted ways (common for devops) |
| **OR** `roles/run.admin` | Stronger: full admin on Cloud Run (often requested if developer isn’t enough) |

### 3.2 Artifact Registry (push images from laptop)

| Role | What you can do |
|------|------------------|
| `roles/artifactregistry.writer` | Push images |
| **OR** `roles/artifactregistry.repoAdmin` | Manage repos/tags more broadly |

### 3.3 Secrets (only if admins allow)

**Typical pattern:** admins keep Secret Manager **admin**, you only **read** secrets for debugging:

| Role | What you can do |
|------|------------------|
| `roles/secretmanager.secretAccessor` | Read secret **values** (powerful; often restricted) |

If you must add secret versions yourself:

| Role | What you can do |
|------|------------------|
| `roles/secretmanager.admin` | Create secrets/versions (very powerful; many orgs refuse) |

**Less risky alternative:** admin delegates “add version” via pipeline only.

### 3.4 Cloud SQL / Redis (only if you truly must change DB/Redis)

| Role | Notes |
|------|------|
| `roles/cloudsql.client` | Connect/auth helper; not enough to edit instance |
| `roles/cloudsql.editor` | Can modify many DB instance settings (still sensitive) |
| `roles/cloudsql.admin` | Full SQL admin (usually restricted) |
| `roles/redis.editor` | Edit Redis (sensitive) |

---

## 4) If admins allow **networking** (you need to run full infra Terraform)

If your job includes applying `project/`, `load_balancer/`, NEGs, Armor, VPC connector, PSA:

| Role | Why |
|------|-----|
| `roles/compute.networkAdmin` | VPC, subnets, connectors, PSA peering work |
| `roles/compute.securityAdmin` | Cloud Armor security policies |
| `roles/vpcaccess.admin` | Serverless VPC Access connectors |
| `roles/servicenetworking.networksAdmin` | Private Service Access / allocated ranges |
| `roles/dns.admin` | Private DNS zones/records (if used) |

LB + certs + forwarding rules also sit under Compute LB admin patterns; commonly covered alongside network/security admin roles in operational practice, but exact minimum can vary.

---

## 5) Terraform state buckets (if you run Terraform as your user)

If you use GCS remote state, your user needs object access to the bucket:

| Access | Role (on the **bucket** or project) |
|--------|-------------------------------------|
| Read state | `roles/storage.objectViewer` (bucket-level recommended) |
| Write state | `roles/storage.objectAdmin` (bucket-level recommended) |

> Prefer **bucket-level IAM**, not project-wide Storage Admin.

---

## 6) “Admin said: **no user IAM**, only service accounts” — what to ask instead

Ask for one of these supported models:

### Model 1 — **Read-only user + SA keys / WIF for changes**
- User: Section **2** (viewer/logging)
- Changes: CI/CD service accounts (see `GCP-ACCESS-PLAN.md`)

### Model 2 — **Group-based access (best practice)**
- Create Google Group: `gcp-cenomi-platform@company.com`
- Grant roles to the **group**
- Add your user to the group  
This avoids attaching many roles directly to one person.

### Model 3 — **Impersonation (“act as service account”)**
- User keeps limited permissions
- User can impersonate `tf-bootstrap@...` for break-glass:
  - `roles/iam.serviceAccountTokenCreator` on that SA **and**
  - user still needs whatever the SA has **via impersonation results** (usually done by using `gcloud --impersonate-service-account`)

> Many orgs prefer WIF/OIDC from Azure DevOps over user impersonation.

---

## 7) Practical recommendation (what to request in one email)

**If you only need to observe + troubleshoot:**
- `roles/viewer`
- `roles/logging.viewer`
- `roles/monitoring.viewer`
- optional: `roles/run.viewer`, `roles/cloudsql.viewer`, `roles/artifactregistry.reader`

**If you need to deploy Cloud Run + push images (no VPC changes):**
- add `roles/run.developer` (or `run.admin`)
- add `roles/artifactregistry.writer`

**If you need to run full Terraform for networking/LB:**
- add networking pack in Section **4**
- add bucket object roles in Section **5**

---

## 8) What you should NOT ask for unless absolutely necessary

- `roles/owner` (full control)
- `roles/editor` (very broad; includes a lot of networking + IAM-adjacent capabilities; often rejected)
- `roles/resourcemanager.projectIamAdmin` (manage project IAM; high risk)
- `roles/iam.serviceAccountAdmin` (create service accounts; high risk)
- `roles/secretmanager.admin` unless you truly manage secrets

---

## 9) One-page “ask admin” template

> Please grant my user `user:NAME@company.com` the following **project roles** in `PROJECT_ID`:  
> - (pick pack) Viewer-only / App operator / Network platform  
>  
> If direct user roles are not allowed, please:  
> 1) grant read-only roles to my user, and  
> 2) provide CI service accounts + (preferred) Workload Identity Federation for deployments,  
> OR allow **group-based** access via `GROUP_EMAIL`.
