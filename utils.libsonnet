{
  create_deployment(namespace, name, replicas, image, env)::
    {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      metadata: {
        namespace: namespace,
        name: name,
        labels: {
          app: name,
        },
      },
      spec: {
        replicas: replicas,
        selector: {
          matchLabels: {
            app: name,
          },
        },
        strategy: {
          type: 'RollingUpdate',
          rollingUpdate: {
            maxSurge: 1,
            maxUnavailable: 0,
          },
        },
        template: {
          metadata: {
            labels: {
              app: name,
              environment: namespace,
            },
            annotations: {
              'prometheus.io/scrape': 'true',
            },
          },
          spec: {
            imagePullSecrets: [
              {
                name: 'k8s-gitlab-registry',
              },
            ],
            containers: [
              {
                name: name,
                image: image,
                ports: [
                  {
                    name: 'http',
                    containerPort: 8080,
                  },
                ],
                livenessProbe: {
                  httpGet: {
                    path: '/status',
                    port: 'http',
                  },
                },
                readinessProbe: {
                  httpGet: {
                    path: '/status',
                    port: 'http',
                  },
                },
                env: env,
              },
            ],
          },
        },
      },
    },

  create_mapping(namespace, name, service, prefix, rewrite, bypass_auth=false)::
    {
      apiVersion: 'getambassador.io/v1',
      kind: 'Mapping',
      metadata: {
        namespace: namespace,
        name: name,
        labels: {
          app: name,
        },
      },
      spec: {
        prefix: prefix,
        service: service,
        rewrite: rewrite,
        bypass_auth: bypass_auth,
      },
    },

  create_service(namespace, name, type = 'ClusterIP', protocols=['http'])::
    {
      local ports = [
        if protocol == 'http' then {
            name: 'http',
            protocol: 'TCP',
            port: 80,
            targetPort: 'http'
        } else if protocol == 'grpc' then {
            name: 'grpc',
            protocol: 'TCP',
            port: 50051,
            targetPort: 50051
        },
        for protocol in protocols
      ],

      apiVersion: 'v1',
      kind: 'Service',
      metadata: {
        namespace: namespace,
        name: name,
        labels: {
          app: name,
        },
      },
      spec: {
        ports: ports
      },
    },

  create_namespace(namespace)::
  {
    apiVersion: 'v1',
    kind: 'Namespace',
    metadata: {
      name: namespace
    },
  },

  get_env_variables(namespace, env)::
    [
      {
        name: 'HOST',
        value: '0.0.0.0',
      },
      {
        name: 'PORT',
        value: '5000',
      },
      {
        name: 'DB_URL_TEMPLATE',
        value: std.strReplace('mongodb://mongo-primary-environment-{{customer}}.service.azr-environment-francecentral.consul,mongo-secondary-environment-{{customer}}.service.azr-environment-francecentral.consul:27017/?replicaSet=insideboard_environment', 'environment', env),
      },
      {
        name: 'DB_NAME_TEMPLATE',
        value: std.strReplace(std.strReplace('{{customer}}_environment_namespace_db', 'environment', env), 'namespace', namespace),
      },
      {
        name: 'ENVIRONMENT',
        value: namespace,
      },
      {
        name: 'NODE_ENV',
        value: 'production',
      },
      {
        name: 'AUTH_JWKS_URL',
        value: std.strReplace('http://auth.namespace:80/.well-known/jwks.json', 'namespace', namespace),
      },
      {
        name: 'BYPASS_AUTH',
        value: 'false',
      },
      {
        name: 'KAFKA_BROKER',
        value: std.strReplace('cp-kafka-environment-headless.environment:9092', 'environment', env),
      },
      {
        name: 'KAFKA_PREFIX',
        value: std.strReplace('namespace_', 'namespace', namespace)
      },
    ],

}
