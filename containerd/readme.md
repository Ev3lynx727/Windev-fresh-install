# ContainerD Development References

A comprehensive collection of container images and tools for development, testing, and deployment across various technology stacks.

## 🤖 AI/ML & Data Science Containers

### NVIDIA GPU-Accelerated Containers

#### Core NVIDIA Containers
- **NVIDIA CUDA Base**: `nvidia/cuda:11.8-devel-ubuntu22.04`
  - Full CUDA development environment
  - WSL2 GPU passthrough compatible
  - Includes CUDA toolkit, cuDNN, and development libraries

- **NVIDIA CUDA Runtime**: `nvidia/cuda:11.8-runtime-ubuntu22.04`
  - CUDA runtime for deployment
  - Smaller footprint than development version
  - Includes CUDA runtime libraries

- **NVIDIA CUDA CUDNN**: `nvidia/cuda:11.8-cudnn8-devel-ubuntu22.04`
  - CUDA with cuDNN for deep learning
  - Optimized for neural network computations
  - Includes development headers and libraries

#### AI/ML Inference & Serving
- **NVIDIA TensorRT**: `nvcr.io/nvidia/tensorrt:22.12-py3`
  - High-performance deep learning inference
  - Optimizes models for production deployment
  - Supports FP32, FP16, and INT8 precision

- **NVIDIA Triton**: `nvcr.io/nvidia/tritonserver:22.12-py3`
  - Multi-framework inference server
  - Supports TensorFlow, PyTorch, ONNX, TensorRT
  - REST and gRPC APIs for model serving

- **NVIDIA Triton with TensorRT**: `nvcr.io/nvidia/tritonserver:22.12-py3-igpu`
  - Triton server optimized for inference
  - Includes TensorRT for maximum performance
  - GPU-accelerated model execution

#### Computer Vision & Image Processing
- **NVIDIA DeepStream**: `nvcr.io/nvidia/deepstream:6.2-devel`
  - Streaming analytics toolkit
  - Real-time AI-based video analytics
  - Optimized for edge computing

- **NVIDIA Isaac ROS**: `nvcr.io/nvidia/isaac/ros:x86_64-ros2-humble-nav2`
  - Robotics framework with ROS 2
  - GPU-accelerated computer vision
  - Navigation and manipulation stacks

#### Scientific Computing & HPC
- **NVIDIA HPC SDK**: `nvcr.io/nvidia/nvhpc:22.11-devel-cuda11.8-ubuntu22.04`
  - High-performance computing toolkit
  - Fortran, C, C++ compilers with GPU support
  - Parallel programming libraries

- **NVIDIA RAPIDS**: `nvcr.io/nvidia/rapidsai/base:22.12-cuda11.8-py3.9`
  - GPU-accelerated data science libraries
  - Pandas, scikit-learn, and visualization on GPU
  - End-to-end data science workflows

#### Development & Tools
- **NVIDIA Container Toolkit**: `nvidia/container-toolkit:latest`
  - Runtime for GPU containers
  - Automatic GPU device detection
  - Seamless GPU passthrough

- **NVIDIA NGC CLI**: `nvcr.io/nvidia/ngc/ngc-cli:latest`
  - Command-line interface for NGC registry
  - Download and manage NVIDIA containers
  - Access to pre-trained models and datasets

#### Specialized NVIDIA Containers
- **NVIDIA Modulus**: `nvcr.io/nvidia/modulus/modulus:22.09`
  - Physics-informed neural networks
  - Scientific machine learning framework
  - GPU-accelerated physics simulations

- **NVIDIA Clara**: `nvcr.io/nvidia/clara/clara-parabricks:4.1.1-1`
  - Medical imaging AI toolkit
  - Genomics and healthcare applications
  - GPU-accelerated medical workflows

- **NVIDIA Merlin**: `nvcr.io/nvidia/merlin/merlin-training:22.12`
  - Recommender systems framework
  - Large-scale recommendation models
  - GPU-accelerated training and inference

