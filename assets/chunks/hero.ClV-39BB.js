import{j as e}from"./jsx-runtime.BjG_zV1W.js";import{C as r}from"./CodeBlock.DvWOAOCu.js";import"./index.CAJ_Adw3.js";import"./icons.C4HwxOCh.js";import"./i18n.C_owC-Jx.js";import"./cache.DjsaJSNf.js";import"./framework.CKd2nDfM.js";import"./styles.CDlaVNd_.js";import"./defaults.UE6OgxpG.js";const t=`import { createServer } from 'node:http';

const server = createServer((request, response) => {
  response.writeHead(200, { 'content-type': 'application/json' });
  response.end(JSON.stringify({ ok: true, path: request.url }));
});

server.listen(3000, () => console.log('listening on :3000'));`;function u(){return e.jsx(r,{code:t,language:"ts",title:"server.ts",lineNumbers:!0})}export{u as default};
