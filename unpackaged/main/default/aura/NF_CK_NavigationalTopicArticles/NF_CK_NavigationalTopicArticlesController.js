({
    init : function(component, event, helper) {
        helper.fetchNavigationalTopic(component, event); 
        var numberOfColumns = component.get('v.numberOfColumns');
        switch ( numberOfColumns ) {
            case numberOfColumns=2:
                component.set('v.columnSizeClass', 'slds-col slds-size_1-of-1 slds-medium-size_6-of-12' ); 
                break;
            case numberOfColumns=3:
                component.set('v.columnSizeClass','slds-col slds-size_1-of-1 slds-medium-size_4-of-12'); 
                break;
            case numberOfColumns=4:
                component.set('v.columnSizeClass','slds-col slds-size_1-of-1 slds-medium-size_3-of-12'); 
                break;
        }
     },
     handleClick: function(component, event, helper) {
		var buttonClicked = event.getSource().get('v.value');
		var divContainer = component.find('expandContainer');
		$A.util.toggleClass(divContainer[buttonClicked], 'showElement'); 
		var newList = [];
		var navigationTupicList = component.get('v.topicList');
		if(navigationTupicList != null && navigationTupicList != undefined && navigationTupicList != ''){
			navigationTupicList.forEach(function(element,index){
				if(index == buttonClicked){
					if(element.iconName == 'utility:chevronright'){
						element.iconName = 'utility:chevrondown';
					}else{
						element.iconName = 'utility:chevronright';
					}
				}
				newList.push(element);
			});
		}
	   component.set('v.topicList',newList); 
	},
})