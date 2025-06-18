# ngrok NixOS Service Documentation

[![Built with Starlight](https://astro.badg.es/v2/built-with-starlight/tiny.svg)](https://starlight.astro.build)

Comprehensive documentation for the ngrok NixOS service module, built with [Astro](https://astro.build/) and [Starlight](https://starlight.astro.build/).

## 🚀 Quick Start

### Prerequisites

- Node.js 18+
- npm or yarn

### Development

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Open http://localhost:4321
```

### Building

```bash
# Build for production
npm run build

# Preview production build
npm run preview
```

## 📝 Documentation Structure

The documentation is organized into several key sections:

### Getting Started
- **Introduction** - Overview and features
- **Quick Start** - 5-minute setup guide
- **Installation** - Detailed installation methods

### Configuration
- **Basic Configuration** - Fundamental setup patterns
- **Advanced Configuration** - Complex deployments and environments
- **Security Configuration** - Enterprise security features
- **Performance Tuning** - Optimization for production

### Authentication
- **HTTP Basic Auth** - Simple username/password authentication
- **OAuth Integration** - Google, GitHub, Microsoft, Facebook
- **OIDC Support** - Enterprise identity providers
- **Webhook Verification** - Secure webhook handling
- **Mutual TLS** - Client certificate authentication

### Examples
- **Basic Setup** - Simple configurations
- **Advanced Examples** - Multi-service deployments
- **OAuth Protected** - Authentication examples
- **Enterprise Setup** - Production-grade configurations

### Flake-Parts
- **Overview** - Modular configuration approach
- **Templates** - Pre-built project templates
- **Modules** - Custom module development
- **Usage Patterns** - Best practices

### Testing
- **VM Testing** - Cross-platform development
- **Cross-Platform** - Multi-architecture support
- **CI Integration** - Automated testing

### Deployment
- **Production Setup** - Enterprise deployment
- **Monitoring** - Observability and alerts
- **Security Hardening** - Production security
- **Troubleshooting** - Common issues and solutions

### Reference
- **Configuration Options** - Complete option reference
- **Service Management** - systemd service operations
- **CLI Commands** - Command-line tools
- **API Reference** - ngrok API integration

## 🎨 Features

### Enhanced Components

The documentation uses enhanced Starlight components:

- **Interactive Tabs** - Organize content by platform/method
- **Step-by-step Guides** - Numbered procedures
- **Code Snippets** - Syntax-highlighted examples
- **Callouts & Asides** - Important notes and tips
- **Badge System** - Status and feature indicators
- **Card Layouts** - Organized feature presentations
- **File Trees** - Directory structure visualization
- **Link Cards** - Enhanced navigation

### Custom Styling

- Responsive design for all screen sizes
- Dark/light theme support
- Enhanced accessibility features
- Print-friendly styles
- Custom animations and transitions

## 🔧 Development

### Scripts

```bash
# Development
npm run dev          # Start dev server
npm run build        # Production build
npm run preview      # Preview build

# Quality Assurance
npm run lint         # Lint code
npm run lint:fix     # Fix linting issues
npm run format       # Format code
npm run format:check # Check formatting
npm run typecheck    # Type checking
```

### File Structure

```
docs/
├── src/
│   ├── content/
│   │   └── docs/           # Documentation pages
│   │       ├── index.mdx       # Homepage
│   │       ├── quick-start.mdx # Quick start guide
│   │       ├── config/         # Configuration guides
│   │       ├── auth/           # Authentication guides
│   │       ├── examples/       # Example configurations
│   │       ├── flake-parts/    # Flake-parts documentation
│   │       ├── testing/        # Testing guides
│   │       ├── deployment/     # Deployment guides
│   │       └── reference/      # Reference documentation
│   └── styles/
│       └── custom.css      # Custom styling
├── astro.config.mjs        # Astro configuration
├── package.json            # Dependencies and scripts
├── tsconfig.json           # TypeScript configuration
├── .eslintrc.js            # ESLint configuration
├── .prettierrc             # Prettier configuration
└── .github/
    └── workflows/
        └── deploy.yml      # GitHub Pages deployment
```

## 🚀 Deployment

### GitHub Pages

The documentation is automatically deployed to GitHub Pages:

1. **Push to main** - Triggers deployment workflow
2. **Build process** - Linting, type checking, building
3. **Deploy** - Automatic deployment to GitHub Pages
4. **Preview** - Available at your GitHub Pages URL

## 🧞 Commands

All commands are run from the docs directory:

| Command                   | Action                                           |
| :------------------------ | :----------------------------------------------- |
| `npm install`             | Installs dependencies                            |
| `npm run dev`             | Starts local dev server at `localhost:4321`      |
| `npm run build`           | Build your production site to `./dist/`          |
| `npm run preview`         | Preview your build locally, before deploying     |
| `npm run lint`            | Lint code with ESLint                           |
| `npm run format`          | Format code with Prettier                       |
| `npm run typecheck`       | Run TypeScript type checking                    |

## 👀 Want to learn more?

- [Astro Documentation](https://docs.astro.build/)
- [Starlight Documentation](https://starlight.astro.build/)
- [ngrok Documentation](https://ngrok.com/docs)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)