#### NGC Registry Collections
- **NVIDIA NGC**: `nvcr.io/nvidia/`
  - Official NVIDIA container registry
  - Pre-trained models and datasets
  - Enterprise-grade containers

- **NVIDIA GPU Cloud**: `nvcr.io/nvidia/gpu-cloud/`
  - Cloud-native GPU containers
  - Optimized for Kubernetes deployments
  - Enterprise support included

#### Industry-Specific NVIDIA Containers
- **NVIDIA Maxine**: `nvcr.io/nvidia/maxine/`
  - AI-enhanced video conferencing
  - Real-time video processing
  - GPU-accelerated video effects

- **NVIDIA Riva**: `nvcr.io/nvidia/riva/`
  - Conversational AI toolkit
  - Speech recognition and synthesis
  - Multi-language support

- **NVIDIA Metropolis**: `nvcr.io/nvidia/metropolis/`
  - Smart city and retail analytics
  - Video analytics and insights
  - Edge-to-cloud AI solutions

### PyTorch Containers
- **PyTorch GPU**: `pytorch/pytorch:2.1.0-cuda11.8-cudnn8-devel`
  - Latest PyTorch with CUDA 11.8
  - Development and training environment
- **PyTorch CPU**: `pytorch/pytorch:2.1.0-cpu`
  - CPU-only version for development/testing
- **PyTorch Hub**: Pre-trained models and examples

### TensorFlow Containers
- **TensorFlow GPU**: `tensorflow/tensorflow:2.13.0-gpu`
  - GPU-accelerated TensorFlow 2.13
  - Includes CUDA and cuDNN
- **TensorFlow Serving**: `tensorflow/serving:2.13.0-gpu`
  - Production model serving
  - REST and gRPC APIs
- **TensorFlow Hub**: Reusable ML components

### Other ML Frameworks
- **Jupyter with GPU**: `jupyter/tensorflow-notebook:cuda11.8-cudnn8-devel-ubuntu22.04`
- **MXNet**: `mxnet/python:gpu`
- **Caffe2**: `caffe2/caffe2:snapshot`
- **Keras**: `keras/keras:latest`

## 🗄️ Database Containers

### Relational Databases
- **PostgreSQL**: `postgres:15-alpine`
  - Lightweight Alpine-based PostgreSQL 15
  - Includes pgAdmin for web interface
- **MySQL**: `mysql:8.0`
  - Latest MySQL 8.0 with performance optimizations
- **MariaDB**: `mariadb:10.11`
  - MySQL-compatible database
- **SQL Server**: `mcr.microsoft.com/mssql/server:2022-latest`

### NoSQL Databases
- **MongoDB**: `mongo:6.0`
  - Document database with replica set support
- **Redis**: `redis:7.0-alpine`
  - In-memory data structure store
- **Cassandra**: `cassandra:4.0`
  - Distributed NoSQL database
- **Elasticsearch**: `elasticsearch:8.6.0`

### Time-Series & Analytics
- **InfluxDB**: `influxdb:2.6`
  - Time-series database for metrics
- **ClickHouse**: `clickhouse/clickhouse-server:22.12`
  - High-performance analytical database
- **TimescaleDB**: `timescaledb:latest-pg15`
  - PostgreSQL extension for time-series

## ☁️ Cloud & Infrastructure

### AWS Containers
- **AWS CLI**: `amazon/aws-cli:2.11.0`
  - Official AWS command-line interface
- **AWS SAM**: `amazon/aws-sam-cli:latest`
  - Serverless application development
- **AWS CDK**: `amazon/aws-cdk:latest`
  - Infrastructure as Code toolkit

### Azure Containers
- **Azure CLI**: `mcr.microsoft.com/azure-cli:latest`
  - Microsoft Azure command-line tools
- **Azure Functions**: `mcr.microsoft.com/azure-functions/dotnet:4.0`
  - Serverless compute platform
