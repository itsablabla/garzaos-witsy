import { fileURLToPath } from 'node:url';
import fs from 'node:fs';
import path from 'node:path';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export default {
  root: __dirname,
  mode: 'production',
  base: './',
  build: {
    outDir: '.vite/renderer/main_window',
    rollupOptions: {
      input: {
        index: path.resolve(__dirname, 'index.web.html'),
      },
    },
  },
  resolve: {
    alias: {
      '@assets': path.resolve(__dirname, 'assets'),
      '@css': path.resolve(__dirname, 'css'),
      '@root': path.resolve(__dirname, './'),
    },
  },
  plugins: [
    {
      name: 'rename-web-index',
      closeBundle() {
        fs.renameSync(
          path.resolve(__dirname, '.vite/renderer/main_window/index.web.html'),
          path.resolve(__dirname, '.vite/renderer/main_window/index.html'),
        );
      },
    },
  ],
  clearScreen: false,
};
