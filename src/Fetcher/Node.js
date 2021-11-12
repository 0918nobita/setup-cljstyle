const fetch = require('node-fetch');

exports._getTextImpl =
  ({ url, authorization }) => (onError, onSuccess) => {
    fetch(url, { headers: { Authorization: authorization } })
      .then((res) =>
        res
          .text()
          .then((text) => onSuccess(text))
          .catch((err) => onError(err)))
      .catch((err) => onError(err));
  };
