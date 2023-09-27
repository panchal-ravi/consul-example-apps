### Deploy frontend and backend services
kaf ~/learn/consul/examples/applications/jwt-auth/proxy-defaults.yml
kaf ~/learn/consul/examples/applications/jwt-auth/frontend/frontend.yml
kaf ~/learn/consul/examples/applications/jwt-auth/backend/backend.yml  

### Add jwt-auth ACL policy to the backend service-identity ACL token 
kaf ~/learn/consul/examples/applications/jwt-auth/jwt-provider-local.yml
# OR #Below does not work at the moment
kaf ~/learn/consul/examples/applications/jwt-auth/jwt-provider-remote.yml

kaf ~/learn/consul/examples/applications/jwt-auth/backend/service-intentions-jwt.yml
 
### Change logging level of backend pod
k exec -i $(kubectl get pod -l app=backend -oname) -- curl -s -X POST localhost:19000/logging\?level=debug
k exec -i $(kubectl get pod -l app=backend -oname) -- curl -s -X POST localhost:19000/logging\?jwt=trace
k exec -i $(kubectl get pod -l app=backend -oname) -- curl -s -X POST localhost:19000/logging\?rbac=trace
k exec -i $(kubectl get pod -l app=backend -oname) -- curl -s -X POST localhost:19000/logging\?filter=trace

### Generated JWT Token
export CLIENT_ID=$(terraform output -json auth0_client | jq .client_id -r)
export CLIENT_SECRET=$(terraform output -json auth0_client | jq .client_secret -r)
export TOKEN=$(curl -s -X POST https://dev-qn4ll0wqf1jbzac8.us.auth0.com/oauth/token \
  --header "content-type: application/x-www-form-urlencoded" \
  --data grant_type=password \
  --data username=analyst@demo.com \
  --data password=HashiCorp1! \
  --data scope=openid read:sample \
  --data client_id=$CLIENT_ID \
  --data client_secret=$CLIENT_SECRET | jq .id_token -r)

  --data 'audience=1yvQlCKXVucSwUmyouCXXvNqK1adRZNi' 


### Verify /health endpoint should require valid JWT token
k exec -i  $(kubectl get pod -l app=frontend -oname) -c frontend -- curl -s  http://240.0.0.2/health
k exec -i  $(kubectl get pod -l app=frontend -oname) -c frontend -- curl -s -H "Authorization: Bearer $TOKEN"  http://240.0.0.2/health


### Verify / endpoint should NOT require a JWT token
k exec -i $(kubectl get pod -l app=frontend -oname) -c frontend -- curl -s http://240.0.0.2


### Delete resources
kdelf ~/learn/consul/examples/applications/jwt-auth/backend/service-intentions-jwt.yml
kdelf ~/learn/consul/examples/applications/jwt-auth/jwt-provider-local.yml
kdelf ~/learn/consul/examples/applications/jwt-auth/jwt-provider-remote.yml
kdelf ~/learn/consul/examples/applications/jwt-auth/proxy-defaults.yml
kdelf ~/learn/consul/examples/applications/jwt-auth/frontend/frontend.yml
kdelf ~/learn/consul/examples/applications/jwt-auth/backend/backend.yml

tfd -auto-approve