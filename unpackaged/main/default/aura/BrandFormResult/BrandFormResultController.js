({
	doInit : function(component, event, helper) {
		var getMessage = component.get("v.messageToShow");
        var getTicketId = component.get("v.ticketid");
        
        getMessage=getMessage.replace("<ticketid>", getTicketId);
        
        component.set("v.finalMessage",getMessage);
        }
})