# ❓ FAQ — Serverless Power Tuning & Automated Memory Optimization

This FAQ covers the *why*, *how*, and *governance considerations* behind the automation.

---

###  Why not just run AWS Lambda Power Tuning manually in the console?

Running the Power Tuning state machine manually gives you a result, but it is:
- A **one-time experiment**
- Not repeatable
- Not validated under **load**
- Not backed by stored evidence
- Not governed (no approval step)
- Not automatically re-run as workloads evolve

**This project operationalizes tuning** into a **repeatable engineering practice** — with:
- Automated tuning
- Performance verification using real traffic (Newman/Postman)
- Change approval workflows (optional)
- Reports pushed to repo for audit & architecture review

---
###  Why not just schedule the Power Tuner using a cron expression?

A cron-triggered Power Tuner run:
- Identifies the optimal memory **for that moment**
- But does **not**:
  - Verify behavior under real workload patterns
  - Generate reports
  - Store results for audit
  - Apply or request approval for changes

This automation validates, proves, documents, and (optionally) applies the tuning change in a **controlled and reviewable** manner.

---

###  Who is this workflow intended for? Developers or Platform/Architecture teams?

This pattern is designed for:
- **Platform Engineering**
- **Cloud Centers of Excellence**
- **Enterprise Architecture**
- **FinOps Programs**
- **Service/Workload Owners**

It is **not** meant for general application developers to self-tune Lambdas.

It provides:
- **Repeatability**
- **Governance**
- **Evidence-backed decisions**

---

###  Why does memory tuning matter if Lambda is “serverless” and “auto-scales”?

Because:
- Lambda execution time = **actual billable cost**
- Memory directly controls **CPU allocation**

Often:
> **More memory → more CPU → faster execution → lower total cost**

This workflow proves & enforces this relationship using real data.

---

###  Can this tuning pipeline break functionality?

No — because it:
1. **Runs load tests** before tuning.
2. **Compares performance and stability** across configurations.
3. Supports a **manual approval gate** before any memory change is applied.

If approval is **disabled**, the tuning change is still based on measured performance, not guesswork.

---

###  Can this be reused for *other* Lambda architectures?

Yes — it was intentionally designed to be **plug-and-play**:

- Any Lambda ARN can be passed into the tuning workflow
- The workflow auto-discovers the Power Tuner state machine region + ARN
- No stored IAM keys → secure by default (OIDC)

This enables **organization-wide standardization**.

---

###  Where are the tuning and test results stored?

They are:
- Saved under `reports/history/<timestamp>/`
- Versioned in Git (audit trail for CAB/architecture reviews)
- Available for dashboards or Confluence documentation

This creates **traceable and reviewable optimization evidence.**

---

###  What is the “ask_approval” toggle used for?

| Mode | Behavior | Suitable For |
|---|---|---|
| `ask_approval = true` | Human approves change in GitHub Issue | Regulated / Change-controlled environments |
| `ask_approval = false` | Lambda memory auto-updates | Rapid iteration / lower environments / platform automation |

---

###  Can this pipeline run periodically?

Yes — it can be triggered via:
- `repository_dispatch`
- `workflow_dispatch`
- `cron` (scheduled tuning)

This ensures tuning stays accurate as **traffic patterns and workloads evolve**.

---

###  What business value does this provide?

| Business Impact | Description |
|---|---|
| Cost Efficiency | Prevents over/under-provisioning |
| Predictable Performance | Ensures latency remains stable under growth |
| Architectural Confidence | Data-backed decisions instead of guesswork |
| Governance & Auditability | Reports automatically stored and traceable |
| Platform Standardization | Can be applied across many workloads consistently |

###  Why are reports stored in the Git repository, and is this suitable for production?

Storing reports in Git is useful for:
- Demonstrating traceability in simple environments
- Sharing results across architecture and platform teams
- Quick audit reference during development phases

However, **most enterprises will not store operational tuning outputs in Git** long-term.

Instead, the recommended production pattern is:

**Use S3 as the System of Record**
- Versioned S3 bucket (e.g., `org-platform-observability-lambda-tuning`)
- SSE encryption (SSE-S3 or SSE-KMS)
- Lifecycle policies (e.g., retain 6–12 months)
- Optional access controls by platform / FinOps / architecture teams

**Optional Enhancements**
- **Athena** queries for trend analysis
- **QuickSight** dashboards for organizational insight
- **EventBridge** triggers for automated re-tuning signals (traffic change, latency drift, etc.)

**Summary**
- Git storage is acceptable for **demo / PoC / team-level adoption**
- **S3-based storage is recommended for production**

# ❓ FAQ — AWS Lambda Power Tuning Automation

### What problem does this solve?
Most teams configure Lambda memory once and never revisit it.  
But workloads evolve, traffic patterns shift, and performance/cost profiles change.  
This pipeline enables **continuous, data-driven right-sizing** instead of guesswork.

---

### Why automate power tuning instead of running it manually in the AWS console?
| Manual Console Run | Automated Pipeline |
|---|---|
| One-off analysis | Repeatable & schedulable |
| Decisions stored in screenshots | Decisions stored as evidence reports |
| Easy to forget after release | Built into delivery workflow |
| No governance / audit | Optional approval + versioned artifacts |
| Requires console access | Works from CI with **zero IAM keys** (OIDC) |

---

### Why is **Newman load testing** included?
Power tuning alone measures execution characteristics.  
But **actual customer behavior** matters too.

Newman validates:
- How latency changes under real API traffic
- Whether higher memory improves concurrency throughput
- Whether performance benefits are meaningful for UX

---

### Why is the memory change **approval-based**?
Enterprise environments commonly require:
- CAB / Change Records
- Peer review / dual-control
- Non-production → production promotion steps

The pipeline supports both:
- `ask_approval = true` → **manual governance**
- `ask_approval = false` → **self-optimizing Lambda**

---

### Why are reports stored in **Amazon S3** instead of Git?
In real environments:
- Git is not a storage system
- Security policies restrict storing customer data in repos
- S3 provides lifecycle policies, encryption, retention & IAM control

This repo stores reports in Git **only for demonstration**.  
For production, the pipeline pushes to **S3**.

---

### What role does Terraform play?
Terraform ensures the infrastructure can be:
- Version-controlled
- Repeated identically across multiple environments
- Audited, reviewed, and peer-approved

---

### Can this tuning workflow be applied to **other Lambdas / architectures**?
Yes.  
The tuning workflow is **decoupled** and accepts:
- Lambda ARN
- API invoke URL (optional)

This makes it **plug-in** to any serverless workload:
- Event-driven Lambdas
- Step Functions orchestrations
- Microservices with API Gateway
- Streaming processors

---

### What business value does this deliver?
- Faster customer experience
- Predictable & explainable cloud costs
- Architectural transparency
- Repeatable FinOps practice

This shifts tuning from art → **engineering discipline**.

---