- **Azure DevOps**: `mcr.microsoft.com/azure-pipelines/vsts-agent:latest`

### Google Cloud Containers
- **Google Cloud SDK**: `google/cloud-sdk:latest`
  - Complete GCP command-line tools
- **Cloud Build**: `gcr.io/cloud-builders/gcloud:latest`
  - CI/CD platform containers
- **Kubernetes Engine**: `gcr.io/google_containers/hyperkube:latest`

## 🛠️ Development Tools

### Language-Specific Containers
- **Node.js**: `node:18-alpine`
  - Lightweight Node.js development
- **Python**: `python:3.11-slim`
  - Minimal Python environment
- **Go**: `golang:1.20-alpine`
  - Go development with modules
- **Rust**: `rust:1.70-slim`
  - Rust compilation environment
- **Java**: `openjdk:17-slim`
  - JDK 17 for Java development
- **.NET**: `mcr.microsoft.com/dotnet/sdk:7.0`
  - .NET 7 SDK for development

### DevOps & Infrastructure
- **Docker-in-Docker**: `docker:dind`
  - Docker daemon in a container
- **Kubernetes Tools**: `bitnami/kubectl:latest`
  - Kubernetes command-line tool
- **Helm**: `alpine/helm:latest`
  - Kubernetes package manager
- **Terraform**: `hashicorp/terraform:latest`
  - Infrastructure as Code

## 📊 Monitoring & Observability

### Metrics & Monitoring
- **Prometheus**: `prom/prometheus:latest`
  - Metrics collection and alerting
- **Grafana**: `grafana/grafana:latest`
  - Visualization and dashboards
- **Node Exporter**: `prom/node-exporter:latest`
  - System metrics exporter

### Logging & Tracing
- **ELK Stack**:
  - `elasticsearch:8.6.0`
  - `logstash:8.6.0`
  - `kibana:8.6.0`
- **Fluentd**: `fluent/fluentd:latest`
  - Log collection and routing
- **Jaeger**: `jaegertracing/all-in-one:latest`
  - Distributed tracing

## 🔒 Security & Compliance

### Vulnerability Scanning
- **Trivy**: `aquasecurity/trivy:latest`
  - Container vulnerability scanner
- **Clair**: `quay.io/projectquay/clair:latest`
  - Static vulnerability analysis
- **Grype**: `anchore/grype:latest`
  - Vulnerability scanner for SBOM

### Security Tools
- **Docker Bench**: `docker/docker-bench-security:latest`
  - Docker security compliance
- **Hadolint**: `hadolint/hadolint:latest`
  - Dockerfile linter
- **OWASP ZAP**: `owasp/zap2docker-stable:latest`
  - Web application security scanner

## 🐛 Debugging & Testing

### Network Analysis
- **Wireshark**: `robertdahmer/docker-wireshark:latest`
  - Network protocol analyzer
- **tcpdump**: `corfr/tcpdump:latest`
  - Command-line packet analyzer
- **Wireshark Alternative**: `networkstatic/netshoot:latest`
  - Network troubleshooting tools

### Load Testing
- **Apache Bench**: `httpd:alpine` (includes ab)
- **Siege**: Custom container with siege
- **k6**: `grafana/k6:latest`
  - Modern load testing tool

## 🚀 Specialized Workloads

### CI/CD Containers
- **GitLab Runner**: `gitlab/gitlab-runner:latest`
- **Jenkins**: `jenkins/jenkins:lts`
- **Drone CI**: `drone/drone:latest`

### Media Processing
- **FFmpeg**: `jrottenberg/ffmpeg:latest`
  - Multimedia processing
- **ImageMagick**: `v4tech/imagemagick:latest`
  - Image manipulation

### Blockchain & Crypto
- **Bitcoin Core**: `bitcoin/bitcoin:latest`
- **Ethereum**: `ethereum/client-go:latest`
- **Hyperledger**: `hyperledger/fabric-peer:latest`

