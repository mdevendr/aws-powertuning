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

