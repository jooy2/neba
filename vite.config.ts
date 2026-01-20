import { defineConfig } from 'vite';
import ReactPlugin from '@vitejs/plugin-react-swc';
import { dirname, resolve } from 'path';
import { fileURLToPath } from 'url';

console.log(resolve(dirname(fileURLToPath(import.meta.url)), 'src'));

export default defineConfig({
  resolve: {
    extensions: ['.mjs', '.js', '.ts', '.jsx', '.tsx', '.mts', '.json', '.scss'],
    alias: {
      '@/dist': resolve(dirname(fileURLToPath(import.meta.url)), 'src'),
      '@/src': resolve(dirname(fileURLToPath(import.meta.url)), 'examples/src')
    }
  },
  base: './',
  root: resolve('./examples'),
  publicDir: resolve('./src/examples/public'),
  plugins: [ReactPlugin()]
});
