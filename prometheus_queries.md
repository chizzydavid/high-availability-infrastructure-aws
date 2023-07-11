## Availability SLI
### The percentage of successful requests over the last 5m
```
sum(rate(flask_http_request_total{job="ec2", status!~"5.."}[5m])) / sum(rate(flask_http_request_total{job="ec2"}[5m]))
```

## Latency SLI
### 90% of requests finish in these times
```
histogram_quantile(0.90, sum(rate(flask_http_request_duration_seconds_bucket{job="ec2"}[10m])) by (le, status, method))
```

## Throughput
### Successful requests per second
```
sum(rate(flask_http_request_total{job="ec2",status=~"2.."}[3m]))
```

## Error Budget - Remaining Error Budget
### The error budget is 20%
```
1 - ((1 - (sum(increase(flask_http_request_total{job="ec2", status="200"}[7d])) by (status)) /  sum(increase(flask_http_request_total{job="ec2"}[7d])) by (status)) / (1 - .80))
```
