const esbuild = require('esbuild');

esbuild.build({
    entryPoints: ['src/bootstrap.js'],
    bundle: true,
    minify: true,
    outfile: 'dist/setup-cljstyle.js',
    platform: 'node',
}).catch((e) => {
    console.error(e);
    process.exit(1);
});
