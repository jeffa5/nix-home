{...}:{
  services.prometheus.ruleFiles = [
    ./alerts/prometheus.yaml
    ./alerts/node-exporter.yaml
    ./alerts/restic.yaml
  ];
}