## 🖥️ NVIDIA Container Usage Guide

### WSL2 GPU Setup Requirements

#### Prerequisites
- **Windows NVIDIA Drivers**: Latest GeForce/Quadro drivers
- **WSL2 Kernel**: Updated WSL2 kernel with GPU support
- **NVIDIA Container Toolkit**: Installed in WSL2 environment
- **Docker Desktop**: WSL2 backend enabled

#### Verification Commands
```bash
# Check NVIDIA drivers in Windows
nvidia-smi

# Check GPU access in WSL2
nvidia-smi

# Verify container toolkit
nvidia-container-runtime --version
```

### Running NVIDIA Containers

#### Basic GPU Container
```bash
# Run CUDA container with GPU access
docker run --gpus all nvidia/cuda:11.8-base-ubuntu22.04 nvidia-smi

# Run with specific GPU
docker run --gpus device=0 nvidia/cuda:11.8-base-ubuntu22.04 nvidia-smi

# Run with GPU memory limit
docker run --gpus all --memory=4g nvidia/cuda:11.8-base-ubuntu22.04 nvidia-smi
```

#### PyTorch GPU Container
```bash
# Run PyTorch with GPU
docker run --gpus all -it pytorch/pytorch:2.1.0-cuda11.8-cudnn8-devel

# Mount local directory
docker run --gpus all -it -v $(pwd):/workspace pytorch/pytorch:2.1.0-cuda11.8-cudnn8-devel

# Jupyter notebook with GPU
docker run --gpus all -p 8888:8888 -v $(pwd):/workspace jupyter/tensorflow-notebook:cuda11.8-cudnn8-devel-ubuntu22.04
```

#### TensorFlow GPU Container
```bash
# Run TensorFlow with GPU
docker run --gpus all -it tensorflow/tensorflow:2.13.0-gpu

# TensorFlow Serving
docker run --gpus all -p 8501:8501 -v $(pwd)/models:/models tensorflow/serving:2.13.0-gpu
```

### Performance Optimization

#### Memory Management
```bash
# Limit GPU memory usage
docker run --gpus all --memory=8g --memory-swap=16g nvidia/cuda:11.8-base-ubuntu22.04

# Set GPU memory fraction
export TF_GPU_ALLOCATOR=cuda_malloc_async
export TF_FORCE_GPU_ALLOW_GROWTH=true
```

#### Multi-GPU Setup
```bash
# Use all GPUs
docker run --gpus all multi-gpu-application

# Use specific GPUs
docker run --gpus device=0,1 multi-gpu-application

# Use GPU by UUID
docker run --gpus gpu=$(nvidia-smi --query-gpu=gpu_uuid --format=csv,noheader | head -1) application
```

### Development Workflows

#### Jupyter Notebooks
```bash
# PyTorch Jupyter
docker run --gpus all -p 8888:8888 -v $(pwd):/workspace pytorch/pytorch:2.1.0-cuda11.8-cudnn8-devel jupyter notebook --allow-root --ip=0.0.0.0

# TensorFlow Jupyter
docker run --gpus all -p 8888:8888 -v $(pwd):/workspace tensorflow/tensorflow:2.13.0-gpu-jupyter jupyter notebook --allow-root --ip=0.0.0.0
```

#### Development Containers
```bash
# VS Code Dev Container with GPU
{
  "image": "nvidia/cuda:11.8-devel-ubuntu22.04",
  "runArgs": ["--gpus", "all"],
  "extensions": ["ms-python.python", "ms-toolsai.jupyter"]
}
```

#### Training Scripts
```bash
# Mount data and run training
docker run --gpus all \
  -v $(pwd)/data:/data \
  -v $(pwd)/models:/models \
  pytorch/pytorch:2.1.0-cuda11.8-cudnn8-devel \
  python train.py --data /data --output /models
```

### Troubleshooting

