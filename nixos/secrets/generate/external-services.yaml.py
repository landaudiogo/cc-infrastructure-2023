import subprocess
import json
import re

from jinja2 import Template

TEMPLATE=Template('''
---
apiVersion: v1
kind: Service
metadata:
  name: {{ host }}
spec:
  ports:
    - name: api
      protocol: TCP
      port: 3003
      targetPort: 3003
    - name: prometheus
      protocol: TCP
      port: 3008
      targetPort: 3008
---
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: {{ host }} # by convention, use the name of the Service
                # as a prefix for the name of the EndpointSlice
  labels:
    # You should set the "kubernetes.io/service-name" label.
    # Set its value to match the name of the Service
    kubernetes.io/service-name: {{ host }}
addressType: IPv4
ports:
  - name: api # should match with the name of the service port defined above
    protocol: TCP
    port: 3003
  - name: prometheus # should match with the name of the service port defined above
    protocol: TCP
    port: 3008
endpoints:
  - addresses:
      - "{{ ipv4address }}"
''')

credentials = subprocess.run(
    ["agenix", "-d", "groups.json.age"],
    capture_output=True,
    check=True
)
credentials = json.loads(credentials.stdout)

manifest = TEMPLATE.render({"host": "landau", "ipv4address": "63.34.236.235"})
for cred in credentials:
    seq = int(re.match(r"^group-(\d+)", cred["instance_name"]).groups()[0])
    host = f"group{seq}"
    manifest += TEMPLATE.render({"host": host, "ipv4address": cred["public_ip"]})

print(manifest)
