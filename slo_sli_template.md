# API Service

| Category     | SLI                                                                                                              | SLO                                                                                                         |
|--------------|------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| Availability | (No. of successful requests) / (No. of total  requests )                                                | 99%                                                                                                         |
| Latency      | 90% of requests complete below 100ms | 90% of requests below 100ms                                                                                 |
| Error Budget | (No. of error requests) / (No. of total requests)                                                    | Error budget is defined at 20%. This means that 20% of the requests can fail and still be within the budget |
| Throughput   | No. of successful requests(200) per second                                                                       | 5 RPS indicates the application is functioning                                                              |