#### Common Issues
- **"Could not select device driver"**: Update WSL2 kernel
- **"No devices were found"**: Check NVIDIA drivers in Windows
- **Memory errors**: Reduce batch size or use `--memory` limits
- **Permission denied**: Ensure user is in docker group

#### Diagnostic Commands
```bash
# Check GPU status
nvidia-smi

# Check container runtime
docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu22.04 nvidia-smi

# Check GPU memory usage
nvidia-smi --query-gpu=memory.used,memory.total --format=csv

# Monitor GPU processes
nvidia-smi pmon
```

### Best Practices

#### Resource Management
- **Monitor GPU usage**: Use `nvidia-smi` regularly
- **Set memory limits**: Prevent out-of-memory errors
- **Use appropriate precision**: FP16/INT8 for inference
- **Batch processing**: Optimize batch sizes for GPU memory

#### Security Considerations
- **Container isolation**: Don't run privileged containers
- **Network restrictions**: Limit container network access
- **Volume mounting**: Be careful with host volume permissions
- **Regular updates**: Keep NVIDIA drivers and containers updated

#### Performance Tips
- **Data loading**: Use pinned memory for faster GPU transfers
- **Mixed precision**: Use automatic mixed precision training
- **Multi-GPU training**: Implement distributed training strategies
- **Profiling**: Use NVIDIA Nsight for performance analysis

### Integration with Development Tools

#### VS Code Integration
- **Dev Containers**: GPU-enabled development environments
- **Extensions**: Python, Jupyter, CUDA support
- **Remote Development**: SSH into GPU containers

#### Jupyter Integration
- **GPU monitoring**: Real-time GPU usage in notebooks
- **CUDA debugging**: Integrated debugging capabilities
- **Performance profiling**: Built-in profiling tools

#### CI/CD Integration
- **GPU-enabled pipelines**: GitHub Actions with GPU runners
- **Automated testing**: GPU-accelerated test suites
- **Model deployment**: Automated container builds with GPU support

## 📚 Learning & Documentation

### Interactive Learning
- **TryHackMe**: Various CTF containers
- **HackTheBox**: Penetration testing labs
- **OWASP Juice Shop**: Vulnerable web application

### Documentation Tools
- **MkDocs**: `squidfunk/mkdocs-material:latest`
- **Hugo**: `klakegg/hugo:latest`
- **Jekyll**: `jekyll/jekyll:latest`

## 🔧 Container Management

### Docker Utilities
- **Portainer**: `portainer/portainer-ce:latest`
  - Web-based Docker management
- **Docker Compose**: `docker/compose:latest`
- **Docker Registry**: `registry:2.8`

### Orchestration
- **Kubernetes**: `kindest/node:latest`
  - Local Kubernetes clusters
- **Minikube**: `kicbase/stable:latest`
- **k3s**: `rancher/k3s:latest`

## 📋 Usage Guidelines

### Image Selection Strategy
1. **Base Images**: Use official images when available
2. **Security**: Prefer images with recent updates
3. **Size**: Consider Alpine variants for smaller footprints
4. **GPU Support**: Use NVIDIA images for GPU workloads

### Best Practices
- **Multi-stage Builds**: Reduce final image size
- **Security Scanning**: Regular vulnerability checks
- **Version Pinning**: Use specific tags, not `latest`
- **Layer Caching**: Order commands for optimal caching

### WSL2 Considerations
- **GPU Passthrough**: Use `--gpus all` for NVIDIA containers
- **Volume Mounting**: Ensure proper permission handling
- **Network Access**: Configure port forwarding appropriately
- **Resource Limits**: Set memory and CPU limits for stability

### NVIDIA Container Compatibility Matrix

#### CUDA Version Support
| Container | CUDA Version | cuDNN | Ubuntu Base | WSL2 Compatible |
|-----------|--------------|-------|-------------|-----------------|
| `nvidia/cuda:11.8-*` | 11.8 | 8.6 | 22.04 | ✅ |
| `nvidia/cuda:11.6-*` | 11.6 | 8.4 | 20.04 | ✅ |
| `nvidia/cuda:11.4-*` | 11.4 | 8.2 | 20.04 | ✅ |
| `nvidia/cuda:11.2-*` | 11.2 | 8.1 | 20.04 | ✅ |

