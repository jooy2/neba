import{j as e}from"./jsx-runtime.BjG_zV1W.js";import{C as r}from"./CodeBlock._-TQpsXP.js";import"./index.CKsxLMuf.js";import"./icons.C5e0GxhX.js";import"./i18n.DpuvhODr.js";import"./cache.uQL3LqyE.js";import"./observe.BgVbFSQG.js";import"./framework.xlcI8-Dy.js";import"./styles.DWChSxLs.js";import"./defaults.B6iMc8JS.js";const t=`import { createServer } from 'node:http';

const server = createServer((request, response) => {
  response.writeHead(200, { 'content-type': 'application/json' });
  response.end(JSON.stringify({ ok: true, path: request.url }));
});

server.listen(3000, () => console.log('listening on :3000'));`;function d(){return e.jsx(r,{code:t,language:"ts",title:"server.ts",lineNumbers:!0})}export{d as default};
