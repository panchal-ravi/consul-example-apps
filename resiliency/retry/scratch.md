### Deploy frontend, backend and service-intention
kaf ~/learn/consul/examples/applications/resiliency/retry/proxy-defaults.yml
kaf ~/learn/consul/examples/applications/resiliency/retry/frontend.yml
kaf ~/learn/consul/examples/applications/resiliency/retry/backend.yml  
kaf ~/learn/consul/examples/applications/resiliency/retry/service-intentions.yml  


### Test backend response without retry
while true; do kubectl exec -i $(kubectl get pod -l app=frontend -oname) -c frontend -- curl -s localhost:9090 | jq '.upstream_calls[] | "\(.name), \(.code)"' -r; sleep 1; done

### Apply retry
kaf ~/learn/consul/examples/applications/resiliency/retry/backend-service-router.yml  


### Delete services and configuration
kdelf ~/learn/consul/examples/applications/resiliency/retry/backend-service-router.yml  
kdelf ~/learn/consul/examples/applications/resiliency/retry/service-intentions.yml  
kdelf ~/learn/consul/examples/applications/resiliency/retry/frontend.yml
kdelf ~/learn/consul/examples/applications/resiliency/retry/backend.yml  
kdelf ~/learn/consul/examples/applications/resiliency/retry/proxy-defaults.yml

