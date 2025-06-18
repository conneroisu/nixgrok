// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	integrations: [
		starlight({
			title: 'ngrok NixOS Service',
			description: 'Comprehensive documentation for the ngrok NixOS service module',
			social: { 
				github: 'https://github.com/yourusername/nixgrok',
			},
			logo: {
				src: './src/assets/logo.svg',
			},
			customCss: [
				'./src/styles/custom.css',
			],
			sidebar: [
				{
					label: 'Getting Started',
					items: [
						{ label: 'Introduction', slug: 'introduction' },
						{ label: 'Quick Start', slug: 'quick-start' },
						{ label: 'Installation', slug: 'installation' },
					],
				},
				{
					label: 'Configuration',
					items: [
						{ label: 'Basic Configuration', slug: 'config/basic' },
						{ label: 'Advanced Configuration', slug: 'config/advanced' },
						{ label: 'Security Options', slug: 'config/security' },
						{ label: 'Performance Tuning', slug: 'config/performance' },
					],
				},
				{
					label: 'Authentication',
					items: [
						{ label: 'HTTP Basic Auth', slug: 'auth/basic' },
						{ label: 'OAuth Integration', slug: 'auth/oauth' },
						{ label: 'OIDC Support', slug: 'auth/oidc' },
						{ label: 'Webhook Verification', slug: 'auth/webhooks' },
						{ label: 'Mutual TLS', slug: 'auth/mtls' },
					],
				},
				{
					label: 'Examples',
					items: [
						{ label: 'Basic Setup', slug: 'examples/basic' },
						{ label: 'Multi-Service', slug: 'examples/advanced' },
						{ label: 'OAuth Protected', slug: 'examples/oauth' },
						{ label: 'Enterprise Setup', slug: 'examples/enterprise' },
					],
				},
				{
					label: 'Flake-Parts',
					items: [
						{ label: 'Overview', slug: 'flake-parts/overview' },
						{ label: 'Templates', slug: 'flake-parts/templates' },
						{ label: 'Modules', slug: 'flake-parts/modules' },
						{ label: 'Usage Patterns', slug: 'flake-parts/usage' },
					],
				},
				{
					label: 'Testing',
					items: [
						{ label: 'VM Testing', slug: 'testing/vm' },
						{ label: 'Cross-Platform', slug: 'testing/cross-platform' },
						{ label: 'Continuous Integration', slug: 'testing/ci' },
					],
				},
				{
					label: 'Deployment',
					items: [
						{ label: 'Production Setup', slug: 'deployment/production' },
						{ label: 'Monitoring', slug: 'deployment/monitoring' },
						{ label: 'Security Hardening', slug: 'deployment/security' },
						{ label: 'Troubleshooting', slug: 'deployment/troubleshooting' },
					],
				},
				{
					label: 'Reference',
					items: [
						{ label: 'Configuration Options', slug: 'reference/options' },
						{ label: 'Service Management', slug: 'reference/services' },
						{ label: 'CLI Commands', slug: 'reference/cli' },
						{ label: 'API Reference', slug: 'reference/api' },
					],
				},
			],
		}),
	],
});
