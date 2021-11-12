const https = require('https');

exports._getTextImpl =
  ({ url, authorization }) => (onError, onSuccess) => {
    https.get(
      url,
      {
        headers: {
          Authorization: authorization,
          'User-Agent': 'Node.js',
        },
      },
      (res) => {
        res.on('error', (err) => onError(err));

        let data = '';

        res.on('data', (chunk) => {
          data += chunk;
        });

        res.on('end', () => onSuccess(data));
      }
    );
  };
