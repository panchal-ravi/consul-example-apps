### Deploy frontend, backend and service-intention
kaf ~/learn/consul/examples/applications/resiliency/circuit-breaker/proxy-defaults.yml
kaf ~/learn/consul/examples/applications/resiliency/circuit-breaker/frontend.yml
kaf ~/learn/consul/examples/applications/resiliency/circuit-breaker/backend-v1.yml  
kaf ~/learn/consul/examples/applications/resiliency/circuit-breaker/backend-v2.yml  
kaf ~/learn/consul/examples/applications/resiliency/circuit-breaker/service-intentions.yml  


### Test backend response without circuit-breaker
while true; do kubectl exec -i $(kubectl get pod -l app=frontend -oname) -c frontend -- curl -s localhost:9090 | jq '.upstream_calls[] | "\(.name), \(.code)"' -r; sleep 1; done

### Apply circuit-breaker
kaf ~/learn/consul/examples/applications/resiliency/circuit-breaker/frontend-service-defaults.yml  


### Delete services and configuration
kdelf ~/learn/consul/examples/applications/resiliency/circuit-breaker/backend-service-router.yml  
kdelf ~/learn/consul/examples/applications/resiliency/circuit-breaker/frontend-service-defaults.yml  
kdelf ~/learn/consul/examples/applications/resiliency/circuit-breaker/service-intentions.yml  
kdelf ~/learn/consul/examples/applications/resiliency/circuit-breaker/frontend.yml
kdelf ~/learn/consul/examples/applications/resiliency/circuit-breaker/backend-v1.yml  
kdelf ~/learn/consul/examples/applications/resiliency/circuit-breaker/backend-v2.yml  
kdelf ~/learn/consul/examples/applications/resiliency/circuit-breaker/proxy-defaults.yml

