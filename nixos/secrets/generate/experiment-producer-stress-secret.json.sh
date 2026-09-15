#! bash

set -euo pipefail

SECRET_NAME="experiment-producer-stress-secret"

script=$(basename "$0")
script_d="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)"
decrypted_d="${script_d}/../.decrypted"


keys=(
    "experiment-producer-stress.json"
)

for key in "${keys[@]}"; do
    agenix -d "$key.age" > "${decrypted_d}/$key"
done

config="$(base64 -w 0 < "${decrypted_d}/experiment-producer-stress.json")"

echo '{
    "apiVersion": "v1",
    "kind": "Secret",
    "metadata": {
        "name": "'"$SECRET_NAME"'"
    },
    "data": {
        "config.json": "'"$config"'"
    }
}' > "${decrypted_d}/$SECRET_NAME.json"
