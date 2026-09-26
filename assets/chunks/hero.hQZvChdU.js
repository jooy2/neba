import{j as e}from"./jsx-runtime.BjG_zV1W.js";import{C as r}from"./CodeBlock.Ck54ofWB.js";import"./index.BC-ZOPMe.js";import"./icons.CMYhfmvL.js";import"./i18n.QqYapR6g.js";import"./cache.DjsaJSNf.js";import"./observe.D2XLDznJ.js";import"./framework.BoUsC9QI.js";import"./styles.BouEvDw_.js";import"./defaults.D04ek_WJ.js";const t=`import { createServer } from 'node:http';

const server = createServer((request, response) => {
  response.writeHead(200, { 'content-type': 'application/json' });
  response.end(JSON.stringify({ ok: true, path: request.url }));
});

server.listen(3000, () => console.log('listening on :3000'));`;function d(){return e.jsx(r,{code:t,language:"ts",title:"server.ts",lineNumbers:!0})}export{d as default};
