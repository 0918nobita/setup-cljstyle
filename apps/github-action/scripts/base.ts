import * as path from 'path';
import type { BuildOptions } from 'esbuild';

export const baseBuildOptions: BuildOptions = {
    platform: 'node',
    target: 'node12',
    bundle: true,
    minify: true,
    entryPoints: [path.join(__dirname, '..', 'src', 'main.ts')],
    outfile: path.join(__dirname, '..', 'dist', 'bundle.js'),
};
