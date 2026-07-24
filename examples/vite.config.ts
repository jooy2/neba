import { defineConfig } from 'vite';
import ReactPlugin from '@vitejs/plugin-react-swc';
import { dirname, resolve } from 'path';
import { fileURLToPath } from 'url';

const exampleDir = dirname(fileURLToPath(import.meta.url));

// The demo app is self-contained: `root` is pinned to this directory so the
// config can be invoked from the repository root (see the `demo:*` scripts).
export default defineConfig({
  root: exampleDir,
  base: './',
  publicDir: resolve(exampleDir, 'public'),
  resolve: {
    extensions: ['.mjs', '.js', '.ts', '.jsx', '.tsx', '.mts', '.json', '.scss'],
    alias: {
      // The library source, so demo edits hot-reload without a rebuild.
      '@/dist': resolve(exampleDir, '../src'),
      // The demo app's own source.
      '@/src': resolve(exampleDir, 'src')
    }
  },
  plugins: [ReactPlugin()]
});
