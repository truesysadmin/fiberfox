---
description: Repository Information Overview
alwaysApply: true
---

# FiberFox Information

## Summary
FiberFox is a high-performance (D)DoS vulnerability testing toolkit implementing various L4/7 attack vectors. Built with async networking to minimize CPU/RAM requirements while handling complex network interactions. The toolkit includes L4 attacks (UDP, TCP, CONNECTION), UDP-based amplification attacks (RDP, CLDAP, MEM, NTP, DNS), and L7 attacks (GET, STRESS, BYPASS, SLOW, CFBUAM, AVB). It supports distributed attack simulation through HTTP/SOCK4/SOCK5 proxies and provides comprehensive monitoring statistics.

## Structure
- **fiberfox/**: Core application module containing main attack orchestration logic
  - `main.py`: Primary entry point with attack vector implementations and CLI argument handling
  - `static.py`: Static configuration data (user agents, referrers)
  - `__init__.py`: Package initialization
- **docs/**: Documentation and analysis images
- **config files**: Configuration examples (config.json, prx.json, proxies.txt)

## Language & Runtime
**Language**: Python  
**Version**: 3.10.11 (specified in .python-version)  
**Build System**: setuptools  
**Package Manager**: pip  
**Package Version**: 0.3.7

## Dependencies
**Main Dependencies**:
- asks (HTTP client library)
- certifi (SSL certificates)
- curio (async I/O library)
- dnspython (DNS protocol implementation)
- impacket (network protocol library for IP/UDP packet handling)
- python-socks (SOCKS proxy protocol support)
- sparklines (terminal sparkline visualization)
- tabulate (table formatting for statistics)
- yarl (URL handling library)

## Build & Installation
```bash
# From PyPI
pip install fiberfox

# From source
git clone https://github.com/kachayev/fiberfox.git
cd fiberfox
python setup.py install

# Build Docker image
git clone https://github.com/kachayev/fiberfox.git
cd fiberfox
docker build -t fiberfox .
```

## Docker
**Dockerfile**: Dockerfile  
**Base Image**: python:3.10.4-buster  
**Configuration**: Installs dependencies via pip, copies source, and runs setuptools installation. Container entry point executes fiberfox command directly.

## Main Entry Points
**Console Script**: `fiberfox = fiberfox.main:run`  
**CLI Usage**: Configurable attack parameters include targets, concurrency (fibers), attack strategy, duration, proxies, reflectors, logging level, and connection timeout. Supports reading targets/proxies from files or proxy provider configurations.

**Key Flags**:
- `--targets`: Target URLs or IP addresses
- `--concurrency/-c`: Number of async fibers
- `--strategy/-s`: Attack type (UDP, TCP, STRESS, BYPASS, CONNECTION, SLOW, CFBUAM, AVB, GET)
- `--duration-seconds/-d`: Attack duration
- `--proxies-config`: Proxy server configuration file
- `--reflectors-config`: Reflector servers for amplification attacks
- `--log-level`: Logging verbosity (DEBUG, INFO, ERROR, WARN)
