({
    doInit : function(cmp, event, helper) {
        console.log('inside transactiondetail init');
        var transItems = cmp.get("v.pointWrapper").transactionItemList;
        cmp.set("v.numRecords",transItems.length);
        
    },
    
	handleCloseModal : function(component, event, helper) {
        component.find("overlayTransactionDetail").notifyClose();
        //cmp.set("v.pointWrapper",null);
		//alert('Closed');
	},
})