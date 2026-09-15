import{j as e}from"./jsx-runtime.BjG_zV1W.js";import{C as t}from"./CodeBlock.BN1ib7AN.js";import"./index.BC-ZOPMe.js";import"./icons.C4HwxOCh.js";import"./i18n.CNb1bbqZ.js";import"./cache.DjsaJSNf.js";import"./observe.D2XLDznJ.js";import"./framework.CKd2nDfM.js";import"./styles.BhE9daFN.js";import"./defaults.D04ek_WJ.js";const i=`export function middleware(request: Request) {
  const token = request.headers.get('authorization');

  if (!token) {
    return new Response('Unauthorized', { status: 401 });
  }

  return NextResponse.next();
}`;function g(){return e.jsxs("div",{className:"flex w-full flex-col gap-4",children:[e.jsx(t,{code:i,language:"ts",lineNumbers:!0,highlightLines:"4-6",title:"highlightLines='4-6'"}),e.jsx(t,{code:i,language:"ts",lineNumbers:!0,highlightLines:[2,"4-6",9],theme:"one-dark",title:"highlightLines={[2, '4-6', 9]}"})]})}export{g as default};
