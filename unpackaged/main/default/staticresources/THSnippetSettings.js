// THSnippetSettings
window._snapinsSnippetSettingsFile = (function () {
	console.log("NEW Snippet settings file v10 loaded. ");   // Logs that the snippet settings file was loaded successfully
	console.log("Embedded Service Info\n" + embedded_svc)
	embedded_svc.snippetSettingsFile.extraPrechatFormDetails =
		[
			{
				"label": "Origin",
				"fieldName": "Origin",
				"value": "Chat",
				"displayToAgent": false
			}, {
				"label": "Page URL",
				"value": location.href && location.href.substring(0, 255),
				"displayToAgent": false,
				"transcriptFields": ['URL__c']
			}];

	embedded_svc.snippetSettingsFile.extraPrechatInfo = [{
		"entityFieldMaps": [{
			"doCreate": false,
			"doFind": false,
			"fieldName": "LastName",
			"isExactMatch": true,
			"label": "Last Name"
		}, {
			"doCreate": false,
			"doFind": false,
			"fieldName": "FirstName",
			"isExactMatch": true,
			"label": "First Name"
		}],
		"entityName": "Contact"
	}];
	embedded_svc.snippetSettingsFile.avatarImgURL = $A.get('$Resource.TH_Chat') + '/img/live_agent_icon.png';
	embedded_svc.snippetSettingsFile.chatbotAvatarImgURL = $A.get('$Resource.TH_Chat') + '/img/FLAG_32x32.svg';
})();