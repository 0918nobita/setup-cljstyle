module.exports = {
    baseConfig: {
        root: true,
        env: {
            es6: true,
            node: true,
        },
        parserOptions: {
            ecmaVersion: 2018,
            sourceType: 'module',
        },
        ignorePatterns: ['dist'],
        extends: ['eslint:recommended', 'prettier'],
    },
    setupTypeScript: ({ tsconfigRootDir }) => ({
        files: ['*.ts'],
        parser: '@typescript-eslint/parser',
        parserOptions: {
            tsconfigRootDir,
            project: ['./tsconfig.json'],
        },
        plugins: ['@typescript-eslint'],
        extends: [
            'plugin:@typescript-eslint/recommended',
            'plugin:@typescript-eslint/recommended-requiring-type-checking',
        ],
    }),
};
