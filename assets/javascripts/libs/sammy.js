(function(b,a){(function(c){if(typeof define==="function"&&define.amd){define(["jquery"],c);}else{b.sammy=a.Sammy=c(b);}})(function(k){var r,i="([^/]+)",m=/:([\w\d]+)/g,n=/\?([^#]*)?$/,e=function(s){return Array.prototype.slice.call(s);},f=function(s){return Object.prototype.toString.call(s)==="[object Function]";},o=function(s){return Object.prototype.toString.call(s)==="[object Array]";},j=function(s){return Object.prototype.toString.call(s)==="[object RegExp]";},l=function(s){return decodeURIComponent((s||"").replace(/\+/g," "));},d=encodeURIComponent,h=function(t){return String(t).replace(/&(?!\w+;)/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;");},p=function(s){return function(t,u){return this.route.apply(this,[s,t,u]);};},c={},q=!!(a.history&&history.pushState),g=[];r=function(){var t=e(arguments),u,s;r.apps=r.apps||{};if(t.length===0||t[0]&&f(t[0])){return r.apply(r,["body"].concat(t));}else{if(typeof(s=t.shift())=="string"){u=r.apps[s]||new r.Application();u.element_selector=s;if(t.length>0){k.each(t,function(v,w){u.use(w);});}if(u.element_selector!=s){delete r.apps[s];}r.apps[u.element_selector]=u;return u;}}};r.VERSION="0.7.2";r.addLogger=function(s){g.push(s);};r.log=function(){var s=e(arguments);s.unshift("["+Date()+"]");k.each(g,function(u,t){t.apply(r,s);});};if(typeof a.console!="undefined"){if(f(a.console.log.apply)){r.addLogger(function(){a.console.log.apply(a.console,arguments);});}else{r.addLogger(function(){a.console.log(arguments);});}}else{if(typeof console!="undefined"){r.addLogger(function(){console.log.apply(console,arguments);});}}k.extend(r,{makeArray:e,isFunction:f,isArray:o});r.Object=function(s){return k.extend(this,s||{});};k.extend(r.Object.prototype,{escapeHTML:h,h:h,toHash:function(){var s={};k.each(this,function(u,t){if(!f(t)){s[u]=t;}});return s;},toHTML:function(){var s="";k.each(this,function(u,t){if(!f(t)){s+="<strong>"+u+"</strong> "+t+"<br />";}});return s;},keys:function(s){var t=[];for(var u in this){if(!f(this[u])||!s){t.push(u);}}return t;},has:function(s){return this[s]&&k.trim(this[s].toString())!=="";},join:function(){var t=e(arguments);var s=t.shift();return t.join(s);},log:function(){console.log("-------------");console.log(this.debug);r.log.apply(r,arguments);},toString:function(t){var u=[];k.each(this,function(w,s){if(!f(s)||t){u.push('"'+w+'": '+s.toString());}});return"Sammy.Object: {"+u.join(",")+"}";}});r.DefaultLocationProxy=function(t,s){this.app=t;this.is_native=false;this.has_history=q;this._startPolling(s);};r.DefaultLocationProxy.fullPath=function(s){var t=s.toString().match(/^[^#]*(#.+)$/);var u=t?t[1]:"";return[s.pathname,s.search,u].join("");};k.extend(r.DefaultLocationProxy.prototype,{bind:function(){var t=this,u=this.app,s=r.DefaultLocationProxy;k(a).bind("hashchange."+this.app.eventNamespace(),function(w,v){if(t.is_native===false&&!v){t.is_native=true;a.clearInterval(s._interval);}u.trigger("location-changed");});if(q&&!u.disable_push_state){k(a).bind("popstate."+this.app.eventNamespace(),function(v){u.trigger("location-changed");});k("a").live("click.history-"+this.app.eventNamespace(),function(w){if(w.isDefaultPrevented()||w.metaKey||w.ctrlKey){return;}var v=s.fullPath(this);if(this.hostname==a.location.hostname&&u.lookupRoute("get",v)&&this.target!=="_blank"){w.preventDefault();t.setLocation(v);return false;}});}if(!s._bindings){s._bindings=0;}s._bindings++;},unbind:function(){k(a).unbind("hashchange."+this.app.eventNamespace());k(a).unbind("popstate."+this.app.eventNamespace());k("a").die("click.history-"+this.app.eventNamespace());r.DefaultLocationProxy._bindings--;if(r.DefaultLocationProxy._bindings<=0){a.clearInterval(r.DefaultLocationProxy._interval);}},getLocation:function(){return r.DefaultLocationProxy.fullPath(a.location);},setLocation:function(s){if(/^([^#\/]|$)/.test(s)){if(q&&!this.app.disable_push_state){s="/"+s;}else{s="#!/"+s;}}if(s!=this.getLocation()){if(q&&!this.app.disable_push_state&&/^\//.test(s)){history.pushState({path:s},a.title,s);this.app.trigger("location-changed");}else{return(a.location=s);}}},_startPolling:function(u){var t=this;if(!r.DefaultLocationProxy._interval){if(!u){u=10;}var s=function(){var v=t.getLocation();if(typeof r.DefaultLocationProxy._last_location=="undefined"||v!=r.DefaultLocationProxy._last_location){a.setTimeout(function(){k(a).trigger("hashchange",[true]);},0);}r.DefaultLocationProxy._last_location=v;};s();r.DefaultLocationProxy._interval=a.setInterval(s,u);}}});r.Application=function(s){var t=this;this.routes={};this.listeners=new r.Object({});this.arounds=[];this.befores=[];this.namespace=(new Date()).getTime()+"-"+parseInt(Math.random()*1000,10);this.context_prototype=function(){r.EventContext.apply(this,arguments);};this.context_prototype.prototype=new r.EventContext();if(f(s)){s.apply(this,[this]);}if(!this._location_proxy){this.setLocationProxy(new r.DefaultLocationProxy(this,this.run_interval_every));}if(this.debug){this.bindToAllEvents(function(v,u){t.log(t.toString(),v.cleaned_type,u||{});});}};r.Application.prototype=k.extend({},r.Object.prototype,{ROUTE_VERBS:["get","post","put","delete"],APP_EVENTS:["run","unload","lookup-route","run-route","route-found","event-context-before","event-context-after","changed","error","check-form-submission","redirect","location-changed"],_last_route:null,_location_proxy:null,_running:false,element_selector:"body",debug:false,raise_errors:false,run_interval_every:50,disable_push_state:false,template_engine:null,toString:function(){return"Sammy.Application:"+this.element_selector;},$element:function(s){return s?k(this.element_selector).find(s):k(this.element_selector);},use:function(){var s=e(arguments),u=s.shift(),t=u||"";try{s.unshift(this);if(typeof u=="string"){t="Sammy."+u;u=r[u];}u.apply(this,s);}catch(v){if(typeof u==="undefined"){this.error("Plugin Error: called use() but plugin ("+t.toString()+") is not defined",v);}else{if(!f(u)){this.error("Plugin Error: called use() but '"+t.toString()+"' is not a function",v);}else{this.error("Plugin Error",v);}}}return this;},setLocationProxy:function(s){var t=this._location_proxy;this._location_proxy=s;if(this.isRunning()){if(t){t.unbind();}this._location_proxy.bind();}},log:function(){if(this.debug){r.log.apply(r,Array.prototype.concat.apply([this.element_selector],arguments));}},route:function(w,t,y){var v=this,x=[],s,u;if(!y&&f(t)){t=w;y=t;w="any";}w=w.toLowerCase();if(t.constructor==String){m.lastIndex=0;while((u=m.exec(t))!==null){x.push(u[1]);}t=new RegExp(t.replace(m,i)+"$");}if(typeof y=="string"){y=v[y];}s=function(z){var A={verb:z,path:t,callback:y,param_names:x};v.routes[z]=v.routes[z]||[];v.routes[z].push(A);};if(w==="any"){k.each(this.ROUTE_VERBS,function(A,z){s(z);});}else{s(w);}return this;},get:p("get"),post:p("post"),put:p("put"),del:p("delete"),any:p("any"),mapRoutes:function(t){var s=this;k.each(t,function(u,v){s.route.apply(s,v);});return this;},eventNamespace:function(){return["sammy-app",this.namespace].join("-");},bind:function(s,u,w){var v=this;if(typeof w=="undefined"){w=u;}var t=function(){var z,x,y;z=arguments[0];y=arguments[1];if(y&&y.context){x=y.context;delete y.context;}else{x=new v.context_prototype(v,"bind",z.type,y,z.target);}z.cleaned_type=z.type.replace(v.eventNamespace(),"");w.apply(x,[z,y]);};if(!this.listeners[s]){this.listeners[s]=[];}this.listeners[s].push(t);if(this.isRunning()){this._listen(s,t);}return this;},trigger:function(s,t){this.$element().trigger([s,this.eventNamespace()].join("."),[t]);return this;},refresh:function(){this.last_location=null;this.trigger("location-changed");return this;},before:function(s,t){if(f(s)){t=s;s={};}this.befores.push([s,t]);return this;},after:function(s){return this.bind("event-context-after",s);},around:function(s){this.arounds.push(s);return this;},isRunning:function(){return this._running;},helpers:function(s){k.extend(this.context_prototype.prototype,s);return this;},helper:function(s,t){this.context_prototype.prototype[s]=t;return this;},run:function(s){if(this.isRunning()){return false;}var t=this;k.each(this.listeners.toHash(),function(u,v){k.each(v,function(x,w){t._listen(u,w);});});this.trigger("run",{start_url:s});this._running=true;this.last_location=null;if(!(/\#(.+)/.test(this.getLocation()))&&typeof s!="undefined"){this.setLocation(s);}this._checkLocation();this._location_proxy.bind();this.bind("location-changed",function(){t._checkLocation();});this.bind("submit",function(v){var u=t._checkFormSubmission(k(v.target).closest("form"));return(u===false)?v.preventDefault():false;});k(a).bind("unload",function(){t.unload();});return this.trigger("changed");},unload:function(){if(!this.isRunning()){return false;}var s=this;this.trigger("unload");this._location_proxy.unbind();this.$element().unbind("submit").removeClass(s.eventNamespace());k.each(this.listeners.toHash(),function(t,u){k.each(u,function(w,v){s._unlisten(t,v);});});this._running=false;return this;},destroy:function(){this.unload();delete r.apps[this.element_selector];return this;},bindToAllEvents:function(t){var s=this;k.each(this.APP_EVENTS,function(u,v){s.bind(v,t);});k.each(this.listeners.keys(true),function(v,u){if(k.inArray(u,s.APP_EVENTS)==-1){s.bind(u,t);}});return this;},routablePath:function(s){return s.replace(n,"");},lookupRoute:function(y,w){var x=this,v=false,u=0,s,t;if(typeof this.routes[y]!="undefined"){s=this.routes[y].length;for(;u<s;u++){t=this.routes[y][u];if(x.routablePath(w).match(t.path)){v=t;break;}}}return v;},runRoute:function(u,H,w,z){var v=this,F=this.lookupRoute(u,H),t,C,x,B,G,D,A,E,s;this.log("runRoute",[u,H].join(" "));this.trigger("run-route",{verb:u,path:H,params:w});if(typeof w=="undefined"){w={};}k.extend(w,this._parseQueryString(H));if(F){this.trigger("route-found",{route:F});if((E=F.path.exec(this.routablePath(H)))!==null){E.shift();k.each(E,function(I,J){if(F.param_names[I]){w[F.param_names[I]]=l(J);}else{if(!w.splat){w.splat=[];}w.splat.push(l(J));}});}t=new this.context_prototype(this,u,H,w,z);x=this.arounds.slice(0);G=this.befores.slice(0);A=[t].concat(w.splat);C=function(){var I;while(G.length>0){D=G.shift();if(v.contextMatchesOptions(t,D[0])){I=D[1].apply(t,[t]);if(I===false){return false;}}}v.last_route=F;t.trigger("event-context-before",{context:t});I=F.callback.apply(t,A);t.trigger("event-context-after",{context:t});return I;};k.each(x.reverse(),function(I,J){var K=C;C=function(){return J.apply(t,[K]);};});try{s=C();}catch(y){this.error(["500 Error",u,H].join(" "),y);}return s;}else{return this.notFound(u,H);}},contextMatchesOptions:function(u,v,A){var C=v;if(typeof C==="string"||j(C)){C={path:C};}if(typeof A==="undefined"){A=true;}if(k.isEmptyObject(C)){return true;}if(o(C.path)){var z,w,s,B;z=[];for(w=0,B=C.path.length;w<B;w+=1){s=k.extend({},C,{path:C.path[w]});z.push(this.contextMatchesOptions(u,s));}var t=k.inArray(true,z)>-1?true:false;return A?t:!t;}if(C.only){return this.contextMatchesOptions(u,C.only,true);}else{if(C.except){return this.contextMatchesOptions(u,C.except,false);}}var x=true,y=true;if(C.path){if(!j(C.path)){C.path=new RegExp(C.path.toString()+"$");}x=C.path.test(u.path);}if(C.verb){if(typeof C.verb==="string"){y=C.verb===u.verb;}else{y=C.verb.indexOf(u.verb)>-1;}}return A?(y&&x):!(y&&x);},getLocation:function(){return this._location_proxy.getLocation();},setLocation:function(s){return this._location_proxy.setLocation(s);},swap:function(t,u){var s=this.$element().html(t);if(f(u)){u(t);}return s;},templateCache:function(s,t){if(typeof t!="undefined"){return c[s]=t;}else{return c[s];}},clearTemplateCache:function(){return(c={});},notFound:function(u,t){var s=this.error(["404 Not Found",u,t].join(" "));return(u==="get")?s:true;},error:function(t,s){if(!s){s=new Error();}s.message=[t,s.message].join(" ");this.trigger("error",{message:s.message,error:s});if(this.raise_errors){throw (s);}else{this.log(s.message,s);}},_checkLocation:function(){var s,t;s=this.getLocation();if(!this.last_location||this.last_location[0]!="get"||this.last_location[1]!=s){this.last_location=["get",s];t=this.runRoute("get",s);}return t;},_getFormVerb:function(u){var t=k(u),v,s;s=t.find('input[name="_method"]');if(s.length>0){v=s.val();}if(!v){v=t[0].getAttribute("method");}if(!v||v===""){v="get";}return k.trim(v.toString().toLowerCase());},_checkFormSubmission:function(u){var s,v,x,w,t;this.trigger("check-form-submission",{form:u});s=k(u);v=s.attr("action")||"";x=this._getFormVerb(s);this.log("_checkFormSubmission",s,v,x);if(x==="get"){w=this._serializeFormParams(s);if(w!==""){v+="?"+w;}this.setLocation(v);t=false;}else{w=k.extend({},this._parseFormParams(s));t=this.runRoute(x,v,w,u.get(0));}return(typeof t=="undefined")?false:t;},_serializeFormParams:function(t){var v="",s=t.serializeArray(),u;if(s.length>0){v=this._encodeFormPair(s[0].name,s[0].value);for(u=1;u<s.length;u++){v=v+"&"+this._encodeFormPair(s[u].name,s[u].value);}}return v;},_encodeFormPair:function(s,t){return d(s)+"="+d(t);},_parseFormParams:function(s){var v={},u=s.serializeArray(),t;for(t=0;t<u.length;t++){v=this._parseParamPair(v,u[t].name,u[t].value);}return v;},_parseQueryString:function(v){var x={},u,t,w,s;u=v.match(n);if(u&&u[1]){t=u[1].split("&");for(s=0;s<t.length;s++){w=t[s].split("=");x=this._parseParamPair(x,l(w[0]),l(w[1]||""));}}return x;},_parseParamPair:function(u,s,t){if(typeof u[s]!=="undefined"){if(o(u[s])){u[s].push(t);}else{u[s]=[u[s],t];}}else{u[s]=t;}return u;},_listen:function(s,t){return this.$element().bind([s,this.eventNamespace()].join("."),t);},_unlisten:function(s,t){return this.$element().unbind([s,this.eventNamespace()].join("."),t);}});r.RenderContext=function(s){this.event_context=s;this.callbacks=[];this.previous_content=null;this.content=null;this.next_engine=false;this.waiting=false;};r.RenderContext.prototype=k.extend({},r.Object.prototype,{then:function(u){if(!f(u)){if(typeof u==="string"&&u in this.event_context){var t=this.event_context[u];u=function(v){return t.apply(this.event_context,[v]);};}else{return this;}}var s=this;if(this.waiting){this.callbacks.push(u);}else{this.wait();a.setTimeout(function(){var v=u.apply(s,[s.content,s.previous_content]);if(v!==false){s.next(v);}},0);}return this;},wait:function(){this.waiting=true;},next:function(s){this.waiting=false;if(typeof s!=="undefined"){this.previous_content=this.content;this.content=s;}if(this.callbacks.length>0){this.then(this.callbacks.shift());}},load:function(s,t,v){var u=this;return this.then(function(){var w,x,z,y;if(f(t)){v=t;t={};}else{t=k.extend({},t);}if(v){this.then(v);}if(typeof s==="string"){z=(s.match(/\.json$/)||t.json);w=z?t.cache===true:t.cache!==false;u.next_engine=u.event_context.engineFor(s);delete t.cache;delete t.json;if(t.engine){u.next_engine=t.engine;delete t.engine;}if(w&&(x=this.event_context.app.templateCache(s))){return x;}this.wait();k.ajax(k.extend({url:s,data:{},dataType:z?"json":"text",type:"get",success:function(A){if(w){u.event_context.app.templateCache(s,A);}u.next(A);}},t));return false;}else{if(s.nodeType){return s.innerHTML;}if(s.selector){u.next_engine=s.attr("data-engine");if(t.clone===false){return s.remove()[0].innerHTML.toString();}else{return s[0].innerHTML.toString();}}}});},loadPartials:function(t){var s;if(t){this.partials=this.partials||{};for(s in t){(function(v,u){v.load(t[u]).then(function(w){this.partials[u]=w;});})(this,s);}}return this;},render:function(s,u,v,t){if(f(s)&&!u){return this.then(s);}else{if(f(u)){t=v;v=u;u=null;}else{if(v&&!f(v)){t=v;v=null;}}return this.loadPartials(t).load(s).interpolate(u,s).then(v);}},partial:function(s,u,v,t){if(f(v)){return this.render(s,u,t).swap(v);}else{if(f(u)){return this.render(s,{},v).swap(u);}else{return this.render(s,u,v).swap();}}},send:function(){var u=this,t=e(arguments),s=t.shift();if(o(t[0])){t=t[0];}return this.then(function(v){t.push(function(w){u.next(w);});u.wait();s.apply(s,t);return false;});},collect:function(w,v,s){var u=this;var t=function(){if(f(w)){v=w;w=this.content;}var x=[],y=false;k.each(w,function(z,B){var A=v.apply(u,[z,B]);if(A.jquery&&A.length==1){A=A[0];y=true;}x.push(A);return A;});return y?x:x.join("");};return s?t():this.then(t);},renderEach:function(s,t,u,v){if(o(t)){v=u;u=t;t=null;}return this.load(s).then(function(x){var w=this;if(!u){u=o(this.previous_content)?this.previous_content:[];}if(v){k.each(u,function(y,A){var B={},z=this.next_engine||s;if(t){B[t]=A;}else{B=A;}v(A,w.event_context.interpolate(x,B,z));});}else{return this.collect(u,function(y,A){var B={},z=this.next_engine||s;if(t){B[t]=A;}else{B=A;}return this.event_context.interpolate(x,B,z);},true);}});},interpolate:function(v,u,s){var t=this;return this.then(function(x,w){if(!v&&w){v=w;}if(this.next_engine){u=this.next_engine;this.next_engine=false;}var y=t.event_context.interpolate(x,v,u,this.partials);return s?w+y:y;});},swap:function(s){return this.then(function(t){this.event_context.swap(t,s);return t;}).trigger("changed",{});},appendTo:function(s){return this.then(function(t){k(s).append(t);}).trigger("changed",{});},prependTo:function(s){return this.then(function(t){k(s).prepend(t);}).trigger("changed",{});},replace:function(s){return this.then(function(t){k(s).html(t);}).trigger("changed",{});},trigger:function(s,t){return this.then(function(u){if(typeof t=="undefined"){t={content:u};}this.event_context.trigger(s,t);return u;});}});r.EventContext=function(w,v,t,u,s){this.app=w;this.verb=v;this.path=t;this.params=new r.Object(u);this.target=s;};r.EventContext.prototype=k.extend({},r.Object.prototype,{$element:function(){return this.app.$element(e(arguments).shift());},engineFor:function(u){var t=this,s;if(f(u)){return u;}u=(u||t.app.template_engine).toString();if((s=u.match(/\.([^\.\?\#]+)$/))){u=s[1];}if(u&&f(t[u])){return t[u];}if(t.app.template_engine){return this.engineFor(t.app.template_engine);}return function(v,w){return v;};},interpolate:function(u,v,t,s){return this.engineFor(t).apply(this,[u,v,s]);},render:function(s,u,v,t){return new r.RenderContext(this).render(s,u,v,t);},renderEach:function(s,t,u,v){return new r.RenderContext(this).renderEach(s,t,u,v);},load:function(s,t,u){return new r.RenderContext(this).load(s,t,u);},loadPartials:function(s){return new r.RenderContext(this).loadPartials(s);},partial:function(s,u,v,t){return new r.RenderContext(this).partial(s,u,v,t);},send:function(){var s=new r.RenderContext(this);return s.send.apply(s,arguments);},redirect:function(){var A,y=e(arguments),x=this.app.getLocation(),t=y.length;if(t>1){var w=0,B=[],s=[],v={},z=false;for(;w<t;w++){if(typeof y[w]=="string"){B.push(y[w]);}else{k.extend(v,y[w]);z=true;}}A=B.join("/");if(z){for(var u in v){s.push(this.app._encodeFormPair(u,v[u]));}A+="?"+s.join("&");}}else{A=y[0];}this.trigger("redirect",{to:A});this.app.last_location=[this.verb,this.path];this.app.setLocation(A);if(new RegExp(A).test(x)){this.app.trigger("location-changed");}},trigger:function(s,t){if(typeof t=="undefined"){t={};}if(!t.context){t.context=this;}return this.app.trigger(s,t);},eventNamespace:function(){return this.app.eventNamespace();},swap:function(s,t){return this.app.swap(s,t);},notFound:function(){return this.app.notFound(this.verb,this.path);},json:function(s){return k.parseJSON(s);},toString:function(){return"Sammy.EventContext: "+[this.verb,this.path,this.params].join(" ");}});return r;});})(jQuery,window);