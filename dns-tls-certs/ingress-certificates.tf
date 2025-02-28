resource "kubectl_manifest" "aro_dns_cert_manager_ingress_certificates" {
  depends_on  = [ time_sleep.wait_for_api_certificates ]
  # provider    = kubernetes.managed_cluster

  yaml_body = <<YAML
    apiVersion: "cert-manager.io/v1"
    kind: "Certificate"
    metadata:
      name: "${local.cert_ocp_gen_ingress_secret_name}"
      namespace: "openshift-ingress"
    spec:
      duration: "${var.tls_certificates_ttl_seconds}"
      renewBefore: "360h"
      privateKey:
        algorithm: RSA
        size: 2048
      subject: 
        countries: [ "${var.dns_tls_certificates_subject.country}" ]
        localities: [ "${var.dns_tls_certificates_subject.locality}" ]
        organizationalUnits: [ "${var.dns_tls_certificates_subject.organizationalUnit}" ]
        organizations: [ "${var.dns_tls_certificates_subject.organization}" ]
        provinces: [ "${var.dns_tls_certificates_subject.province}" ]
        postalCodes: [ "${var.dns_tls_certificates_subject.postalCode}" ]
        streetAddresses: [ "${var.dns_tls_certificates_subject.streetAddresse}" ]
      uris: [ "${var.custom_dns_domain_name}", "*.apps.${var.custom_dns_domain_name}", "api.${var.custom_dns_domain_name}" ]
      commonName: "*.apps.${var.custom_dns_domain_name}"
      dnsNames:
        - "*.apps.${var.custom_dns_domain_name}"
      issuerRef:
        kind: "ClusterIssuer"
        name: "${local.cert_manager_cluster_issuer_cr_name}"
      secretName: "${local.cert_ocp_gen_ingress_secret_name}"
  YAML
  
  force_new       = true
  force_conflicts = true
  wait            = true
}

resource "kubectl_manifest" "patch_cluster_ingress_cert_sa" {
  depends_on  = [ kubectl_manifest.aro_dns_cert_manager_ingress_certificates ]
  # provider    = kubernetes.managed_cluster

  yaml_body = <<YAML
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: "patch-cluster-ingress-cert"
      namespace: "openshift-ingress"
  YAML

  force_new       = true
  force_conflicts = true
  wait            = true
}

resource "kubectl_manifest" "clusterrole_patch_cluster_ingress_cert" {
  depends_on = [ kubectl_manifest.patch_cluster_ingress_cert_sa ]
  # provider    = kubernetes.managed_cluster

  yaml_body = <<YAML
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: patch-cluster-ingress-cert
    rules:
      - apiGroups:
          - operator.openshift.io
        resources:
          - ingresscontrollers
        verbs:
          - get
          - list
          - patch
      - apiGroups:
          - ""
        resources:
          - secrets
        verbs:
          - get
          - list
  YAML

  force_new       = true
  force_conflicts = true
  wait            = true
}

resource "kubectl_manifest" "clusterrolebinding_patch_cluster_ingress_cert" {
  depends_on = [ kubectl_manifest.clusterrole_patch_cluster_ingress_cert ]
  # provider    = kubernetes.managed_cluster

  yaml_body = <<YAML
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: patch-cluster-ingress-cert
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: patch-cluster-ingress-cert
    subjects:
      - kind: ServiceAccount
        name: patch-cluster-ingress-cert
        namespace: openshift-ingress
  YAML

  force_new       = true
  force_conflicts = true
  wait            = true
}

resource "kubectl_manifest" "job_patch_cluster_ingress_cert" {
  depends_on = [ kubectl_manifest.clusterrolebinding_patch_cluster_ingress_cert ]
  # provider    = kubernetes.managed_cluster
  
  yaml_body = <<YAML
    apiVersion: "batch/v1"
    kind: "Job"
    metadata:
      annotations:
        "argocd.argoproj.io/hook": "PostSync"
        "argocd.argoproj.io/hook-delete-policy": "HookSucceeded"
      name: "patch-cluster-ingress-cert"
      namespace: "openshift-ingress"
    spec:
      template:
        spec:
          containers:
            - command:
                - /bin/bash
                - -c
                - |
                  #!/usr/bin/env bash
                  oc get secret "${local.cert_ocp_gen_ingress_secret_name}" -n openshift-ingress;
                  if [ "$?" = "0" ];
                  then
                    oc patch ingresscontroller default -n openshift-ingress-operator --type=merge --patch='{"spec": { "defaultCertificate": { "name": "${local.cert_ocp_gen_ingress_secret_name}" }}}'
                  else
                    echo "Could not execute sync as secret '${local.cert_ocp_gen_ingress_secret_name}' in namespace 'openshift-ingress' does not exist, check status of CertificationRequest"
                    exit 1
                  fi
              image: "image-registry.openshift-image-registry.svc:5000/openshift/cli:latest"
              name: "patch-cluster-ingress-cert"
          dnsPolicy: "ClusterFirst"
          restartPolicy: "Never"
          serviceAccount: "patch-cluster-ingress-cert"
          serviceAccountName: "patch-cluster-ingress-cert"
          terminationGracePeriodSeconds: 30
  YAML

  force_new       = true
  force_conflicts = true
  wait            = true
}
