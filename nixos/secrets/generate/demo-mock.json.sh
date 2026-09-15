#! bash

set -euo pipefail

SECRET_NAME="demo-mock"

script=$(basename "$0")
script_d="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)"
decrypted_d="${script_d}/../.decrypted"


keys=(
    "database-secret.json"
)

for key in "${keys[@]}"; do
    agenix -d "$key.age" > "${decrypted_d}/$key"
done

key="$(head -c 16 /dev/urandom | od -An -t x | tr -d '[:space:]' | base64)"
postgres_password="$(jq -r '.data.POSTGRES_PASSWORD' < "${decrypted_d}/database-secret.json"  | base64 -d)"
database_url="$(printf "postgres://cec:$postgres_password@postgres:5432/cec" | base64 -w 0)"

echo '{
    "apiVersion": "v1",
    "kind": "Secret",
    "metadata": {
        "name": "'"$SECRET_NAME"'"
    },
    "data": {
        "SECRET_KEY": "'"$key"'",
        "DATABASE_URL": "'"$database_url"'"
    }
}' > "${decrypted_d}/$SECRET_NAME.json"
