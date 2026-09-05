function o(e,n){return!e||e==="_self"||e==="_parent"||e==="_top"?n:[...new Set([...(n??"").split(/\s+/).filter(Boolean),"noopener","noreferrer"])].join(" ")}export{o as s};
