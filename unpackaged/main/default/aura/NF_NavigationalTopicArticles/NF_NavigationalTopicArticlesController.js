({
    init : function(component, event, helper) {
        // console.log('1');
         helper.fetchNavigationalTopic(component, event); 
     },
     handleClick: function(component, event, helper) {
		var buttonClicked = event.getSource().get('v.value');
		//console.log(buttonClicked);
		var divContainer = component.find('expandContainer');
		//console.log(divContainer);
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