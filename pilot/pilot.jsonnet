local utils = import '../utils.libsonnet';

local namespace = 'pilot';

local env = utils.get_env_variables(namespace, 'pilot');
[
  utils.create_namespace(namespace),
  utils.create_deployment(
    namespace,
    'mongo-express',
    5,
    'mongo-express',
    env,
  ),
  utils.create_service(
    namespace,
    'mongo-express',
    'ClusterIP',
    ['http', 'grpc'],
  ),
  utils.create_deployment(
    namespace,
    'cp-kafka',
    1,
    'confluentinc/cp-kafka',
    env,
  ),
  utils.create_service(
    namespace,
    'cp-kafka',
  ),
]