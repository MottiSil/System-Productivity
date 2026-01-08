module.exports = {
  apps: [{
    name: 'system-productivity-app',
    script: 'npm',
    args: 'run preview',
    // Note: For better performance, consider using 'serve' directly:
    // script: 'serve',
    // args: '-s dist -l 3000 --host 0.0.0.0',
    // This requires 'serve' to be installed: npm install -g serve
    env: {
      NODE_ENV: 'production',
      PORT: 3000,
      HOST: '0.0.0.0'
    },
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true
  }]
};
