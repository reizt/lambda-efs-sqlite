import { Hono } from 'hono';

export function createApp() {
	const app = new Hono();

	app.get('/', async (c) => {
		c.text('Hello World');
	});

	return app;
}
