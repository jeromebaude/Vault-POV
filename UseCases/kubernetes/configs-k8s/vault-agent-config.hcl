# Uncomment this to have Agent run once (e.g. when running as an initContainer)
exit_after_auth = true
pid_file = "/home/vault/pidfile"

vault {
    address = "https://54.198.199.29:8200"
    tls_skip_verify = "true"
}

auto_auth {
    method "kubernetes" {
        mount_path = "auth/kubernetes"
        config = {
            role = "example"
        }
    }

    sink "file" {
        config = {
            path = "/home/vault/.vault-token"
        }
    }
}
