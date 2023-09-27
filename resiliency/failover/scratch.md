### Deploy frontend, backend and service-intention
kaf ~/learn/consul/examples/applications/resiliency/failover/proxy-defaults.yml
kaf ~/learn/consul/examples/applications/resiliency/failover/frontend.yml
kaf ~/learn/consul/examples/applications/resiliency/failover/backend-v1.yml  
kaf ~/learn/consul/examples/applications/resiliency/failover/backend-v2.yml  
kaf ~/learn/consul/examples/applications/resiliency/failover/backend-service-resolver.yml  
kaf ~/learn/consul/examples/applications/resiliency/failover/service-intentions.yml  


### Test backend-v2 response, all requests should be handled by backend-v2
while true; do kubectl exec -i $(kubectl get pod -l app=frontend -oname) -c frontend -- curl -s localhost:9090 | jq '.upstream_calls[] | "\(.name), \(.code)"' -r; sleep 1; done

### Update 'ERROR_RATE' to 1 in backend-v2.yml and apply changes
kaf ~/learn/consul/examples/applications/resiliency/failover/backend-v2.yml  

### Test backend-v2 response, Consul should automatically failover to v1 subset after first few errors.
while true; do kubectl exec -i $(kubectl get pod -l app=frontend -oname) -c frontend -- curl -s localhost:9090 | jq '.upstream_calls[] | "\(.name), \(.code)"' -r; sleep 1; done

### Change 'ERROR_RATE' back to 0 in backend-v2.yml and apply changes
kaf ~/learn/consul/examples/applications/resiliency/failover/backend-v2.yml  

### Test backend-v2 response, all requests should be handled by backend-v2
while true; do kubectl exec -i $(kubectl get pod -l app=frontend -oname) -c frontend -- curl -s localhost:9090 | jq '.upstream_calls[] | "\(.name), \(.code)"' -r; sleep 1; done

### Now remove all pods of backend-v2
k scale deployment backend-v2 --replicas 0

### Test backend-v2 response, Consul should automatically failover to v1 subset after first few errors.
while true; do kubectl exec -i $(kubectl get pod -l app=frontend -oname) -c frontend -- curl -s localhost:9090 | jq '.upstream_calls[] | "\(.name), \(.code)"' -r; sleep 1; done

### Delete services and configuration
kdelf ~/learn/consul/examples/applications/resiliency/failover/backend-service-resolver.yml  
kdelf ~/learn/consul/examples/applications/resiliency/failover/service-intentions.yml  
kdelf ~/learn/consul/examples/applications/resiliency/failover/frontend.yml
kdelf ~/learn/consul/examples/applications/resiliency/failover/backend-v1.yml  
kdelf ~/learn/consul/examples/applications/resiliency/failover/backend-v2.yml  
kdelf ~/learn/consul/examples/applications/resiliency/failover/proxy-defaults.yml

