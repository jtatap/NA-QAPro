({
	doInit : function(component, event, helper) {
		var getMessage = component.get("v.messageToShow");
        var getTicketId = component.get("v.ticketid");
        
        getMessage=getMessage.replace("<ticketid>", getTicketId);
        
        component.set("v.finalMessage",getMessage);
        //console.log('Message = '+getMessage);
        //console.log('Ticket Id = '+getTicketId);
        //console.log('Final Message = '+component.get("v.finalMessage"));
	}
})