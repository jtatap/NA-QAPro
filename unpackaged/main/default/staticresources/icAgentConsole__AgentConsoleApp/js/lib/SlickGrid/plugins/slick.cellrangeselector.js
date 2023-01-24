!function($){$.extend(!0,window,{Slick:{CellRangeSelector:function(options){var _grid,_currentlySelectedRange,_canvas,_dragging,_decorator,_self=this,_handler=new Slick.EventHandler,_defaults={selectionCss:{border:"2px dashed blue"}};function handleDragInit(e,dd){e.stopImmediatePropagation()}function handleDragStart(e,dd){var cell=_grid.getCellFromEvent(e);if(!1!==_self.onBeforeCellRangeSelected.notify(cell)&&_grid.canCellBeSelected(cell.row,cell.cell)&&(_dragging=!0,e.stopImmediatePropagation()),_dragging){_grid.focus();var start=_grid.getCellFromPoint(dd.startX-$(_canvas).offset().left,dd.startY-$(_canvas).offset().top);return dd.range={start:start,end:{}},_currentlySelectedRange=dd.range,_decorator.show(new Slick.Range(start.row,start.cell))}}function handleDrag(e,dd){if(_dragging){e.stopImmediatePropagation();var end=_grid.getCellFromPoint(e.pageX-$(_canvas).offset().left,e.pageY-$(_canvas).offset().top);_grid.canCellBeSelected(end.row,end.cell)&&(dd.range.end=end,_currentlySelectedRange=dd.range,_decorator.show(new Slick.Range(dd.range.start.row,dd.range.start.cell,end.row,end.cell)))}}function handleDragEnd(e,dd){_dragging&&(_dragging=!1,e.stopImmediatePropagation(),_decorator.hide(),_self.onCellRangeSelected.notify({range:new Slick.Range(dd.range.start.row,dd.range.start.cell,dd.range.end.row,dd.range.end.cell)}))}$.extend(this,{init:function(grid){options=$.extend(!0,{},_defaults,options),_decorator=options.cellDecorator||new Slick.CellRangeDecorator(grid,options),_canvas=(_grid=grid).getCanvasNode(),_handler.subscribe(_grid.onDragInit,handleDragInit).subscribe(_grid.onDragStart,handleDragStart).subscribe(_grid.onDrag,handleDrag).subscribe(_grid.onDragEnd,handleDragEnd)},destroy:function(){_handler.unsubscribeAll()},getCellDecorator:function(){return _decorator},getCurrentRange:function(){return _currentlySelectedRange},onBeforeCellRangeSelected:new Slick.Event,onCellRangeSelected:new Slick.Event})}}})}(jQuery);