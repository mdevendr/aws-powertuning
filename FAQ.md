# ❓ FAQ — Serverless Power Tuning & Automated Memory Optimization

This FAQ covers the *why*, *how*, and *governance considerations* behind the automation.

---

### **Q1. Why not just run AWS Lambda Power Tuning manually in the console?**

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

### **Q2. Why not just schedule the Power Tuner using a cron expression?**

A cron-triggered Power Tuner run:
- Identifies the optimal memory **for that moment**
- But does **not**:
  - Verify behavior under real workload patterns
  - Generate reports
  - Store results for audit
  - Apply or request approval for changes

This automation validates, proves, documents, and (optionally) applies the tuning change in a **controlled and reviewable** manner.

---

### **Q3. Who is this workflow intended for? Developers or Platform/Architecture teams?**

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

### **Q4. Why does memory tuning matter if Lambda is “serverless” and “auto-scales”?**

Because:
- Lambda execution time = **actual billable cost**
- Memory directly controls **CPU allocation**

Often:
> **More memory → more CPU → faster execution → lower total cost**

This workflow proves & enforces this relationship using real data.

---

### **Q5. Can this tuning pipeline break functionality?**

No — because it:
1. **Runs load tests** before tuning.
2. **Compares performance and stability** across configurations.
3. Supports a **manual approval gate** before any memory change is applied.

If approval is **disabled**, the tuning change is still based on measured performance, not guesswork.

---

### **Q6. Can this be reused for *other* Lambda architectures?**

Yes — it was intentionally designed to be **plug-and-play**:

- Any Lambda ARN can be passed into the tuning workflow
- The workflow auto-discovers the Power Tuner state machine region + ARN
- No stored IAM keys → secure by default (OIDC)

This enables **organization-wide standardization**.

---

### **Q7. Where are the tuning and test results stored?**

They are:
- Saved under `reports/history/<timestamp>/`
- Versioned in Git (audit trail for CAB/architecture reviews)
- Available for dashboards or Confluence documentation

This creates **traceable and reviewable optimization evidence.**

---

### **Q8. What is the “ask_approval” toggle used for?**

| Mode | Behavior | Suitable For |
|---|---|---|
| `ask_approval = true` | Human approves change in GitHub Issue | Regulated / Change-controlled environments |
| `ask_approval = false` | Lambda memory auto-updates | Rapid iteration / lower environments / platform automation |

---

### **Q9. Can this pipeline run periodically?**

Yes — it can be triggered via:
- `repository_dispatch`
- `workflow_dispatch`
- `cron` (scheduled tuning)

This ensures tuning stays accurate as **traffic patterns and workloads evolve**.

---

### **Q10. What business value does this provide?**

| Business Impact | Description |
|---|---|
| Cost Efficiency | Prevents over/under-provisioning |
| Predictable Performance | Ensures latency remains stable under growth |
| Architectural Confidence | Data-backed decisions instead of guesswork |
| Governance & Auditability | Reports automatically stored and traceable |
| Platform Standardization | Can be applied across many workloads consistently |

### **Q11. Why are reports stored in the Git repository, and is this suitable for production?**

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

---

If you need an enterprise-ready rollout playbook (multi-team), I can generate that as well.
