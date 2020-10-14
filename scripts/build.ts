import { build } from 'esbuild';

build({
    platform: 'node',
    entryPoints: ['./src/index.ts'],
    outfile: './dist/setup-cljstyle.js',
    bundle: true,
    minify: true,
    tsconfig: './tsconfig.json',
    color: true,
    logLevel: 'error',
});
