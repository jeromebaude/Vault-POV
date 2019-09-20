vault {
  renew_token = false
  vault_agent_token_file = "/home/vault/.vault-token"
  retry {
    backoff = "1s"
  }
  ssl {
    verify = false
  }
}

template {
  destination = "/etc/secrets/index.html"
  contents = <<EOH
  <html>
  <body>
  <p>Some secrets:</p>
  {{- with secret "kv_test/test" }}
  <ul>
  <li><pre>username: {{ .Data.username }}</pre></li>
  <li><pre>password: {{ .Data.password }}</pre></li>
  </ul>
  {{ end }}
  </body>
  </html>
  EOH
}
