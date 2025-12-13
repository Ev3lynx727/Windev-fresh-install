# ContainerD Agent Instructions & References

## Primary Task
**Create a Dockerfile for Full-Stack Development Container**

Build a comprehensive container image that includes:
- Node.js, Python, Go development environments
- Database clients (PostgreSQL, MySQL, MongoDB)
- Cloud CLI tools (AWS, Azure, GCP)
- Development utilities and networking tools
- WSL2-optimized configuration

## Container Architecture Plan

### Base Image Strategy
- **Primary**: `ubuntu:22.04` for stability and WSL2 compatibility
- **Alternative**: `mcr.microsoft.com/devcontainers/base:ubuntu` for Dev Container compatibility
- **GPU Support**: NVIDIA CUDA base images when GPU acceleration needed

### Layer Organization
1. **System Dependencies**: Essential packages and libraries
2. **Language Runtimes**: Node.js, Python, Go, Java
3. **Development Tools**: Git, Docker CLI, build tools
4. **Cloud & Database Tools**: AWS CLI, kubectl, database clients
5. **Networking & Monitoring**: curl, wget, monitoring tools
6. **User Configuration**: Non-root user, PATH setup, shell configuration

### Key Features to Include
- **Multi-language Support**: JavaScript, Python, Go, Rust
- **Database Connectivity**: PostgreSQL, MySQL, Redis, MongoDB clients
- **Cloud Integration**: AWS, Azure, Google Cloud CLIs
- **Container Tools**: Docker-in-Docker, kubectl, Helm
- **Development Experience**: Git, SSH, VS Code extensions support
- **Security**: Non-root user, minimal attack surface

## NVIDIA Container Integration

### Should We Add NVIDIA Container Support?

**YES - Recommended for GPU-accelerated workloads**

### Implementation Strategy

#### 1. Base Image Selection
```dockerfile
# Option A: CUDA-enabled base image
FROM nvidia/cuda:11.8-devel-ubuntu22.04

# Option B: PyTorch with CUDA
FROM pytorch/pytorch:2.1.0-cuda11.8-cudnn8-devel

# Option C: TensorFlow with GPU
FROM tensorflow/tensorflow:2.13.0-gpu
```

#### 2. NVIDIA Container Toolkit Integration
```dockerfile
# Install NVIDIA Container Toolkit
RUN distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
    && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
       sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
       tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

RUN apt-get update && apt-get install -y nvidia-container-toolkit
```

#### 3. GPU-Aware Applications
- **Machine Learning**: TensorFlow, PyTorch, scikit-learn
- **Data Science**: Jupyter, pandas, numpy with GPU acceleration
- **Computer Vision**: OpenCV with CUDA support
- **Deep Learning**: CUDA-enabled frameworks

### Runtime Configuration
```bash
# Run with GPU support
docker run --gpus all nvidia-container

# WSL2 GPU passthrough
docker run --gpus all --runtime=nvidia nvidia-container
```

## Additional References to Add

### Development Containers
- **GitHub Codespaces**: https://github.com/features/codespaces
- **Dev Containers Spec**: https://containers.dev/
- **VS Code Dev Containers**: https://code.visualstudio.com/docs/devcontainers/containers

### Specialized Containers
- **.NET Development**: `mcr.microsoft.com/dotnet/sdk:7.0`
- **Java Development**: `openjdk:17-slim`
- **Rust Development**: `rust:1.70-slim`
- **PHP Development**: `php:8.2-cli`

### Database Containers
- **PostgreSQL**: `postgres:15-alpine`
- **MySQL**: `mysql:8.0`
- **MongoDB**: `mongo:6.0`
- **Redis**: `redis:7.0-alpine`

### Cloud Development
- **AWS Development**: `amazon/aws-cli:2.11.0`
- **Azure Development**: `mcr.microsoft.com/azure-cli:latest`
- **Google Cloud**: `google/cloud-sdk:latest`

### Monitoring & Observability
- **Prometheus**: `prom/prometheus:latest`
- **Grafana**: `grafana/grafana:latest`
- **ELK Stack**: Elasticsearch, Logstash, Kibana containers

### Security & Compliance
- **Trivy**: Container vulnerability scanning
- **Docker Bench**: Security compliance checking
- **Hadolint**: Dockerfile linting

## Implementation Roadmap

### Phase 1: Core Full-Stack Container
- [ ] Define base image and core dependencies
- [ ] Implement multi-language support
- [ ] Add database clients and cloud tools
- [ ] Configure development environment

### Phase 2: GPU Support Integration
- [ ] Add NVIDIA container toolkit
- [ ] Implement GPU-aware base images
- [ ] Test CUDA workloads in WSL2
- [ ] Document GPU usage patterns

### Phase 3: Advanced Features
- [ ] Add monitoring and observability tools
- [ ] Implement security scanning
- [ ] Create specialized variants (ML, Data Science, etc.)
- [ ] Add CI/CD integration

### Phase 4: Ecosystem Integration
- [ ] Integrate with Dev Containers specification
- [ ] Add VS Code extension recommendations
- [ ] Create docker-compose configurations
- [ ] Document WSL2 optimization tips

## Quality Assurance

### Testing Checklist
- [ ] Multi-architecture support (amd64, arm64)
- [ ] WSL2 compatibility verification
- [ ] GPU passthrough testing
- [ ] Performance benchmarking
- [ ] Security vulnerability scanning
- [ ] Documentation completeness

### Maintenance Plan
- **Base Image Updates**: Monthly security updates
- **Tool Updates**: Quarterly version bumps
- **Dependency Checks**: Automated vulnerability scanning
- **Performance Monitoring**: Resource usage tracking

## Related Files
- `wsl2-dev/install-nvidia-container.sh` - NVIDIA setup for WSL2
- `docs/build-with-devcontainer.md` - Dev Container usage guide
- `containerd/readme.md` - Additional container references
