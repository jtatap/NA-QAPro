jQuery,PersistentQueue=function(name){var queue=[],queueName=name+"_queue",isDestroyed=!1;function persistQueue(){if(!0===isDestroyed)throw new Error("Queue has been destroyed");localStorage.setItem(queueName,JSON.stringify(queue))}function onQueueUpdate(e){if(e||(e=window.event),e.key===queueName)try{queue=IC_Common.parseJSON(localStorage.getItem(queueName))}catch(e){}}this.isEmpty=function(){return 0==queue.length},this.enqueue=function(item){queue.push(item),persistQueue()},this.dequeue=function(){if(0!=queue.length){var item=queue[0];return queue=queue.slice(1),persistQueue(),item}},this.peek=function(){return queue.length>0?queue[0]:void 0},this.clear=function(){queue=[],persistQueue()},this.destroy=function(clearStorage){return isDestroyed=!0,window.removeEventListener?window.removeEventListener("storage",onQueueUpdate,!1):window.detachEvent("onstorage",onQueueUpdate),!0===clearStorage&&localStorage.removeItem(queueName),null},function(){if(null==name||void 0==name||0===name.trim().length)throw new Error("Queue name is invalid");if(null!=localStorage.getItem(queueName))try{queue=IC_Common.parseJSON(localStorage.getItem(queueName))}catch(e){persistQueue()}else persistQueue();window.addEventListener?window.addEventListener("storage",onQueueUpdate,!1):window.attachEvent("onstorage",onQueueUpdate)}()},String.prototype.trim||(String.prototype.trim=function(){return this.replace(/^\s+|\s+$/g,"")});