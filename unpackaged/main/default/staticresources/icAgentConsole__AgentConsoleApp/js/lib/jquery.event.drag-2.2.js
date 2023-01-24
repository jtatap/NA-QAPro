!function($){$.fn.drag=function(str,arg,opts){var type="string"==typeof str?str:"",fn=$.isFunction(str)?str:$.isFunction(arg)?arg:null;return 0!==type.indexOf("drag")&&(type="drag"+type),opts=(str==fn?arg:opts)||{},fn?this.bind(type,opts,fn):this.trigger(type)};var $event=$.event,$special=$event.special,drag=$special.drag={defaults:{which:1,distance:0,not:":input",handle:null,relative:!1,drop:!0,click:!1},datakey:"dragdata",noBubble:!0,add:function(obj){var data=$.data(this,drag.datakey),opts=obj.data||{};data.related+=1,$.each(drag.defaults,function(key,def){void 0!==opts[key]&&(data[key]=opts[key])})},remove:function(){$.data(this,drag.datakey).related-=1},setup:function(){if(!$.data(this,drag.datakey)){var data=$.extend({related:0},drag.defaults);$.data(this,drag.datakey,data),$event.add(this,"touchstart mousedown",drag.init,data),this.attachEvent&&this.attachEvent("ondragstart",drag.dontstart)}},teardown:function(){($.data(this,drag.datakey)||{}).related||($.removeData(this,drag.datakey),$event.remove(this,"touchstart mousedown",drag.init),drag.textselect(!0),this.detachEvent&&this.detachEvent("ondragstart",drag.dontstart))},init:function(event){if(!drag.touched){var results,dd=event.data;if(!(0!=event.which&&dd.which>0&&event.which!=dd.which)&&!$(event.target).is(dd.not)&&(!dd.handle||$(event.target).closest(dd.handle,event.currentTarget).length)&&(drag.touched="touchstart"==event.type?this:null,dd.propagates=1,dd.mousedown=this,dd.interactions=[drag.interaction(this,dd)],dd.target=event.target,dd.pageX=event.pageX,dd.pageY=event.pageY,dd.dragging=null,results=drag.hijack(event,"draginit",dd),dd.propagates))return(results=drag.flatten(results))&&results.length&&(dd.interactions=[],$.each(results,function(){dd.interactions.push(drag.interaction(this,dd))})),dd.propagates=dd.interactions.length,!1!==dd.drop&&$special.drop&&$special.drop.handler(event,dd),drag.textselect(!1),drag.touched?$event.add(drag.touched,"touchmove touchend",drag.handler,dd):$event.add(document,"mousemove mouseup",drag.handler,dd),!(!drag.touched||dd.live)&&void 0}},interaction:function(elem,dd){var offset=$(elem)[dd.relative?"position":"offset"]()||{top:0,left:0};return{drag:elem,callback:new drag.callback,droppable:[],offset:offset}},handler:function(event){var dd=event.data;switch(event.type){case!dd.dragging&&"touchmove":event.preventDefault();case!dd.dragging&&"mousemove":if(Math.pow(event.pageX-dd.pageX,2)+Math.pow(event.pageY-dd.pageY,2)<Math.pow(dd.distance,2))break;event.target=dd.target,drag.hijack(event,"dragstart",dd),dd.propagates&&(dd.dragging=!0);case"touchmove":event.preventDefault();case"mousemove":if(dd.dragging){if(drag.hijack(event,"drag",dd),dd.propagates){!1!==dd.drop&&$special.drop&&$special.drop.handler(event,dd);break}event.type="mouseup"}case"touchend":case"mouseup":default:drag.touched?$event.remove(drag.touched,"touchmove touchend",drag.handler):$event.remove(document,"mousemove mouseup",drag.handler),dd.dragging&&(!1!==dd.drop&&$special.drop&&$special.drop.handler(event,dd),drag.hijack(event,"dragend",dd)),drag.textselect(!0),!1===dd.click&&dd.dragging&&$.data(dd.mousedown,"suppress.click",(new Date).getTime()+5),dd.dragging=drag.touched=!1}},hijack:function(event,type,dd,x,elem){if(dd){var result,ia,callback,orig={event:event.originalEvent,type:event.type},mode=type.indexOf("drop")?"drag":"drop",i=x||0,len=isNaN(x)?dd.interactions.length:x;event.type=type,event.originalEvent=null,dd.results=[];do{if(ia=dd.interactions[i]){if("dragend"!==type&&ia.cancelled)continue;callback=drag.properties(event,dd,ia),ia.results=[],$(elem||ia[mode]||dd.droppable).each(function(p,subject){if(callback.target=subject,event.isPropagationStopped=function(){return!1},!1===(result=subject?$event.dispatch.call(subject,event,callback):null)?("drag"==mode&&(ia.cancelled=!0,dd.propagates-=1),"drop"==type&&(ia[mode][p]=null)):"dropinit"==type&&ia.droppable.push(drag.element(result)||subject),"dragstart"==type&&(ia.proxy=$(drag.element(result)||ia.drag)[0]),ia.results.push(result),delete event.result,"dropinit"!==type)return result}),dd.results[i]=drag.flatten(ia.results),"dropinit"==type&&(ia.droppable=drag.flatten(ia.droppable)),"dragstart"!=type||ia.cancelled||callback.update()}}while(++i<len);return event.type=orig.type,event.originalEvent=orig.event,drag.flatten(dd.results)}},properties:function(event,dd,ia){var obj=ia.callback;return obj.drag=ia.drag,obj.proxy=ia.proxy||ia.drag,obj.startX=dd.pageX,obj.startY=dd.pageY,obj.deltaX=event.pageX-dd.pageX,obj.deltaY=event.pageY-dd.pageY,obj.originalX=ia.offset.left,obj.originalY=ia.offset.top,obj.offsetX=obj.originalX+obj.deltaX,obj.offsetY=obj.originalY+obj.deltaY,obj.drop=drag.flatten((ia.drop||[]).slice()),obj.available=drag.flatten((ia.droppable||[]).slice()),obj},element:function(arg){if(arg&&(arg.jquery||1==arg.nodeType))return arg},flatten:function(arr){return $.map(arr,function(member){return member&&member.jquery?$.makeArray(member):member&&member.length?drag.flatten(member):member})},textselect:function(bool){$(document)[bool?"unbind":"bind"]("selectstart",drag.dontstart).css("MozUserSelect",bool?"":"none"),document.unselectable=bool?"off":"on"},dontstart:function(){return!1},callback:function(){}};drag.callback.prototype={update:function(){$special.drop&&this.available.length&&$.each(this.available,function(i){$special.drop.locate(this,i)})}};var $dispatch=$event.dispatch;$event.dispatch=function(event){if(!($.data(this,"suppress."+event.type)-(new Date).getTime()>0))return $dispatch.apply(this,arguments);$.removeData(this,"suppress."+event.type)};var touchHooks=$event.fixHooks.touchstart=$event.fixHooks.touchmove=$event.fixHooks.touchend=$event.fixHooks.touchcancel={props:"clientX clientY pageX pageY screenX screenY".split(" "),filter:function(event,orig){if(orig){var touched=orig.touches&&orig.touches[0]||orig.changedTouches&&orig.changedTouches[0]||null;touched&&$.each(touchHooks.props,function(i,prop){event[prop]=touched[prop]})}return event}};$special.draginit=$special.dragstart=$special.dragend=drag}(jQuery);