!function($){$.extend(!0,window,{Slick:{RowMoveManager:function(options){var _grid,_canvas,_dragging,_self=this,_handler=new Slick.EventHandler,_defaults={cancelEditOnDrag:!1};function handleDragInit(e,dd){e.stopImmediatePropagation()}function handleDragStart(e,dd){var cell=_grid.getCellFromEvent(e);if(options.cancelEditOnDrag&&_grid.getEditorLock().isActive()&&_grid.getEditorLock().cancelCurrentEdit(),_grid.getEditorLock().isActive()||!/move|selectAndMove/.test(_grid.getColumns()[cell.cell].behavior))return!1;_dragging=!0,e.stopImmediatePropagation();var selectedRows=_grid.getSelectedRows();0!=selectedRows.length&&-1!=$.inArray(cell.row,selectedRows)||(selectedRows=[cell.row],_grid.setSelectedRows(selectedRows));var rowHeight=_grid.getOptions().rowHeight;dd.selectedRows=selectedRows,dd.selectionProxy=$("<div class='slick-reorder-proxy'/>").css("position","absolute").css("zIndex","99999").css("width",$(_canvas).innerWidth()).css("height",rowHeight*selectedRows.length).appendTo(_canvas),dd.guide=$("<div class='slick-reorder-guide'/>").css("position","absolute").css("zIndex","99998").css("width",$(_canvas).innerWidth()).css("top",-1e3).appendTo(_canvas),dd.insertBefore=-1}function handleDrag(e,dd){if(_dragging){e.stopImmediatePropagation();var top=e.pageY-$(_canvas).offset().top;dd.selectionProxy.css("top",top-5);var insertBefore=Math.max(0,Math.min(Math.round(top/_grid.getOptions().rowHeight),_grid.getDataLength()));if(insertBefore!==dd.insertBefore){var eventData={rows:dd.selectedRows,insertBefore:insertBefore};!1===_self.onBeforeMoveRows.notify(eventData)?(dd.guide.css("top",-1e3),dd.canMove=!1):(dd.guide.css("top",insertBefore*_grid.getOptions().rowHeight),dd.canMove=!0),dd.insertBefore=insertBefore}}}function handleDragEnd(e,dd){if(_dragging&&(_dragging=!1,e.stopImmediatePropagation(),dd.guide.remove(),dd.selectionProxy.remove(),dd.canMove)){var eventData={rows:dd.selectedRows,insertBefore:dd.insertBefore};_self.onMoveRows.notify(eventData)}}$.extend(this,{onBeforeMoveRows:new Slick.Event,onMoveRows:new Slick.Event,init:function(grid){options=$.extend(!0,{},_defaults,options),_canvas=(_grid=grid).getCanvasNode(),_handler.subscribe(_grid.onDragInit,handleDragInit).subscribe(_grid.onDragStart,handleDragStart).subscribe(_grid.onDrag,handleDrag).subscribe(_grid.onDragEnd,handleDragEnd)},destroy:function(){_handler.unsubscribeAll()}})}}})}(jQuery);