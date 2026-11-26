import DefaultTheme from 'vitepress/theme';
import Layout from './components/Layout.vue';
import Demo from './components/Demo.vue';
import PropsTable from './components/PropsTable.vue';
import Fw from './components/Fw.vue';
import { syncFramework } from '../data/framework';
import './styles/index.css';
import './custom.css';

export default {
  extends: DefaultTheme,
  // Adds the live hero to the home page, and the framework switch to every
  // other; everything else is the default theme.
  Layout,
  enhanceApp({ app }) {
    // All three are used straight from Markdown, so they are registered
    // globally rather than imported page by page.
    app.component('Demo', Demo);
    app.component('PropsTable', PropsTable);
    app.component('Fw', Fw);
    // Before hydration, so every component that reads the framework starts
    // from the reader's choice rather than the default.
    syncFramework();
  }
};
