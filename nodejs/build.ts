import { build } from 'esbuild';

await build({
	entryPoints: ['src/lambda.ts'],
	bundle: true,
	platform: 'node',
	target: 'node20',
	outfile: 'dist/lambda.js',
});
