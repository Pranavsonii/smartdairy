// ecosystem.config.js (ESM version)
export default {
  apps: [
    {
      name: 'milk-api',
      script: 'index.js',
      watch: true,
      ignore_watch: ['node_modules', 'uploads', 'public/uploads'],
      env: {
        NODE_ENV: 'development',
        PORT: 3005
      },
      env_production: {
        NODE_ENV: 'production',
        PORT: 3005
      }
    }
  ]
};
