# Kubernetes Deployments

## Overview

Kubernetes Deployments provide a declarative way to manage your application's lifecycle. They allow you to describe the desired state of your application and Kubernetes will work to maintain that state.

## Deployment Strategies

### 1. Rolling Update (Default)
- Gradually replaces old pods with new ones
- Ensures zero downtime during updates
- Configurable with `maxSurge` and `maxUnavailable`
- Example configuration:
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
```

### 2. Recreate
- Terminates all existing pods before creating new ones
- Results in downtime during updates
- Useful for applications that can't run multiple versions simultaneously
- Example configuration:
```yaml
strategy:
  type: Recreate
```

### 3. Blue-Green Deployment
- Maintains two identical environments (blue and green)
- Traffic is switched from one environment to another
- Requires additional resources
- Can be implemented using Kubernetes services and labels

### 4. Canary Deployment
- Gradually rolls out changes to a subset of users
- Allows for testing in production with minimal risk
- Can be implemented using Kubernetes features or service meshes

## Deployment with Istio

Istio provides additional deployment capabilities through its traffic management features:

### 1. Traffic Splitting
- Distribute traffic between different versions of your application
- Example configuration:
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: myapp
spec:
  hosts:
  - myapp
  http:
  - route:
    - destination:
        host: myapp
        subset: v1
      weight: 90
    - destination:
        host: myapp
        subset: v2
      weight: 10
```

### 2. A/B Testing
- Route traffic based on specific criteria (headers, cookies, etc.)
- Useful for feature testing and experimentation

### 3. Circuit Breaking
- Prevent cascading failures
- Control traffic flow between services
- Configure retry policies and timeouts

### 4. Fault Injection
- Test application resilience
- Simulate service failures and network issues