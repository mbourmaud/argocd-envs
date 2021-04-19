local utils = import '../utils.libsonnet';

local namespace = 'dev';

local env = utils.get_env_variables(namespace, 'dev');

local apps = [
  {
    name: 'themes',
    replicas: 1,
    image: 'gitlab.insideboard.com:5000/ib/themes:1611b579f56c4d44f1e0d0501c4924c5e09ad7ce',
    service: true,
    deployment: true,
    mapping: true,
  },
  {
    name: 'languages',
    replicas: 3,
    image: 'gitlab.insideboard.com:5000/ib/languages:1611b579f56c4d44f1e0d0501c4924c5e09ad7ce',
    service: true,
    deployment: true,
    mapping: false,
  },
    {
    name: 'account-roles',
    replicas: 3,
    image: 'gitlab.insideboard.com:5000/ib/account-roles:1611b579f56c4d44f1e0d0501c4924c5e09ad7ce',
    service: true,
    deployment: true,
    mapping: true,
  },
];

local configs = [
  [
    if app.service then utils.create_service(namespace, app.name),
    if app.deployment then utils.create_deployment(namespace, app.name, app.replicas, app.image, env),
    if app.mapping then utils.create_mapping(namespace, app.name, app.name, std.strReplace('/apis/name/v1', 'name', app.name), '/api/v1'),
  ]
  for app in apps
];

std.flattenArrays(configs + [[utils.create_namespace(namespace)]])