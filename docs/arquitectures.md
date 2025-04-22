## 1. AWS Elastic Beanstalk + Amazon RDS (Blue/Green)

![Elastic Beanstalk Blue/Green Diagram](https://docs.aws.amazon.com/es_es/elasticbeanstalk/latest/dg/images/aeb-architecture_crossaws2.png)

| **Pros**                                                                                   | **Cons**                                                                                   |
|--------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|
| ✅ Very quick to get started; handles provisioning, scaling and load balancing by itself.  | ❌ Limited control over underlying EC2 and networking details.                            |
| ✅ Built‑in Blue/Green support via CNAME swap for instant cutover :contentReference[oaicite:0]{index=0}.     | ❌ Deploy times can be slower than container‑based or serverless options.                  |
| ✅ Native integration with RDS Multi‑AZ for automatic failover .         | ❌ Harder to customize AMIs or host‑level settings.                                       |

_For full diagram see:_  
https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features.CNAMESwap.html

---

## 2. Amazon ECS on Fargate + ALB (Rolling/Canary)

![ECS Fargate Architecture](https://d2908q01vomqb2.cloudfront.net/1b6453892473a467d07372d45eb05abc2031647a/2018/01/26/Slide1-1024x592.png)

| **Pros**                                                                                                                | **Cons**                                                                                      |
|-------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|
| ✅ Fine‑grained control over container definitions, networking and IAM.                                                  | ❌ Steeper learning curve: tasks, services, clusters to configure. :contentReference[oaicite:1]{index=1}          |
| ✅ Zero‑downtime rolling updates (minimumHealthyPercent=100%, maximumPercent=200%).                                      | ❌ Potentially higher cost if CPU/memory sizing isn’t optimized.                              |
| ✅ Supports Canary or Blue/Green deployments via CodeDeploy traffic shifting.                                            | ❌ Must manage DB connection pooling (use RDS Proxy).                                        |

_For full diagram see:_  
https://docs.aws.amazon.com/AmazonECS/latest/developerguide/deployment-type-ecs.html

---

## 3. AWS Lambda + API Gateway + RDS Proxy (Version‑alias)

![Lambda → API Gateway → RDS Proxy](data:image/png;base64,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)

| **Pros**                                                                                                 | **Cons**                                                                                           |
|----------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| ✅ Fully serverless—no servers to manage.                                                                 | ❌ Cold‑start latency unless you provision concurrency.                                           |
| ✅ Instant traffic shifting with Lambda aliases (weighted routing) :contentReference[oaicite:2]{index=2}.                     | ❌ Hard limit: 15 min max execution time per invocation.                                          |
| ✅ Auto‑scales to zero when idle; pay‑per‑invocation billing.                                              | ❌ Requires RDS Proxy to safely manage DB connections and avoid exhaustion.                       |

_For full diagram see:_  
https://docs.aws.amazon.com/lambda/latest/dg/configuration-aliases.html

---

## 4. Amazon EKS (Kubernetes) + RDS (Rolling)

![Amazon EKS Rolling Update](https://d2908q01vomqb2.cloudfront.net/d435a6cdd786300dff204ee7c2ef942d3e9034e2/2025/01/10/backstage-diagram-1024x530.png)

| **Pros**                                                                                                              | **Cons**                                                                                          |
|-----------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| ✅ Ultimate flexibility: any pod spec, sidecars, service mesh, custom CNI.                                              | ❌ Highest operational overhead: cluster lifecycle, node upgrades, networking. :contentReference[oaicite:3]{index=3}  |
| ✅ Native Kubernetes rolling updates that respect PodDisruptionBudgets.                                                | ❌ Requires experienced Kubernetes/DevOps teams.                                                  |
| ✅ Integrates seamlessly with CI/CD tools like Helm, ArgoCD, Flux, etc.                                                | ❌ Base cost for EKS control plane + worker nodes can add up.                                     |

_For full diagram see:_  
https://docs.aws.amazon.com/eks/latest/userguide/update-managed-node-group.html

---

## 5. AWS App Runner + Amazon RDS (Blue/Green)

![AWS App Runner Architecture](https://docs.aws.amazon.com/es_es/apprunner/latest/dg/images/architecture.png)

| **Pros**                                                                          | **Cons**                                                                                 |
|-----------------------------------------------------------------------------------|------------------------------------------------------------------------------------------|
| ✅ Fully managed: builds, deploys, scales and secures your container automatically. | ❌ Less VPC/networking control compared to ECS/EKS.                                      |
| ✅ Blue/Green deployments with traffic splitting built‑in.                         | ❌ Fewer runtime‑tuning options than container/VM services.                               |
| ✅ Automatic HTTPS, health checks and seamless scaling.                            | ❌ Regional availability may lag behind other AWS compute services.                       |

_For full diagram see:_  
https://docs.aws.amazon.com/apprunner/latest/dg/what-is-apprunner.html

---

*All pros/cons derived from AWS official documentation.*
::contentReference[oaicite:4]{index=4}
