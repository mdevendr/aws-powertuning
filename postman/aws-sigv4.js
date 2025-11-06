const aws4 = require('aws4');

pm.request = aws4.sign(pm.request, {
  accessKeyId: pm.environment.get('awsAccessKeyId'),
  secretAccessKey: pm.environment.get('awsSecretAccessKey'),
  sessionToken: pm.environment.get('awsSessionToken'),
  service: 'execute-api',
  region: 'eu-west-2'
});
