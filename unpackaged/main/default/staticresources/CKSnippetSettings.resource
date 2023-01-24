
window._snapinsSnippetSettingsFile = (function() {
	console.log("NEW Snippet settings file v10 loaded. ");
	        embedded_svc.snippetSettingsFile.avatarImgURL = $A.get('$Resource.CK_Chat') +'/img/Sales_Expert.svg';
            embedded_svc.snippetSettingsFile.chatbotAvatarImgURL = $A.get('$Resource.CK_Chat') +'/img/CK_Assistant.svg';

	   console.log(embedded_svc.snippetSettingsFile.avatarImgURL);
	   console.log(embedded_svc.snippetSettingsFile.chatbotAvatarImgURL);
	console.log("Embedded Service Info\n" + embedded_svc)
	embedded_svc.snippetSettingsFile.extraPrechatFormDetails = 
	[
	{
	 "label": "Origin",
	 "fieldName": "Origin",
	 "value": "Chat",
	 "displayToAgent": false
	},{
                  "label": "Page URL",
                  "value": location.href && location.href.substring(0,255),
                  "displayToAgent": false,
                  "transcriptFields": ['URL__c']
              }];
	})();