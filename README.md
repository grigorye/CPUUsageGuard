# CPUUsageGuard

A simple tool to keep processes that load CPU for a long time.

## Usage

```
CPUUsageGuard -pattern 'Google Chrome Helper --type=renderer'
```

```
▿ config: CPUUsageGuard.Config
  - pattern: "Google Chrome Helper --type=renderer"
  - cpuUsageThreshold: 10.0
  - samplesThreshold: 5
  - interval: 60.0
  - topDelay: 5
```
