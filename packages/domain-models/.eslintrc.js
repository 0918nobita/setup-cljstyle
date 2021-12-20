const eslint = require('@setup-cljstyle/config/eslint');

module.exports = {
    ...eslint.baseConfig,
    overrides: [eslint.setupTypeScript({ tsconfigRootDir: __dirname })],
};
