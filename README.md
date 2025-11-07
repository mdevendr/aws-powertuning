## Serverless Performance & Cost Optimization — Production-Ready Pattern

This repository demonstrates **how to measure, optimize, and continuously improve AWS Lambda performance and cost — using data, not assumptions.**

It brings together:

| Capability | Technology Used |
|----------|----------------|
| API + Serverless Application | Lambda + API Gateway + DynamoDB |
| Performance & Cost Benchmarking | **AWS Lambda Power Tuning (Step Functions)** |
| Real-World Load Testing | **Postman + Newman** (automated) |
| Automated CI/CD + Governance Controls | GitHub Actions + **OIDC (no stored IAM keys)** |
| Transparent Decision Evidence | HTML/Markdown/PNG reports committed into `reports/` |

### Why This Matters (Business & Architecture Perspective)

Most teams configure Lambda memory **once** and never revisit it.  
But workloads **change** — and so does the **performance → cost relationship**.

> **More memory does *not* always mean higher cost.**
>  
> More memory ⇒ More CPU ⇒ Faster execution ⇒ **Lower or equal cost**.

This repository provides a **repeatable, automated, auditable** way to prove and apply the *right* configuration.

### Business & Architecture Overview
Lambda cost is directly influenced by **execution duration** and **configured memory**.  
However, **more memory ≠ more cost** — because higher memory also allocates **more CPU**, often **reducing execution time significantly**.

| Outcome | Benefit |
|---|---|
| **Reduced Cloud Cost** | Prevents over-provisioning & performance waste |
| **Better Customer Experience** | Lower latency and faster response times |
| **Governance & Risk Control** | Memory changes require optional approval |
| **Repeatability & Standardization** | One method that scales across teams and workloads |

This repository provides:

| Capability | Benefit |
|-----------|---------|
| Automated performance benchmarking across multiple memory sizes | Identify the optimal configuration for your workload |
| Visualization of performance + cost | Clear evidence for architectural decisions |
| GitHub-based optional approval workflow | Governance & controlled rollout |
| No shared credentials (OIDC) | Enterprise-grade security posture |
| IaC (Terraform) | Repeatable across dev → staging → prod |

---
### Architecture (High-Level)

#### A. Executive / Business Overview

This solution implements a **self-optimising serverless application** that automatically evaluates and improves its own **performance, cost efficiency, and scalability**. It continuously measures how different Lambda memory configurations impact **latency, throughput, and total execution cost**, then identifies the **optimal configuration** for the workload.

Depending on governance requirements, the system can either:
- **Apply the recommended memory automatically**
- Require **manual approval** before adjusting the Lambda configuration

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
### Evidence & Reports (Automatically Written to Git)

| Report | Location | Purpose |
|---|---|---|
| AWS Powertuner (128,256,512,1024 MB) | `reports/pwrt1.pdf` | Baseline performance |
| Raw Power Tuning Output | `reports/history/tuning-*.json` | Execution duration + cost by memory size |
| Visualization Link (interactive) | `reports/power-tuner-report.md` | Shows cost/performance curve clearly |
| Load Test (512 MB) | `reports/512MB.pdf` | Baseline performance |
| Load Test (1024 MB) | `reports/1024MB.pdf` | Improved performance case |
| Summary of Recommendation | `reports/memory-change-summary.md` | Decision justification |
| CI Smoke Test Result | `reports/history/newman-*.html` | Verifies API still works post-change |

### Example Power Tuning Visualizations
(Already included in `reports/`)
- `pwrt1.png`
- `pwrt2.png`
- `pwrt3.png`

### Performance & Cost Metrics

#### AWS Lambda Power Tuning Results
| Memory (MB) | Avg Duration (ms) | Cost per Invoke (USD) | Observed Behavior | Outcome |
|------------:|------------------:|----------------------:|------------------|---------|
| 128         | ~1900 ms          | ~0.00000045           | CPU-starved; slow | ❌ Worst performance |
| 256         | ~200–300 ms       | ~0.00000016           | Stable & efficient | ✅ Best Cost Efficiency |
| 512         | ~550–650 ms       | ~0.00000048           | No performance gain; cost ↑ | ⚠️ Avoid |
| 1024        | ~170–250 ms       | ~0.00000024           | Fastest & stable latency | ⭐ Best Performance |

#### Postman Load Test Results (Real Workload Behavior)
| Memory (MB) | Avg Response Time | P90 | P95 | P99 | Error Rate | Throughput | Outcome |
|------------:|------------------:|----:|----:|----:|-----------:|-----------:|--------|
| 512         | ~140–160 ms       | ~190 ms | ~220 ms | ~260+ ms | 0% | ~5–7 req/s | ⚠️ Latency variability under load |
| 1024        | **~70–90 ms**     | **~90 ms** | **~105 ms** | **~160 ms** | **0%** | **Higher sustained throughput** | ✅ Faster & more stable |

---
### Memory Optimization Workflow

