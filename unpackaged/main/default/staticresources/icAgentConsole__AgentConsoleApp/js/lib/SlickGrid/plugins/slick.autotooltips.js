!function($){$.extend(!0,window,{Slick:{AutoTooltips:function(options){var _grid,_defaults={enableForCells:!0,enableForHeaderCells:!1,maxToolTipLength:null};function handleMouseEnter(e){var cell=_grid.getCellFromEvent(e);if(cell){var text,$node=$(_grid.getCellNode(cell.row,cell.cell));$node.innerWidth()<$node[0].scrollWidth?(text=$.trim($node.text()),options.maxToolTipLength&&text.length>options.maxToolTipLength&&(text=text.substr(0,options.maxToolTipLength-3)+"...")):text="",$node.attr("title",text)}}function handleHeaderMouseEnter(e,args){var column=args.column,$node=$(e.target).closest(".slick-header-column");column&&!column.toolTip&&$node.attr("title",$node.innerWidth()<$node[0].scrollWidth?column.name:"")}$.extend(this,{init:function(grid){options=$.extend(!0,{},_defaults,options),_grid=grid,options.enableForCells&&_grid.onMouseEnter.subscribe(handleMouseEnter),options.enableForHeaderCells&&_grid.onHeaderMouseEnter.subscribe(handleHeaderMouseEnter)},destroy:function(){options.enableForCells&&_grid.onMouseEnter.unsubscribe(handleMouseEnter),options.enableForHeaderCells&&_grid.onHeaderMouseEnter.unsubscribe(handleHeaderMouseEnter)}})}}})}(jQuery);