import e from"string-natural-compare";var t={},r=false;function dew(){if(r)return t;r=true;
/**
   * A cross-browser implementation of getElementsByClass.
   * Heavily based on Dustin Diaz's function: http://dustindiaz.com/getelementsbyclass.
   *
   * Find all elements with class `className` inside `container`.
   * Use `single = true` to increase performance in older browsers
   * when only one element is needed.
   *
   * @param {String} className
   * @param {Element} container
   * @param {Boolean} single
   * @api public
   */var getElementsByClassName=function(e,t,r){return r?e.getElementsByClassName(t)[0]:e.getElementsByClassName(t)};var querySelector=function(e,t,r){t="."+t;return r?e.querySelector(t):e.querySelectorAll(t)};var polyfill=function(e,t,r){var n=[],i="*";var a=e.getElementsByTagName(i);var s=a.length;var l=new RegExp("(^|\\s)"+t+"(\\s|$)");for(var u=0,o=0;u<s;u++)if(l.test(a[u].className)){if(r)return a[u];n[o]=a[u];o++}return n};t=function(){return function(e,t,r,n){n=n||{};return n.test&&n.getElementsByClassName||!n.test&&document.getElementsByClassName?getElementsByClassName(e,t,r):n.test&&n.querySelector||!n.test&&document.querySelector?querySelector(e,t,r):polyfill(e,t,r)}}();return t}var n={},i=false;function dew$1(){if(i)return n;i=true;n=function extend(e){var t=Array.prototype.slice.call(arguments,1);for(var r,n=0;r=t[n];n++)if(r)for(var i in r)e[i]=r[i];return e};return n}var a={},s=false;function dew$2(){if(s)return a;s=true;var e=[].indexOf;a=function(t,r){if(e)return t.indexOf(r);for(var n=0,i=t.length;n<i;++n)if(t[n]===r)return n;return-1};return a}var l={},u=false;function dew$3(){if(u)return l;u=true;
/**
   * Source: https://github.com/timoxley/to-array
   *
   * Convert an array-like object into an `Array`.
   * If `collection` is already an `Array`, then will return a clone of `collection`.
   *
   * @param {Array | Mixed} collection An `Array` or array-like object to convert e.g. `arguments` or `NodeList`
   * @return {Array} Naive conversion of `collection` to a new `Array`.
   * @api public
   */l=function toArray(e){if("undefined"===typeof e)return[];if(null===e)return[null];if(e===window)return[window];if("string"===typeof e)return[e];if(isArray(e))return e;if("number"!=typeof e.length)return[e];if("function"===typeof e&&e instanceof Function)return[e];var t=[];for(var r=0,n=e.length;r<n;r++)(Object.prototype.hasOwnProperty.call(e,r)||r in e)&&t.push(e[r]);return t.length?t:[]};function isArray(e){return"[object Array]"===Object.prototype.toString.call(e)}return l}var o={},f=false;var d="undefined"!==typeof globalThis?globalThis:"undefined"!==typeof self?self:global;function dew$4(){if(f)return o;f=true;var e=window.addEventListener?"addEventListener":"attachEvent",t=window.removeEventListener?"removeEventListener":"detachEvent",r="addEventListener"!==e?"on":"",n=dew$3();
/**
   * Bind `el` event `type` to `fn`.
   *
   * @param {Element} el, NodeList, HTMLCollection or Array
   * @param {String} type
   * @param {Function} fn
   * @param {Boolean} capture
   * @api public
   */o.bind=function(t,i,a,s){t=n(t);for(var l=0,u=t.length;l<u;l++)t[l][e](r+i,a,s||false)};
/**
   * Unbind `el` event `type`'s callback `fn`.
   *
   * @param {Element} el, NodeList, HTMLCollection or Array
   * @param {String} type
   * @param {Function} fn
   * @param {Boolean} capture
   * @api public
   */o.unbind=function(e,i,a,s){e=n(e);for(var l=0,u=e.length;l<u;l++)e[l][t](r+i,a,s||false)};
/**
   * Returns a function, that, as long as it continues to be invoked, will not
   * be triggered. The function will be called after it stops being called for
   * `wait` milliseconds. If `immediate` is true, trigger the function on the
   * leading edge, instead of the trailing.
   *
   * @param {Function} fn
   * @param {Integer} wait
   * @param {Boolean} immediate
   * @api public
   */o.debounce=function(e,t,r){var n;return t?function(){var i=this||d,a=arguments;var later=function(){n=null;r||e.apply(i,a)};var s=r&&!n;clearTimeout(n);n=setTimeout(later,t);s&&e.apply(i,a)}:e};return o}var h={},c=false;function dew$5(){if(c)return h;c=true;h=function(e){e=void 0===e?"":e;e=null===e?"":e;e=e.toString();return e};return h}var v={},g=false;var m="undefined"!==typeof globalThis?globalThis:"undefined"!==typeof self?self:global;function dew$6(){if(g)return v;g=true;var e=dew$2();var t=/\s+/;Object.prototype.toString;
/**
   * Wrap `el` in a `ClassList`.
   *
   * @param {Element} el
   * @return {ClassList}
   * @api public
   */v=function(e){return new ClassList(e)};
/**
   * Initialize a new ClassList for `el`.
   *
   * @param {Element} el
   * @api private
   */function ClassList(e){if(!e||!e.nodeType)throw new Error("A DOM element reference is required");(this||m).el=e;(this||m).list=e.classList}
/**
   * Add class `name` if not already present.
   *
   * @param {String} name
   * @return {ClassList}
   * @api public
   */ClassList.prototype.add=function(t){if((this||m).list){(this||m).list.add(t);return this||m}var r=this.array();var n=e(r,t);~n||r.push(t);(this||m).el.className=r.join(" ");return this||m};
/**
   * Remove class `name` when present, or
   * pass a regular expression to remove
   * any which match.
   *
   * @param {String|RegExp} name
   * @return {ClassList}
   * @api public
   */ClassList.prototype.remove=function(t){if((this||m).list){(this||m).list.remove(t);return this||m}var r=this.array();var n=e(r,t);~n&&r.splice(n,1);(this||m).el.className=r.join(" ");return this||m};
/**
   * Toggle class `name`, can force state via `force`.
   *
   * For browsers that support classList, but do not support `force` yet,
   * the mistake will be detected and corrected.
   *
   * @param {String} name
   * @param {Boolean} force
   * @return {ClassList}
   * @api public
   */ClassList.prototype.toggle=function(e,t){if((this||m).list){"undefined"!==typeof t?t!==(this||m).list.toggle(e,t)&&(this||m).list.toggle(e):(this||m).list.toggle(e);return this||m}"undefined"!==typeof t?t?this.add(e):this.remove(e):this.has(e)?this.remove(e):this.add(e);return this||m};ClassList.prototype.array=function(){var e=(this||m).el.getAttribute("class")||"";var r=e.replace(/^\s+|\s+$/g,"");var n=r.split(t);""===n[0]&&n.shift();return n};
/**
   * Check if class `name` is present.
   *
   * @param {String} name
   * @return {ClassList}
   * @api public
   */ClassList.prototype.has=ClassList.prototype.contains=function(t){return(this||m).list?(this||m).list.contains(t):!!~e(this.array(),t)};return v}var p={},w=false;function dew$7(){if(w)return p;w=true;
/**
   * A cross-browser implementation of getAttribute.
   * Source found here: http://stackoverflow.com/a/3755343/361337 written by Vivin Paliath
   *
   * Return the value for `attr` at `element`.
   *
   * @param {Element} el
   * @param {String} attr
   * @api public
   */p=function(e,t){var r=e.getAttribute&&e.getAttribute(t)||null;if(!r){var n=e.attributes;var i=n.length;for(var a=0;a<i;a++)void 0!==n[a]&&n[a].nodeName===t&&(r=n[a].nodeValue)}return r};return p}var y={},b=false;var C="undefined"!==typeof globalThis?globalThis:"undefined"!==typeof self?self:global;function dew$8(){if(b)return y;b=true;y=function(e){return function(t,r,n){var i=this||C;(this||C)._values={};(this||C).found=false;(this||C).filtered=false;var init=function(t,r,n){if(void 0===r)n?i.values(t,n):i.values(t);else{i.elm=r;var a=e.templater.get(i,t);i.values(a)}};(this||C).values=function(t,r){if(void 0===t)return i._values;for(var n in t)i._values[n]=t[n];true!==r&&e.templater.set(i,i.values())};(this||C).show=function(){e.templater.show(i)};(this||C).hide=function(){e.templater.hide(i)};(this||C).matching=function(){return e.filtered&&e.searched&&i.found&&i.filtered||e.filtered&&!e.searched&&i.filtered||!e.filtered&&e.searched&&i.found||!e.filtered&&!e.searched};(this||C).visible=function(){return!(!i.elm||i.elm.parentNode!=e.list)};init(t,r,n)}};return y}var $={},S=false;function dew$9(){if(S)return $;S=true;$=function(e){var addAsync=function(t,r,n){var i=t.splice(0,50);n=n||[];n=n.concat(e.add(i));if(t.length>0)setTimeout((function(){addAsync(t,r,n)}),1);else{e.update();r(n)}};return addAsync};return $}var A={},N=false;"undefined"!==typeof globalThis?globalThis:"undefined"!==typeof self?self:global;function dew$a(){if(N)return A;N=true;var e=dew$6(),t=dew$4(),r=dew$i();A=function(n){var i=false;var refresh=function(t,r){if(n.page<1){n.listContainer.style.display="none";i=true}else{i&&(n.listContainer.style.display="block");var s,l=n.matchingItems.length,u=n.i,o=n.page,f=Math.ceil(l/o),d=Math.ceil(u/o),h=r.innerWindow||2,c=r.left||r.outerWindow||0,v=r.right||r.outerWindow||0;v=f-v;t.clear();for(var g=1;g<=f;g++){var m=d===g?"active":"";if(a.number(g,c,v,d,h)){s=t.add({page:g,dotted:false})[0];m&&e(s.elm).add(m);s.elm.firstChild.setAttribute("data-i",g);s.elm.firstChild.setAttribute("data-page",o)}else if(a.dotted(t,g,c,v,d,h,t.size())){s=t.add({page:"...",dotted:true})[0];e(s.elm).add("disabled")}}}};var a={number:function(e,t,r,n,i){return this.left(e,t)||this.right(e,r)||this.innerWindow(e,n,i)},left:function(e,t){return e<=t},right:function(e,t){return e>t},innerWindow:function(e,t,r){return e>=t-r&&e<=t+r},dotted:function(e,t,r,n,i,a,s){return this.dottedLeft(e,t,r,n,i,a)||this.dottedRight(e,t,r,n,i,a,s)},dottedLeft:function(e,t,r,n,i,a){return t==r+1&&!this.innerWindow(t,i,a)&&!this.right(t,n)},dottedRight:function(e,t,r,n,i,a,s){return!e.items[s-1].values().dotted&&(t==n&&!this.innerWindow(t,i,a)&&!this.right(t,n))}};return function(e){var i=new r(n.listContainer.id,{listClass:e.paginationClass||"pagination",item:e.item||"<li><a class='page' href='#'></a></li>",valueNames:["page","dotted"],searchClass:"pagination-search-that-is-not-supposed-to-exist",sortClass:"pagination-sort-that-is-not-supposed-to-exist"});t.bind(i.listContainer,"click",(function(e){var t=e.target||e.srcElement,r=n.utils.getAttribute(t,"data-page"),i=n.utils.getAttribute(t,"data-i");i&&n.show((i-1)*r+1,r)}));n.on("updated",(function(){refresh(i,e)}));refresh(i,e)}};return A}var E={},L=false;function dew$b(){if(L)return E;L=true;E=function(e){var t=dew$8()(e);var getChildren=function(e){var t=e.childNodes,r=[];for(var n=0,i=t.length;n<i;n++)void 0===t[n].data&&r.push(t[n]);return r};var parse=function(r,n){for(var i=0,a=r.length;i<a;i++)e.items.push(new t(n,r[i]))};var parseAsync=function(t,r){var n=t.splice(0,50);parse(n,r);if(t.length>0)setTimeout((function(){parseAsync(t,r)}),1);else{e.update();e.trigger("parseComplete")}};e.handlers.parseComplete=e.handlers.parseComplete||[];return function(){var t=getChildren(e.list),r=e.valueNames;e.indexAsync?parseAsync(t,r):parse(t,r)}};return E}var T={},O=false;var x="undefined"!==typeof globalThis?globalThis:"undefined"!==typeof self?self:global;function dew$c(){if(O)return T;O=true;var Templater=function(e){var t,r=this||x;var init=function(){var r;if("function"!==typeof e.item){r="string"===typeof e.item?-1===e.item.indexOf("<")?document.getElementById(e.item):getItemSource(e.item):getFirstListItem();if(!r)throw new Error("The list needs to have at least one item on init otherwise you'll have to add a template.");r=createCleanTemplateItem(r,e.valueNames);t=function(){return r.cloneNode(true)}}else t=function(t){var r=e.item(t);return getItemSource(r)}};var createCleanTemplateItem=function(t,r){var n=t.cloneNode(true);n.removeAttribute("id");for(var i=0,a=r.length;i<a;i++){var s=void 0,l=r[i];if(l.data)for(var u=0,o=l.data.length;u<o;u++)n.setAttribute("data-"+l.data[u],"");else if(l.attr&&l.name){s=e.utils.getByClass(n,l.name,true);s&&s.setAttribute(l.attr,"")}else{s=e.utils.getByClass(n,l,true);s&&(s.innerHTML="")}}return n};var getFirstListItem=function(){var t=e.list.childNodes;for(var r=0,n=t.length;r<n;r++)if(void 0===t[r].data)return t[r].cloneNode(true)};var getItemSource=function(e){if("string"===typeof e){if(/<tr[\s>]/g.exec(e)){var t=document.createElement("tbody");t.innerHTML=e;return t.firstElementChild}if(-1!==e.indexOf("<")){var r=document.createElement("div");r.innerHTML=e;return r.firstElementChild}}};var getValueName=function(t){for(var r=0,n=e.valueNames.length;r<n;r++){var i=e.valueNames[r];if(i.data){var a=i.data;for(var s=0,l=a.length;s<l;s++)if(a[s]===t)return{data:t}}else{if(i.attr&&i.name&&i.name==t)return i;if(i===t)return t}}};var setValue=function(t,r,n){var i=void 0,a=getValueName(r);if(a)if(a.data)t.elm.setAttribute("data-"+a.data,n);else if(a.attr&&a.name){i=e.utils.getByClass(t.elm,a.name,true);i&&i.setAttribute(a.attr,n)}else{i=e.utils.getByClass(t.elm,a,true);i&&(i.innerHTML=n)}};(this||x).get=function(t,n){r.create(t);var i={};for(var a=0,s=n.length;a<s;a++){var l=void 0,u=n[a];if(u.data)for(var o=0,f=u.data.length;o<f;o++)i[u.data[o]]=e.utils.getAttribute(t.elm,"data-"+u.data[o]);else if(u.attr&&u.name){l=e.utils.getByClass(t.elm,u.name,true);i[u.name]=l?e.utils.getAttribute(l,u.attr):""}else{l=e.utils.getByClass(t.elm,u,true);i[u]=l?l.innerHTML:""}}return i};(this||x).set=function(e,t){if(!r.create(e))for(var n in t)t.hasOwnProperty(n)&&setValue(e,n,t[n])};(this||x).create=function(e){if(void 0!==e.elm)return false;e.elm=t(e.values());r.set(e,e.values());return true};(this||x).remove=function(t){t.elm.parentNode===e.list&&e.list.removeChild(t.elm)};(this||x).show=function(t){r.create(t);e.list.appendChild(t.elm)};(this||x).hide=function(t){void 0!==t.elm&&t.elm.parentNode===e.list&&e.list.removeChild(t.elm)};(this||x).clear=function(){if(e.list.hasChildNodes())while(e.list.childNodes.length>=1)e.list.removeChild(e.list.firstChild)};init()};T=function(e){return new Templater(e)};return T}var I={},B=false;function dew$d(){if(B)return I;B=true;I=function(e){var t,r,n;var i={resetList:function(){e.i=1;e.templater.clear();n=void 0},setOptions:function(e){if(2==e.length&&e[1]instanceof Array)t=e[1];else if(2==e.length&&"function"==typeof e[1]){t=void 0;n=e[1]}else if(3==e.length){t=e[1];n=e[2]}else t=void 0},setColumns:function(){0!==e.items.length&&void 0===t&&(t=void 0===e.searchColumns?i.toArray(e.items[0].values()):e.searchColumns)},setSearchString:function(t){t=e.utils.toString(t).toLowerCase();t=t.replace(/[-[\]{}()*+?.,\\^$|#]/g,"\\$&");r=t},toArray:function(e){var t=[];for(var r in e)t.push(r);return t}};var a={list:function(){var n,i=[],a=r;while(null!==(n=a.match(/"([^"]+)"/))){i.push(n[1]);a=a.substring(0,n.index)+a.substring(n.index+n[0].length)}a=a.trim();a.length&&(i=i.concat(a.split(/\s+/)));for(var s=0,l=e.items.length;s<l;s++){var u=e.items[s];u.found=false;if(i.length){for(var o=0,f=i.length;o<f;o++){var d=false;for(var h=0,c=t.length;h<c;h++){var v=u.values(),g=t[h];if(v.hasOwnProperty(g)&&void 0!==v[g]&&null!==v[g]){var m="string"!==typeof v[g]?v[g].toString():v[g];if(-1!==m.toLowerCase().indexOf(i[o])){d=true;break}}}if(!d)break}u.found=d}}},reset:function(){e.reset.search();e.searched=false}};var searchMethod=function(s){e.trigger("searchStart");i.resetList();i.setSearchString(s);i.setOptions(arguments);i.setColumns();if(""===r)a.reset();else{e.searched=true;n?n(r,t):a.list()}e.update();e.trigger("searchComplete");return e.visibleItems};e.handlers.searchStart=e.handlers.searchStart||[];e.handlers.searchComplete=e.handlers.searchComplete||[];e.utils.events.bind(e.utils.getByClass(e.listContainer,e.searchClass),"keyup",e.utils.events.debounce((function(t){var r=t.target||t.srcElement,n=""===r.value&&!e.searched;n||searchMethod(r.value)}),e.searchDelay));e.utils.events.bind(e.utils.getByClass(e.listContainer,e.searchClass),"input",(function(e){var t=e.target||e.srcElement;""===t.value&&searchMethod("")}));return searchMethod};return I}var M={},_=false;function dew$e(){if(_)return M;_=true;M=function(e){e.handlers.filterStart=e.handlers.filterStart||[];e.handlers.filterComplete=e.handlers.filterComplete||[];return function(t){e.trigger("filterStart");e.i=1;e.reset.filter();if(void 0===t)e.filtered=false;else{e.filtered=true;var r=e.items;for(var n=0,i=r.length;n<i;n++){var a=r[n];t(a)?a.filtered=true:a.filtered=false}}e.update();e.trigger("filterComplete");return e.visibleItems}};return M}var k={},z=false;function dew$f(){if(z)return k;z=true;k=function(e){var t={els:void 0,clear:function(){for(var r=0,n=t.els.length;r<n;r++){e.utils.classes(t.els[r]).remove("asc");e.utils.classes(t.els[r]).remove("desc")}},getOrder:function(t){var r=e.utils.getAttribute(t,"data-order");return"asc"==r||"desc"==r?r:e.utils.classes(t).has("desc")?"asc":e.utils.classes(t).has("asc")?"desc":"asc"},getInSensitive:function(t,r){var n=e.utils.getAttribute(t,"data-insensitive");r.insensitive="false"!==n},setOrder:function(r){for(var n=0,i=t.els.length;n<i;n++){var a=t.els[n];if(e.utils.getAttribute(a,"data-sort")===r.valueName){var s=e.utils.getAttribute(a,"data-order");"asc"==s||"desc"==s?s==r.order&&e.utils.classes(a).add(r.order):e.utils.classes(a).add(r.order)}}}};var sort=function(){e.trigger("sortStart");var r={};var n=arguments[0].currentTarget||arguments[0].srcElement||void 0;if(n){r.valueName=e.utils.getAttribute(n,"data-sort");t.getInSensitive(n,r);r.order=t.getOrder(n)}else{r=arguments[1]||r;r.valueName=arguments[0];r.order=r.order||"asc";r.insensitive="undefined"==typeof r.insensitive||r.insensitive}t.clear();t.setOrder(r);var i,a=r.sortFunction||e.sortFunction||null,s="desc"===r.order?-1:1;i=a?function(e,t){return a(e,t,r)*s}:function(t,n){var i=e.utils.naturalSort;i.alphabet=e.alphabet||r.alphabet||void 0;!i.alphabet&&r.insensitive&&(i=e.utils.naturalSort.caseInsensitive);return i(t.values()[r.valueName],n.values()[r.valueName])*s};e.items.sort(i);e.update();e.trigger("sortComplete")};e.handlers.sortStart=e.handlers.sortStart||[];e.handlers.sortComplete=e.handlers.sortComplete||[];t.els=e.utils.getByClass(e.listContainer,e.sortClass);e.utils.events.bind(t.els,"click",sort);e.on("searchStart",t.clear);e.on("filterStart",t.clear);return sort};return k}var W={},j=false;function dew$g(){if(j)return W;j=true;W=function(e,t,r){var n=r.location||0;var i=r.distance||100;var a=r.threshold||.4;if(t===e)return true;if(t.length>32)return false;var s=n,l=function(){var e,r={};for(e=0;e<t.length;e++)r[t.charAt(e)]=0;for(e=0;e<t.length;e++)r[t.charAt(e)]|=1<<t.length-e-1;return r}();function match_bitapScore_(e,r){var n=e/t.length,a=Math.abs(s-r);return i?n+a/i:a?1:n}var u=a,o=e.indexOf(t,s);if(-1!=o){u=Math.min(match_bitapScore_(0,o),u);o=e.lastIndexOf(t,s+t.length);-1!=o&&(u=Math.min(match_bitapScore_(0,o),u))}var f=1<<t.length-1;o=-1;var d,h;var c=t.length+e.length;var v;for(var g=0;g<t.length;g++){d=0;h=c;while(d<h){match_bitapScore_(g,s+h)<=u?d=h:c=h;h=Math.floor((c-d)/2+d)}c=h;var m=Math.max(1,s-h+1);var p=Math.min(s+h,e.length)+t.length;var w=Array(p+2);w[p+1]=(1<<g)-1;for(var y=p;y>=m;y--){var b=l[e.charAt(y-1)];w[y]=0===g?(w[y+1]<<1|1)&b:(w[y+1]<<1|1)&b|(v[y+1]|v[y])<<1|1|v[y+1];if(w[y]&f){var C=match_bitapScore_(g,y-1);if(C<=u){u=C;o=y-1;if(!(o>s))break;m=Math.max(1,2*s-o)}}}if(match_bitapScore_(g+1,s)>u)break;v=w}return!(o<0)};return W}var q={},H=false;function dew$h(){if(H)return q;H=true;dew$6();var e=dew$4(),t=dew$1(),r=dew$5(),n=dew(),i=dew$g();q=function(a,s){s=s||{};s=t({location:0,distance:100,threshold:.4,multiSearch:true,searchClass:"fuzzy-search"},s);var l={search:function(e,t){var r=s.multiSearch?e.replace(/ +$/,"").split(/ +/):[e];for(var n=0,i=a.items.length;n<i;n++)l.item(a.items[n],t,r)},item:function(e,t,r){var n=true;for(var i=0;i<r.length;i++){var a=false;for(var s=0,u=t.length;s<u;s++)l.values(e.values(),t[s],r[i])&&(a=true);a||(n=false)}e.found=n},values:function(e,t,n){if(e.hasOwnProperty(t)){var a=r(e[t]).toLowerCase();if(i(a,n,s))return true}return false}};e.bind(n(a.listContainer,s.searchClass),"keyup",a.utils.events.debounce((function(e){var t=e.target||e.srcElement;a.search(t.value,l.search)}),a.searchDelay));return function(e,t){a.search(e,t,l.search)}};return q}var P={},D=false;var F="undefined"!==typeof globalThis?globalThis:"undefined"!==typeof self?self:global;function dew$i(){if(D)return P;D=true;var t=e,r=dew(),n=dew$1(),i=dew$2(),a=dew$4(),s=dew$5(),l=dew$6(),u=dew$7(),o=dew$3();P=function(e,f,d){var h,c=this||F,v=dew$8()(c),g=dew$9()(c),m=dew$a()(c);h={start:function(){c.listClass="list";c.searchClass="search";c.sortClass="sort";c.page=1e4;c.i=1;c.items=[];c.visibleItems=[];c.matchingItems=[];c.searched=false;c.filtered=false;c.searchColumns=void 0;c.searchDelay=0;c.handlers={updated:[]};c.valueNames=[];c.utils={getByClass:r,extend:n,indexOf:i,events:a,toString:s,naturalSort:t,classes:l,getAttribute:u,toArray:o};c.utils.extend(c,f);c.listContainer="string"===typeof e?document.getElementById(e):e;if(c.listContainer){c.list=r(c.listContainer,c.listClass,true);c.parse=dew$b()(c);c.templater=dew$c()(c);c.search=dew$d()(c);c.filter=dew$e()(c);c.sort=dew$f()(c);c.fuzzySearch=dew$h()(c,f.fuzzySearch);this.handlers();this.items();this.pagination();c.update()}},handlers:function(){for(var e in c.handlers)c[e]&&c.handlers.hasOwnProperty(e)&&c.on(e,c[e])},items:function(){c.parse(c.list);void 0!==d&&c.add(d)},pagination:function(){if(void 0!==f.pagination){true===f.pagination&&(f.pagination=[{}]);void 0===f.pagination[0]&&(f.pagination=[f.pagination]);for(var e=0,t=f.pagination.length;e<t;e++)m(f.pagination[e])}}};(this||F).reIndex=function(){c.items=[];c.visibleItems=[];c.matchingItems=[];c.searched=false;c.filtered=false;c.parse(c.list)};(this||F).toJSON=function(){var e=[];for(var t=0,r=c.items.length;t<r;t++)e.push(c.items[t].values());return e};(this||F).add=function(e,t){if(0!==e.length){if(!t){var r=[],n=false;void 0===e[0]&&(e=[e]);for(var i=0,a=e.length;i<a;i++){var s=null;n=c.items.length>c.page;s=new v(e[i],void 0,n);c.items.push(s);r.push(s)}c.update();return r}g(e.slice(0),t)}};(this||F).show=function(e,t){(this||F).i=e;(this||F).page=t;c.update();return c};(this||F).remove=function(e,t,r){var n=0;for(var i=0,a=c.items.length;i<a;i++)if(c.items[i].values()[e]==t){c.templater.remove(c.items[i],r);c.items.splice(i,1);a--;i--;n++}c.update();return n};(this||F).get=function(e,t){var r=[];for(var n=0,i=c.items.length;n<i;n++){var a=c.items[n];a.values()[e]==t&&r.push(a)}return r};(this||F).size=function(){return c.items.length};(this||F).clear=function(){c.templater.clear();c.items=[];return c};(this||F).on=function(e,t){c.handlers[e].push(t);return c};(this||F).off=function(e,t){var r=c.handlers[e];var n=i(r,t);n>-1&&r.splice(n,1);return c};(this||F).trigger=function(e){var t=c.handlers[e].length;while(t--)c.handlers[e][t](c);return c};(this||F).reset={filter:function(){var e=c.items,t=e.length;while(t--)e[t].filtered=false;return c},search:function(){var e=c.items,t=e.length;while(t--)e[t].found=false;return c}};(this||F).update=function(){var e=c.items,t=e.length;c.visibleItems=[];c.matchingItems=[];c.templater.clear();for(var r=0;r<t;r++)if(e[r].matching()&&c.matchingItems.length+1>=c.i&&c.visibleItems.length<c.page){e[r].show();c.visibleItems.push(e[r]);c.matchingItems.push(e[r])}else if(e[r].matching()){c.matchingItems.push(e[r]);e[r].hide()}else e[r].hide();c.trigger("updated");return c};h.start()};return P}var R=dew$i();export default R;