1. Deploy infrastructure via Terraform  
2. Power Tuner runs parallel Lambda executions across memory settings  
3. System computes **cost vs performance trade-offs**
4. Best memory configuration value is produced (e.g., `1024 MB`)
5. Mode-driven update:
   - **Auto:** Memory is updated automatically
   - **Manual:** GitHub Issue is created → Reviewer responds **approve/deny**

---

### Reports & Evidence (Automatically Generated)

| Report Type | Location | Examples |
|---|---|---|
| **Power Tuning Visualization** | `reports/history/` | `power-tuner-*.png`, `.html` |
| **Load Test Comparison** | `reports/` | `512MB.pdf`, `1024MB.pdf` |
| **Raw Benchmark Output** | `reports/history/` | `tuning-*.json` |
| **API Smoke Test Report** | `reports/history/` | `newman-*.html`, `newman-*.md` |
| **Change Summary** | `reports/history/` | `memory-summary-*.md` |

---

###  Evidence & Reports (Automatically Written to Git)
## 📁 Reports & Evidence

All tuning + benchmark evidence is versioned inside the repository for traceability and auditability.

| Report | Description | Link |
|-------|-------------|------|
| **Power Tuning Raw Output (Latest)** | Full tuning execution result JSON | https://github.com/mdevendr/aws-powertuning/blob/main/reports/history/tuning-20251107-121253.json |
| **Power Tuning Visualization (HTML)** | Interactive visualization of memory vs cost vs latency | https://github.com/mdevendr/aws-powertuning/blob/main/reports/history/power-tuner-20251107-121253.html |
| **Power Tuning Visualization (Markdown)** | Text-friendly report for documentation | https://github.com/mdevendr/aws-powertuning/blob/main/reports/history/power-tuner-20251107-121253.md |
| **Current Tuning Recommendation Summary** | Recommended configuration & justification | https://github.com/mdevendr/aws-powertuning/blob/main/reports/history/memory-summary-20251107-121253.md |
| **Load Test (512MB)** | Baseline performance benchmark at 512MB | https://github.com/mdevendr/aws-powertuning/blob/main/reports/512MB.pdf |
| **Load Test (1024MB)** | Optimized performance benchmark at 1024MB | https://github.com/mdevendr/aws-powertuning/blob/main/reports/1024MB.pdf |
| **Post-Deploy Smoke Test Report (HTML)** | Newman run results to confirm API correctness | https://github.com/mdevendr/aws-powertuning/blob/main/reports/history/newman.html |
| **Post-Deploy Smoke Test (Markdown)** | Text summary for documentation and auditing | https://github.com/mdevendr/aws-powertuning/blob/main/reports/history/newman.md |
| **Power Tuner Result Snapshot #1** | Key performance comparison | https://github.com/mdevendr/aws-powertuning/blob/main/reports/pwrt1.PNG |
| **Power Tuner Result Snapshot #2** | Key performance comparison | https://github.com/mdevendr/aws-powertuning/blob/main/reports/pwrt2.PNG |
| **Power Tuner Result Snapshot #3** | Key performance comparison | https://github.com/mdevendr/aws-powertuning/blob/main/reports/pwrt3.PNG |


---

###  How Memory Optimization is Performed

This repository supports **three ways to tune memory**, depending on your maturity:

### **1) Manual Tuning in AWS Console (Quick Exploration)**

1. Deploy workload
2. Open AWS Lambda Power Tuning (console visualization)
3. Observe which memory reduces execution time with minimal cost impact

Used for early discovery and architectural justification.

---

### **2) Load Testing Optimization — “Elbow Method”**

Use **Postman/Newman** to test real traffic patterns:

| Memory | Avg Latency | Result |
|---|---:|---|
| **512 MB** | Higher latency | Baseline |
| **1024 MB** | **~40–55% faster** | **Optimal for this workload**  |

See included reports:  
- `reports/512MB.pdf`  
- `reports/1024MB.pdf`

---

### **3) Automated Optimization Pipeline (This Repository)**

* Executes tuning across selected memory levels  
* Generates cost/performance evidence  
* Creates a recommendation  
* **If approvals are required → prompts via GitHub Issue**  
* Updates Lambda memory configuration  
* Runs smoke tests  
* Commits final reports back into repo for transparency

**Governance is controlled by a single variable:**

| Mode | Behavior |
|---|---|
| `ask_approval = true` | Architect or Lead must approve before applying change |
| `ask_approval = false` | Memory updated automatically (e.g., dev/staging) |

---

###  Key Takeaway

> **We stop guessing. We start measuring.**  
> **This repository makes performance tuning repeatable, governed, and evidence-based.**

This is not *just* AWS Lambda Power Tuning.  
This is a **production-ready decision framework** for Serverless optimization.

---

#### Credits & Author

**Mahesh Devendran**  
Cloud Architect • AWS • Serverless • FinOps  
[LinkedIn] (https://www.linkedin.com/in/mahesh-devendran-83a3b214/)

---

