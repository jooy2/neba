function s(i,n,c,o=64){const t=i.get(n);if(t!==void 0)return t;i.size>=o&&i.clear();const e=c();return i.set(n,e),e}export{s as m};
