({
	handleBrandNameApplicationEvent : function(component, event, helper) {
		console.log('event handled');
        var gotBrandName = event.getParam("brandName");
        console.log('Event Brand Name = '+gotBrandName);

	}
})