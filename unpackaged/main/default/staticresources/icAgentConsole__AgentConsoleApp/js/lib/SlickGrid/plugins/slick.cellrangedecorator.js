!function($){$.extend(!0,window,{Slick:{CellRangeDecorator:function(grid,options){var _elem;options=$.extend(!0,{},{selectionCssClass:"slick-range-decorator",selectionCss:{zIndex:"9999",border:"2px dashed red"},offset:{top:-1,left:-1,height:-2,width:-2}},options),$.extend(this,{show:function(range){_elem||(_elem=$("<div></div>",{css:options.selectionCss}).addClass(options.selectionCssClass).css("position","absolute").appendTo(grid.getCanvasNode()));var from=grid.getCellNodeBox(range.fromRow,range.fromCell),to=grid.getCellNodeBox(range.toRow,range.toCell);return _elem.css({top:from.top+options.offset.top,left:from.left+options.offset.left,height:to.bottom-from.top+options.offset.height,width:to.right-from.left+options.offset.width}),_elem},hide:function(){_elem&&(_elem.remove(),_elem=null)}})}}})}(jQuery);