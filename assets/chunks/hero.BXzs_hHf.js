import{j as e}from"./jsx-runtime.BjG_zV1W.js";import{C as r}from"./CodeBlock.b1cJppYS.js";import"./index.BC-ZOPMe.js";import"./icons.C5e0GxhX.js";import"./i18n.fisrA6Na.js";import"./cache.DjsaJSNf.js";import"./observe.D2XLDznJ.js";import"./framework.BoUsC9QI.js";import"./styles.BxpoqTOI.js";import"./defaults.D04ek_WJ.js";const t=`import { createServer } from 'node:http';

const server = createServer((request, response) => {
  response.writeHead(200, { 'content-type': 'application/json' });
  response.end(JSON.stringify({ ok: true, path: request.url }));
});

server.listen(3000, () => console.log('listening on :3000'));`;function d(){return e.jsx(r,{code:t,language:"ts",title:"server.ts",lineNumbers:!0})}export{d as default};
