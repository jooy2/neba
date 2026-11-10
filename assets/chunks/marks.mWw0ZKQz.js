import{j as e}from"./jsx-runtime.BjG_zV1W.js";import{C as t}from"./CodeBlock._-TQpsXP.js";import"./index.CKsxLMuf.js";import"./icons.C5e0GxhX.js";import"./i18n.DpuvhODr.js";import"./cache.uQL3LqyE.js";import"./observe.BgVbFSQG.js";import"./framework.xlcI8-Dy.js";import"./styles.DWChSxLs.js";import"./defaults.B6iMc8JS.js";const i=`export function middleware(request: Request) {
  const token = request.headers.get('authorization');

  if (!token) {
    return new Response('Unauthorized', { status: 401 });
  }

  return NextResponse.next();
}`;function g(){return e.jsxs("div",{className:"flex w-full flex-col gap-4",children:[e.jsx(t,{code:i,language:"ts",lineNumbers:!0,highlightLines:"4-6",title:"highlightLines='4-6'"}),e.jsx(t,{code:i,language:"ts",lineNumbers:!0,highlightLines:[2,"4-6",9],theme:"one-dark",title:"highlightLines={[2, '4-6', 9]}"})]})}export{g as default};
