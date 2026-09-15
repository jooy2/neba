import{j as e}from"./jsx-runtime.BjG_zV1W.js";import{C as r}from"./CodeBlock.BN1ib7AN.js";import"./index.BC-ZOPMe.js";import"./icons.C4HwxOCh.js";import"./i18n.CNb1bbqZ.js";import"./cache.DjsaJSNf.js";import"./observe.D2XLDznJ.js";import"./framework.CKd2nDfM.js";import"./styles.BhE9daFN.js";import"./defaults.D04ek_WJ.js";const t=`import { createServer } from 'node:http';

const server = createServer((request, response) => {
  response.writeHead(200, { 'content-type': 'application/json' });
  response.end(JSON.stringify({ ok: true, path: request.url }));
});

server.listen(3000, () => console.log('listening on :3000'));`;function d(){return e.jsx(r,{code:t,language:"ts",title:"server.ts",lineNumbers:!0})}export{d as default};
