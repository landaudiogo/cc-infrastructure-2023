#! bash

set -euo pipefail

SECRET_NAME="database-init"

script=$(basename "$0")
script_d="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)"
decrypted_d="${script_d}/../.decrypted"


keys=(
    "init.sql"
)

for key in "${keys[@]}"; do
    agenix -d "$key.age" > "${decrypted_d}/$key"
done

sql="$(base64 -w 0 < "${decrypted_d}/init.sql")"

echo '{
    "apiVersion": "v1",
    "kind": "Secret",
    "metadata": {
        "name": "'"$SECRET_NAME"'"
    },
    "data": {
        "init.sql": "'"$sql"'"
    }
}' > "${decrypted_d}/$SECRET_NAME.json"
