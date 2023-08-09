({
    fetchNavigationalTopic : function(component, event) {
        var self = this;
        var articalDisplayed = component.get('v.articalDisplayed');
        var success = String($A.get("$Label.c.Success1"));
        var error = String($A.get("$Label.c.Error1"));
        var action = component.get("c.getArticles");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === success) {
                var navigationTopicList = response.getReturnValue();
                console.log(navigationTopicList);
                if(navigationTopicList != null && navigationTopicList != undefined){
                    navigationTopicList.forEach(function (element) {
                        element.iconName = 'utility:chevronright';
                        if(element.knowledgeArticleVerList != null && element.knowledgeArticleVerList != undefined){
                            var sortedList = self.sortData(component, 'Sort_Order__c', 'asc',element.knowledgeArticleVerList); 
                            var sortedFilled = [];
                            var temp = [];
                            sortedList.forEach(function(element1){
                                if(element1['Sort_Order__c'] == undefined || element1['Sort_Order__c'] == null){
                                    temp.push(element1);
                                }else{
                                    sortedFilled.push(element1);
                                }
                            });
                            var sortedFinal = sortedFilled.concat(temp);
                            if(sortedFinal != null && sortedFinal != undefined){
                                element.knowledgeArticleVerList = sortedFinal.length >= articalDisplayed ? element.knowledgeArticleVerList.slice(0,articalDisplayed) : element.knowledgeArticleVerList.slice(0,sortedFinal.length);
                            }
                        }
                    });
                }
                var newList = [];
                component.set('v.topicList',navigationTopicList);
            }else if (state === error) {
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
        var reverse = sortDirection !== 'asc';
        
        data = Object.assign([],
                             data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
                            );
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