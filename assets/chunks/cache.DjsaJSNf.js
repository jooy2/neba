function o(i,n,c){const t=i.get(n);if(t!==void 0)return t;i.size>=64&&i.clear();const e=c();return i.set(n,e),e}export{o as m};
