<div align="center">

# MERN Task Manager - DevOps Edition

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat-square&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=flat-square&logo=node.js&logoColor=white)](https://nodejs.org/)
[![React](https://img.shields.io/badge/React-61DAFB?style=flat-square&logo=react&logoColor=black)](https://react.dev/)
[![MongoDB](https://img.shields.io/badge/MongoDB-13AA52?style=flat-square&logo=mongodb&logoColor=white)](https://www.mongodb.com/)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

A **production-ready** full-stack task management application with complete DevOps pipeline featuring Docker containerization, Kubernetes orchestration, persistent storage, and horizontal pod autoscaling.

[Quick Start](#quick-start) • [Features](#features) • [Architecture](#architecture) • [Deployment](#deployment-options) • [Contributing](#author--contribution)

</div>

---

> **Enterprise-Grade Features:** Docker | Docker Compose | Kubernetes | PersistentVolumes | HPA | Metrics Server

**Repository:** [https://github.com/Hanzlase/k8s-mern-deployment.git](https://github.com/Hanzlase/k8s-mern-deployment.git)

---

## Quick Start

### Docker Compose (Local Development)
```bash
docker-compose up --build -d
# Access at http://localhost:3000
```

### Kubernetes (Production)
```bash
kubectl apply -f k8s/
# Access at http://localhost:30000
```

---

## Features

- [x] **Full MERN Stack** - React, Express, MongoDB, Node.js
- [x] **Docker Containerization** - Multi-stage builds with Alpine optimization
- [x] **Kubernetes Orchestration** - Production-grade deployment with 3 replicas
- [x] **Horizontal Pod Autoscaling** - Auto-scale based on CPU metrics (2-5 pods)
- [x] **Persistent Storage** - PersistentVolumes for data durability
- [x] **Health Monitoring** - Liveness and readiness probes
- [x] **Metrics Collection** - Real-time CPU/memory monitoring
- [x] **Service Discovery** - DNS-based internal communication

---

## Project Overview

A **MERN stack** application for managing tasks with a complete DevOps implementation:

| Component | Details |
|-----------|---------|
| **Backend** | Node.js/Express REST API with MongoDB integration |
| **Frontend** | React 19.1.1 + Vite with Tailwind CSS styling |
| **Containerization** | Docker with optimized multi-stage builds |
| **Orchestration** | Kubernetes with production-grade configuration |
| **Storage** | PersistentVolumes for data durability (1Gi) |
| **Scaling** | Horizontal Pod Autoscaler (2-5 replicas, 70% CPU) |

### Task Management Capabilities

- [x] Create tasks
- [x] View all tasks  
- [x] Update task status
- [x] Delete tasks
- [x] Real-time synchronization

---

## Architecture

### Docker Compose Stack
```
┌─────────────────────────────────────────────┐
│         Docker Compose Network              │
├─────────────────────────────────────────────┤
│                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │MongoDB   │  │Backend   │  │Frontend  │ │
│  │:27017    │  │:5000     │  │:3000     │ │
│  │Database  │  │Express   │  │React     │ │
│  └──────────┘  └──────────┘  └──────────┘ │
│                                             │
│       Data persists in mongodb_data/       │
│                                             │
└─────────────────────────────────────────────┘
```

### Kubernetes Cluster Architecture

**Architecture Overview:**
```
┌──────────────────────────────────────────────┐
│        Kubernetes Cluster                    │
├──────────────────────────────────────────────┤
│                                              │
│  Frontend Service (NodePort 30000)           │
│  ├─ Frontend Pod 1 (React 19.1.1 + Vite)   │
│  ├─ Frontend Pod 2 (React 19.1.1 + Vite)   │
│  └─ Frontend Pod 3 (React 19.1.1 + Vite)   │
│                                              │
│  Backend Service (ClusterIP)                │
│  ├─ Backend Pod 1 (Express 5.1.0)           │
│  ├─ Backend Pod 2 (Express 5.1.0)           │
│  └─ Backend Pod 3 (Express 5.1.0)           │
│                                              │
│  MongoDB Service (ClusterIP)                │
│  └─ MongoDB Pod 1 (Database + 1Gi PVC)      │
│                                              │
│  HPA Controller                             │
│  ├─ Backend HPA (2-5 replicas, 70% CPU)    │
│  └─ Frontend HPA (2-5 replicas, 70% CPU)   │
│                                              │
│  Metrics Server (monitoring)                │
│  └─ Collects CPU/Memory metrics             │
│                                              │
└──────────────────────────────────────────────┘
```

---

---

## Technology Stack

<table>
<tr>
<td width="50%">

### Frontend
- **React** 19.1.1 - UI Framework
- **Vite** 7.1.2 - Build Tool
- **Tailwind CSS** 4.1.13 - Styling
- **Axios** 1.11.0 - HTTP Client

</td>
<td width="50%">

### Backend
- **Node.js** Alpine - Runtime
- **Express** 5.1.0 - Web Framework
- **Mongoose** 8.18.0 - MongoDB ODM
- **CORS** 2.8.5 - Cross-Origin Support

</td>
</tr>
</table>

### DevOps & Infrastructure
- **Docker** - Container Engine
- **Docker Compose** - Local Orchestration
- **Kubernetes** - Production Orchestration
- **Metrics Server** - Resource Monitoring
- **Horizontal Pod Autoscaler** - Auto-Scaling
- **PersistentVolume** - Data Persistence
- **MongoDB** - NoSQL Database

---

## Project Structure

```
mern-task-manager-main/
│
├── k8s/                           ← Kubernetes Manifests
│   ├── mongodb-deployment.yaml
│   ├── mongodb-service.yaml
│   ├── backend-deployment.yaml
│   ├── backend-service.yaml
│   ├── frontend-deployment.yaml
│   ├── frontend-service.yaml
│   ├── mongo-storage.yaml
│   └── hpa.yaml
│
├── backend/                       ← Node.js/Express Server
│   ├── Dockerfile
│   ├── server.js
│   ├── models/
│   │   └── Task.js
│   ├── routes/
│   │   └── taskRoutes.js
│   ├── package.json
│   └── .env
│
├── frontend/                      ← React Application
│   ├── Dockerfile
│   ├── src/
│   │   ├── App.jsx
│   │   ├── api.js
│   │   └── components/
│   ├── vite.config.js
│   └── package.json
│
├── docker-compose.yml
├── README.md
└── README.html
```

---

## Deployment Options

### 🐳 Option 1: Docker Compose (Local Development)

Perfect for development and testing with single command startup.

```bash
# Clone and setup
git clone https://github.com/Hanzlase/k8s-mern-deployment.git
cd k8s-mern-deployment

# Start all services
docker-compose up --build -d

# Access services
# Frontend: http://localhost:3000
# Backend API: http://localhost:5000/api/tasks
```

**Includes:**
- MongoDB (port 27017) with persistent volume
- Express Backend (port 5000)
- React Frontend (port 3000)
- Health checks and auto-recovery
- Custom bridge network

---

### ☸️ Option 2: Kubernetes (Production-Ready)

Full orchestration with replicas, auto-scaling, and monitoring.

```bash
# Verify Kubernetes cluster
kubectl cluster-info

# Deploy all resources
kubectl apply -f k8s/

# Monitor deployment
kubectl get pods -w
kubectl get svc
kubectl get hpa -w

# Access frontend
# http://localhost:30000
```

**Includes:**
- 3 Backend pods with HPA (2-5 auto-scaling)
- 3 Frontend pods with HPA (2-5 auto-scaling)
- 1 MongoDB pod with 1Gi storage
- Metrics Server for monitoring
- Service discovery and load balancing
- Automatic pod recovery

---

### 📦 Option 3: Local Development (npm)

For development without containers:

```bash
# Backend setup
cd backend
npm install
# Create .env with MONGO_URI=mongodb://localhost:27017/mern-task-manager
npm run dev

# Frontend setup (new terminal)
cd ../frontend
npm install
npm run dev -- --host
```

---

## Quick Commands

### Docker Compose
```bash
docker-compose up --build -d      # Start services
docker-compose down               # Stop services
docker logs mern-backend          # View logs
docker ps                         # List containers
```

### Kubernetes
```bash
kubectl apply -f k8s/             # Deploy resources
kubectl get pods -w               # Watch pods
kubectl logs <pod-name>           # View logs
kubectl describe pod <pod-name>   # Pod details
kubectl top pods                  # Resource usage
kubectl delete -f k8s/            # Clean up
```

---

## System Specifications

| Specification | Value |
|---------------|-------|
| Backend Image Size | 295 MB |
| Frontend Image Size | 265 MB |
| Backend Replicas | 3 (auto-scales: 2-5) |
| Frontend Replicas | 3 (auto-scales: 2-5) |
| MongoDB Replicas | 1 |
| Storage Capacity | 1 Gi PersistentVolume |
| CPU Request per Pod | 100m |
| Memory Request per Pod | 128Mi |
| HPA CPU Threshold | 70% |
| Total Pods (Initial) | 7 |
| NodePort for Frontend | 30000 |

---

## Configuration Details

### MongoDB
```
Service: mongodb-service:27017
Username: admin
Password: password
Database: mern-task-manager
Storage: /data/mongodb (1Gi PVC)
```

### Backend API
```
Internal: backend-service:5000
External (Compose): http://localhost:5000
External (K8s): http://localhost:5000 (via port-forward)
Health Check: GET /api/tasks
```

### Frontend
```
Docker Compose: http://localhost:3000
Kubernetes: http://localhost:30000 (NodePort)
API Endpoint: http://backend-service:5000/api (K8s)
API Endpoint: http://localhost:5000/api (Compose)
```

---

## Monitoring & Debugging

### Check Service Health
```bash
# Docker Compose
docker ps
docker logs <service-name>

# Kubernetes
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### View Metrics
```bash
# Kubernetes only
kubectl top pods                       # CPU/Memory usage
kubectl top nodes                      # Node resource usage
kubectl get hpa                        # Autoscaler status
kubectl describe hpa backend-hpa       # Detailed HPA info
```

### Troubleshooting
- **Pods not starting:** Check `kubectl describe pod <name>`
- **API not responding:** Verify backend service: `kubectl get svc`
- **Frontend can't connect:** Check service DNS resolution
- **Storage issues:** Verify PVC status: `kubectl get pvc`
- **Scaling not working:** Check metrics-server: `kubectl get deployment metrics-server -n kube-system`

---

## Learning Resources

This project demonstrates real-world DevOps practices:

- **Containerization** - Docker multi-stage builds, image optimization
- **Orchestration** - Kubernetes deployments, services, networking
- **Storage** - PersistentVolumes and PersistentVolumeClaims
- **Autoscaling** - Horizontal Pod Autoscaler with metrics
- **Health Management** - Liveness and readiness probes
- **Resource Management** - CPU/memory requests and limits
- **Networking** - Service discovery and load balancing
- **Monitoring** - Metrics collection and observation  

### Documentation
- [Docker Documentation](https://docs.docker.com/) - Container platform
- [Kubernetes Documentation](https://kubernetes.io/docs/) - Orchestration platform
- [React Documentation](https://react.dev/) - UI framework
- [MongoDB Documentation](https://docs.mongodb.com/) - Database

---

## Best Practices

| Practice | Implementation |
|----------|-----------------|
| **Multi-Stage Builds** | Optimized image sizes (295MB backend, 265MB frontend) |
| **Alpine Linux** | Lightweight base image reduces attack surface |
| **Replicas** | High availability with multiple pod instances |
| **Health Checks** | Liveness and readiness probes for auto-recovery |
| **Resource Management** | CPU/memory requests prevent cluster overload |
| **Service Discovery** | DNS-based internal communication |
| **Data Persistence** | PersistentVolumes ensure data durability |
| **Auto-Scaling** | HPA scales based on real-time metrics |
| **Security** | CORS configured, environment-based secrets |
| **Logging** | Structured logging for debugging |
| **Testing** | Unit and integration test readiness |
| **Documentation** | Comprehensive guides and examples |

---

## Troubleshooting Guide

### Common Issues and Solutions

#### Docker Compose Issues

**Problem:** Port already in use
```bash
# Find process using port
netstat -ano | findstr :3000
# Kill process
taskkill /PID <PID> /F
```

**Problem:** Containers not connecting
```bash
# Check network
docker network ls
# Inspect network
docker network inspect <network-name>
# Restart services
docker-compose restart
```

**Problem:** MongoDB data not persisting
```bash
# Check volume
docker volume ls
# Remove and recreate
docker-compose down -v
docker-compose up --build -d
```

#### Kubernetes Issues

**Problem:** Pods stuck in `Pending`
```bash
# Check events
kubectl describe pod <pod-name>
# Check node resources
kubectl top nodes
# Check storage
kubectl get pvc
```

**Problem:** HPA not working (shows `<unknown>`)
```bash
# Verify metrics-server
kubectl get deployment metrics-server -n kube-system
# Check if metrics are available
kubectl get hpa <hpa-name>
# Wait 30-60 seconds for metrics collection
# Verify resource requests are set
kubectl describe deployment backend
```

**Problem:** Pod can't reach MongoDB
```bash
# Test DNS resolution
kubectl exec <pod-name> -- nslookup mongodb-service
# Check service
kubectl get svc mongodb-service
# Check logs
kubectl logs <pod-name>
```

**Problem:** Storage not binding
```bash
# Check PVC status
kubectl get pvc
# Check PV status
kubectl get pv
# Describe PVC for events
kubectl describe pvc mongodb-pvc
```

---

## Notes

### Networking
- Services communicate via DNS names (e.g., `mongodb-service`)
- Frontend connects to backend via service name in Kubernetes
- NodePort 30000 exposes frontend externally
- Internal services use ClusterIP

### Storage
- MongoDB data persists in PersistentVolume
- Data survives pod restarts and failures
- Volume capacity: 1Gi
- Access mode: ReadWriteOnce (RWO)

### Scaling
- HPA monitors CPU metrics every 15 seconds
- Scales up when CPU > 70%
- Scales down when CPU < 63% (after 5-minute cooldown)
- Minimum 2 pods, maximum 5 pods per deployment

---

## License

This project is open source and available for educational purposes.

---

## Author & Contribution

**DevOps Implementation** - Full containerization and orchestration setup with production-ready configurations.

### Key Features
- Docker multi-stage builds with Alpine optimization
- Docker Compose orchestration for local development
- Kubernetes manifests for production deployment
- Horizontal Pod Autoscaler with metrics monitoring
- Persistent storage with PersistentVolumes
- Health checks and self-healing capabilities
- Comprehensive documentation

### Repository
[![GitHub](https://img.shields.io/badge/GitHub-Hanzlase/k8s--mern--deployment-blue?style=flat-square&logo=github)](https://github.com/Hanzlase/k8s-mern-deployment.git)

```bash
git clone https://github.com/Hanzlase/k8s-mern-deployment.git
```

---

<div align="center">

### Made with care using Docker, Kubernetes, and modern DevOps practices

**Last Updated:** March 2026 | **DevOps Assignment** | **Production-Ready Setup**

</div>

