({
    init : function(component, event, helper) {
        helper.fetchNavigationalTopic(component, event); 
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