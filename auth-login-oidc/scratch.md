export CONSUL_HTTP_ADDR=https://$(kubectl get service -n consul consul-ui -ojson | jq ".status.loadBalancer.ingress[].ip" -r)
export CONSUL_HTTP_TOKEN=$(kubectl get secret -n consul consul-bootstrap-acl-token -ojson | jq .data.token -r | base64 -d)
export CONSUL_CACERT=./ca.crt


consul acl policy create -name eng-ro \
   -rules='service_prefix "" { policy="read" } node_prefix "" { policy="read" }' -ca-file ./ca.crt

consul acl role create -name eng-ro -policy-name eng-ro -ca-file ./ca.crt


consul acl auth-method create -type oidc \
    -name auth0 \
    -max-token-ttl=5m \
    -config=@./examples/login/auth-method-config.json -ca-file ./ca.crt


consul acl binding-rule create \
    -method=auth0 \
    -bind-type=role \
    -bind-name=eng-ro \
    -selector='engineering in list.groups' -ca-file ./ca.crt

consul login -method=auth0 -type=oidc -token-sink-file=dev.token

consul acl token read -self -token-file=dev.token

CONSUL_HTTP_TOKEN=0522fdea-8829-c706-3b8d-cc93470af818 consul kv put version=1.14




### JWT Token
export TOKEN=$(curl -s -X POST https://dev-qn4ll0wqf1jbzac8.us.auth0.com/oauth/token \
  --header 'content-type: application/x-www-form-urlencoded' \
  --data grant_type=password \
  --data 'username=analyst@demo.com' \
  --data 'password=HashiCorp1!' \
  --data scope=openid read:sample \
  --data 'client_id=c9qm6CLRhWK0TXYMlg2npZ5RKyRpXEZa' \
  --data 'client_secret=iBIKJ7DOmdMYBUt7izLsCRYssr42gRHZzhzPj-LK5BdtgTFHeTBwv41qUClnlEto' | jq .id_token -r)

  --data 'audience=1yvQlCKXVucSwUmyouCXXvNqK1adRZNi' 

ID_Token: eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6InNaYVVhR2NyU0h6QVRaT2ptYmNndyJ9.eyJodHRwOi8vY29uc3VsLmludGVybmFsL2ZpcnN0X25hbWUiOiJSYXZpIiwiaHR0cDovL2NvbnN1bC5pbnRlcm5hbC9sYXN0X25hbWUiOiJQYW5jaGFsIiwiaHR0cDovL2NvbnN1bC5pbnRlcm5hbC9ncm91cHMiOlsiZW5naW5lZXJpbmciXSwib3JnLXJvbGVzIjpbImFuYWx5c3QiXSwibmlja25hbWUiOiJhbmFseXN0IiwibmFtZSI6ImFuYWx5c3QiLCJwaWN0dXJlIjoiaHR0cHM6Ly9zLmdyYXZhdGFyLmNvbS9hdmF0YXIvYWRhYjk2Mzc1ZmU5N2E4ZGYzMGYyYWQ2MjlkYTExMTY_cz00ODAmcj1wZyZkPWh0dHBzJTNBJTJGJTJGY2RuLmF1dGgwLmNvbSUyRmF2YXRhcnMlMkZhbi5wbmciLCJ1cGRhdGVkX2F0IjoiMjAyMy0wMS0xMVQwMjowMjowMS41OTlaIiwiZW1haWwiOiJhbmFseXN0QGRlbW8uY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImlzcyI6Imh0dHBzOi8vZGV2LXFuNGxsMHdxZjFqYnphYzgudXMuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYzYjM5YjQzZjcxZjRjNThlZGZhMTRiMSIsImF1ZCI6IjF5dlFsQ0tYVnVjU3dVbXlvdUNYWHZOcUsxYWRSWk5pIiwiaWF0IjoxNjczNDAyNTIxLCJleHAiOjE2NzM0Mzg1MjF9.OFnyebv46JVr2r6NoxDz3DqeUUjFPt_JLnV2Y9_tN8EEi1A0bTT2oK9WpoRmQmJjF_p_GF26xJScwuxADmvnSq3zfKVgzgNMBZgF0xzcjq5PcQnfx9I-HnXSbXZziq_HpdLLNh4idP576w6-vSk41NUSeRUar5ZF1kdjaSnLTRWMFWZ3kuP0sVenXDiJZ4mkPM1nk2NMohkF7YYdkQax8ZoiYjC9FLn7uVFj3q4uq5wy9Ir17Iyub1AJ65WH16Ou3Do8XTmgoWFW5hBcnrrLvd7_cx5QU794aHQXXIpliiHN43IXoW-g7HxMiOp-MqJKOWoXgtk7SuTbLdkvIVP7OA


consul acl auth-method create -type jwt \
    -name auth0-jwt \
    -max-token-ttl=5m \
    -config=@./examples/login/jwt-auth-method-config.json -ca-file ./ca.crt


consul acl binding-rule create \
    -method=auth0-jwt \
    -bind-type=role \
    -bind-name=eng-ro \
    -selector='engineering in list.groups'

consul login -method=auth0-jwt -type=jwt -token-sink-file=dev-jwt.token -bearer-token-file=./jwt.token

https://dev-qn4ll0wqf1jbzac8.us.auth0.com/.well-known/jwks.json




kdelf ~/learn/consul/examples/applications/jwt-auth/backend/service-intentions-jwt.yml
kdelf ~/learn/consul/examples/applications/jwt-auth/jwt-provider-local.yml
kdelf ~/learn/consul/examples/applications/jwt-auth/proxy-defaults.yml
kdelf ~/learn/consul/examples/applications/jwt-auth/frontend/frontend.yml
kdelf ~/learn/consul/examples/applications/jwt-auth/backend/backend.yml