#### Framework Compatibility
| Framework | Container | CUDA Support | WSL2 Status |
|-----------|-----------|--------------|-------------|
| **PyTorch** | `pytorch/pytorch:*cuda*` | 11.8, 11.6 | ✅ Full |
| **TensorFlow** | `tensorflow/tensorflow:*gpu*` | 11.8, 11.6 | ✅ Full |
| **JAX** | `nvcr.io/nvidia/jax:*` | 11.8 | ✅ Full |
| **RAPIDS** | `nvcr.io/nvidia/rapidsai/*` | 11.8 | ✅ Full |
| **TensorRT** | `nvcr.io/nvidia/tensorrt:*` | 11.8 | ✅ Full |

#### GPU Architecture Support
- **Ampere (RTX 30xx)**: Full support with CUDA 11.6+
- **Ada Lovelace (RTX 40xx)**: Full support with CUDA 11.8+
- **Turing (RTX 20xx)**: Limited support, CUDA 11.4 max
- **Pascal (GTX 10xx)**: Deprecated, limited compatibility

### NVIDIA Container Registry Access

#### NGC CLI Usage
```bash
# Login to NGC
docker login nvcr.io

# Pull NVIDIA containers
docker pull nvcr.io/nvidia/tensorflow:22.12-tf2-py3

# List available containers
ngc registry image list nvidia/tensorflow

# Download models and datasets
ngc registry model download-version nvidia/models:resnet50
```

#### NGC Container Naming Convention
```
nvcr.io/nvidia/<framework>:<version>-<variant>
        ├── pytorch:22.12-py3
        ├── tensorflow:22.12-tf2-py3
        ├── tensorrt:22.12-py3
        └── cuda:11.8-devel-ubuntu22.04
```

### Performance Benchmarks

#### WSL2 GPU Performance
- **CUDA Performance**: 95-98% of native Windows performance
- **Memory Bandwidth**: Full GPU memory access
- **PCIe Bandwidth**: Near-native throughput
- **Multi-GPU**: Full support for multi-GPU setups

#### Container Overhead
- **Startup Time**: < 2 seconds for GPU containers
- **Memory Overhead**: ~50MB per container
- **I/O Performance**: Native filesystem performance
- **Network Performance**: Full network stack access

### Advanced Configuration

#### Custom NVIDIA Runtime
```dockerfile
# Use custom NVIDIA runtime
FROM nvidia/cuda:11.8-base-ubuntu22.04
RUN apt-get update && apt-get install -y nvidia-container-runtime

# Runtime configuration
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
```

#### GPU Monitoring in Containers
```bash
# Run monitoring container
docker run --gpus all -it nvidia/cuda:11.8-base-ubuntu22.04 watch -n 1 nvidia-smi

# GPU utilization monitoring
docker run --gpus all -v /tmp:/tmp nvidia/cuda:11.8-base-ubuntu22.04 nvidia-smi pmon
```

#### Environment Variables
```bash
# TensorFlow GPU memory growth
export TF_GPU_ALLOCATOR=cuda_malloc_async
export TF_FORCE_GPU_ALLOW_GROWTH=true

# PyTorch GPU settings
export CUDA_VISIBLE_DEVICES=0,1
export TORCH_USE_CUDA_DSA=1
```

## 🤝 Contributing

To add new container references:
1. Verify the image exists and is actively maintained
2. Include version tags and brief descriptions
3. Categorize appropriately
4. Test WSL2 compatibility when possible
5. Add usage examples or documentation links

## 📞 Support

For container-related issues:
- Check official documentation for each project
- Verify WSL2 compatibility with NVIDIA containers
- Use `docker system df` to monitor disk usage
- Run `docker system prune` for cleanup
