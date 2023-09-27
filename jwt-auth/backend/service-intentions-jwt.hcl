Kind = "service-intentions"
Name = "backend"
Sources = [
  {
    Name = "frontend"
    Permissions = [
      {
        Action = "allow"
        HTTP = {
          PathPrefix = "/health"
        }
        JWT = {
          Providers = [
            {
              Name = "auth0"
              VerifyClaims = [
                {
                  Path = ["name"]
                  Value = "admin"
                }
              ]
            }
          ]
        }
      }
    ]
  }
]
