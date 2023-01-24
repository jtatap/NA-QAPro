({
	fetchNavigationalTopic : function(component, event) {
        var self = this;
        //console.log('2');
        var articalDisplayed = component.get('v.articalDisplayed');
		var action = component.get("c.getArticles");
        //console.log('3');
        //action.setParams({ articalDisplayed : articalDisplayed }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //console.log(response.getReturnValue()); Sort_Order__c
                var navigationTopicList = response.getReturnValue();
                console.log(navigationTopicList);
                if(navigationTopicList != null && navigationTopicList != undefined){
                    navigationTopicList.forEach(function (element) {
                        element.iconName = 'utility:chevronright';
                        if(element.knowledgeArticleVerList != null && element.knowledgeArticleVerList != undefined){
                            var sortedList = self.sortData(component, 'Sort_Order__c', 'asc',element.knowledgeArticleVerList); 
                            //console.log(sortedList);
                            var sortedFilled = [];
                            var temp = [];
                            sortedList.forEach(function(element1){
                                if(element1['Sort_Order__c'] == undefined || element1['Sort_Order__c'] == null){
                                    temp.push(element1);
                                }else{
                                    sortedFilled.push(element1);
                                }
                            });
                            //console.log('work');
                            //console.log(sortedFilled); 
                            //console.log(temp);
                            var sortedFinal = sortedFilled.concat(temp);
                            //console.log(sortedFinal);
                            if(sortedFinal != null && sortedFinal != undefined){
                                element.knowledgeArticleVerList = sortedFinal.length >= articalDisplayed ? element.knowledgeArticleVerList.slice(0,articalDisplayed) : element.knowledgeArticleVerList.slice(0,sortedFinal.length);
                            }
                            
                        }
                    });
                }
                var newList = [];
                
               component.set('v.topicList',navigationTopicList);
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                        self.showToast(component, 'Error', 'error',errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },
    showToast : function(component, title, type,message) { 
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type, // 'error', 'warning', 'success', or 'info'. The default is 'other', which is styled like an 'info' toast and doesn’t display an icon
            "message": message 
        });
        toastEvent.fire();
        
    },
    sortData: function (component , fieldName, sortDirection,data) {
        //var data = component.get("v.data");
        var reverse = sortDirection !== 'asc';

        data = Object.assign([],
            data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
        );
        //component.set("v.data", data);
        return data;
    },
    sortBy: function (field, reverse, primer) {
        var key = primer
            ? function(x) {
        return primer(x[field]);
        }
                    : function(x) {
        return x[field];
        };

        return function (a, b) {
            var A = key(a);
            var B = key(b);
            return reverse * ((A > B) - (B > A));
        };
    },
})