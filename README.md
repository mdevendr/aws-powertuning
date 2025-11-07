# 🚀 Serverless Power Tuning & Cost Optimization on AWS

This repository demonstrates a **production-ready pattern** for automatically evaluating and optimizing the **Lambda memory configuration** based on **performance vs cost trade-offs** — using:

- **AWS Lambda Power Tuning** (Step Functions)
- **Terraform** for reproducible infrastructure
- **GitHub Actions** with OIDC authentication (no stored IAM keys)
- **Postman + Newman** for smoke + functional verification
- **Optional Manual Approval** workflow for memory changes

---

## 🎯 Business & Architecture Overview

Lambda cost is directly influenced by **execution duration** and **configured memory**.  
However, **more memory ≠ more cost** — because higher memory also allocates **more CPU**, often **reducing execution time significantly**.

This repository provides:

| Capability | Benefit |
|-----------|---------|
| Automated performance benchmarking across multiple memory sizes | Identify the optimal configuration for your workload |
| Visualization of performance + cost | Clear evidence for architectural decisions |
| GitHub-based optional approval workflow | Governance & controlled rollout |
| No shared credentials (OIDC) | Enterprise-grade security posture |
| IaC (Terraform) | Repeatable across dev → staging → prod |

---
## 🧩 Architecture (High-Level)

### A. Executive / Business Overview

This solution implements a **self-optimising serverless application** that automatically evaluates and improves its own **performance, cost efficiency, and scalability**. It continuously measures how different Lambda memory configurations impact **latency, throughput, and total execution cost**, then identifies the **optimal configuration** for the workload.

Depending on governance requirements, the system can either:
- ✅ **Apply the recommended memory automatically**
- 🔒 Require **manual approval** before adjusting the Lambda configuration

#### Why This Matters

| Business Outcome | Benefit |
|---|---|
| **Reduced Cloud Spend** | Prevents over-provisioning and eliminates tuning guesswork |
| **Predictable Performance** | Ensures stable latency under real workloads |
| **Operational Efficiency** | Removes manual intervention and tuning cycles |
| **Governance-Ready** | Works with change management / CAB approval models |

This pattern is valuable for:
- FinOps / Cloud Cost Optimization programs
- Serverless production workloads at scale
- Organizations standardizing on **data-driven performance engineering**

---

### B. Technical Architecture (For Architects & Engineers)

      ┌───────────────────────┐
      │       Client / CI     │
      └──────────┬────────────┘
                 │
                 │ invoke_url
                 ▼
        ┌───────────────────────┐
        │   Amazon API Gateway  │
        └──────────┬────────────┘
                   │  (AWS_PROXY Integration)
                   ▼
            ┌───────────────┐
            │ AWS Lambda    │
            │ (Application) │
            └──────┬────────┘
                   │ DynamoDB SDK (boto3)
                   ▼
         ┌───────────────────────┐
         │ Amazon DynamoDB Table │
         └───────────────────────┘


 ┌───────────────────────────────────────────────────────────────┐
 │                Performance Optimization Pipeline               │
 │                                                               │
 │  GitHub Actions (CI/CD)                                       │
 │       │                                                       │
 │       ▼                                                       │
 │  AWS Lambda Power Tuner (Step Functions State Machine)        │
 │       │  executes test invocations at multiple memory levels  │
 │       ▼                                                       │
 │  tuning-output.json                                           │
 │       │                                                       │
 │       ├─ Auto Mode → Lambda memory updated automatically      │
 │       └─ Manual Mode → GitHub Issue approval required         │
 └───────────────────────────────────────────────────────────────┘

---

### Key AWS Services

| Component | Purpose |
|---|---|
| **API Gateway** | Provides REST API interface (`/items`, `/items/{id}`) |
| **Lambda (Application)** | CRUD logic + DynamoDB integration |
| **DynamoDB** | Serverless storage with predictable performance |
| **AWS Lambda Power Tuner (Step Functions)** | Executes benchmark tests across memory configs |
| **GitHub Actions** | Automates deployment, testing, tuning, and approvals |
| **Newman (Postman CLI)** | Validates API functionality post-deployment |
| **IAM Roles / Policies** | Ensures least-privilege and secure execution |

---

### 🔄 Memory Optimization Workflow

1. Deploy infrastructure via Terraform  
2. Power Tuner runs parallel Lambda executions across memory settings  
3. System computes **cost vs performance trade-offs**
4. Best memory configuration value is produced (e.g., `1024 MB`)
5. Mode-driven update:
   - **Auto:** Memory is updated automatically
   - **Manual:** GitHub Issue is created → Reviewer responds **approve/deny**

---

### 📁 Reports & Evidence (Automatically Generated)

| Report Type | Location | Examples |
|---|---|---|
| **Power Tuning Visualization** | `reports/history/` | `power-tuner-*.png`, `.html` |
| **Load Test Comparison** | `reports/` | `512MB.pdf`, `1024MB.pdf` |
| **Raw Benchmark Output** | `reports/history/` | `tuning-*.json` |
| **API Smoke Test Report** | `reports/history/` | `newman-*.html`, `newman-*.md` |
| **Change Summary** | `reports/history/` | `memory-summary-*.md` |

---

### ✅ Design Principles Demonstrated

- Serverless-first architecture
- Automated performance & cost optimization
- FinOps-friendly operational visibility
- CI/CD-integrated governance and approvals
- Repeatable + scalable pattern for enterprise workloads

---

