# Trivy Kubernetes Policy - Allow GitHub Container Registry (ghcr.io)
# This overrides the default KSV-0125 check to include ghcr.io as trusted

package builtin.kubernetes.KSV0125

import data.lib.kubernetes

default deny = false

# Allow images from ghcr.io (GitHub Container Registry)
allowed_registries := [
    "gcr.io",
    "us.gcr.io",
    "asia.gcr.io",
    "eu.gcr.io",
    "mirror.gcr.io",
    "docker.io",
    "registry.hub.docker.com",
    "public.ecr.aws",
    "dockerhub.io",
    "ghcr.io",  # GitHub Container Registry
    "mcr.microsoft.com",  # Microsoft Container Registry
    "container-registry.oracle.com",  # Oracle Container Registry
]

deny {
    input.kind == "Deployment"
    input.spec.template.spec.containers[_].image
    not registry_allowed(input.spec.template.spec.containers[_].image)
    input.spec.template.spec.containers[_].name
}

registry_allowed(image) {
    registry := split(image, "/")[0]
    allowed_registries[_] = registry
}

registry_allowed(image) {
    endswith(image, ":latest") == false
    contains(image, "sha256:")
}