!function($){var logger=IC_Common.getLogger("Notification");NotificationHandler={_runningTimer:null,_currentStatus:"",toggleTheme:{duration:500,background1:"transition: background .5s ease-in-out;background:purple;color:white",background2:"transition: background .5s ease-in-out;background:#F4C613;color:black"},chatToggleTheme:{duration:500,background1:"transition: background .5s ease-in-out;background:#459F46;color:white",background2:"transition: background .5s ease-in-out;background:#F4C613;color:black"},resourceBase:"",init:function(resourceBase){this.resourceBase=resourceBase,this.agentStateLocalization={Unavailable:IC_Localization.unavailable,Available:IC_Localization.available,"Logging in":IC_Localization.loggingIn,InboundContact:IC_Localization.inboundContact,OutboundContact:IC_Localization.outboundContact,HeldPartyAbandoned:IC_Localization.heldPartyAbandoned,"Logged out":IC_Localization.loggedOut,InboundConsult:IC_Localization.inboundConsult,OutboundConsult:IC_Localization.outboundConsult,Refused:IC_Localization.refused,PromisePending:IC_Localization.commitmentPending,Dialer:IC_Localization.personalConnection,DialerPending:IC_Localization.personalConnectionPending},$(document).on(AgentConsoleDataStore.AgentInfoEvent,$.proxy(this.AgentInfoEvent,this)),$(document).on(AgentConsoleDataStore.ContactEvent,$.proxy(this.onContactUpdate,this)),$(document).on(AgentConsoleDataStore.ChatMsgEvent,$.proxy(this.ChatMsgEvent,this)),$(document).on(AgentConsoleDataStore.RescheduleCommitmentReminderEvent,$.proxy(this.RescheduleCommitmentReminderEvent,this)),$(document).on(AgentConsoleDataStore.ProceedCommitmentReminderEvent,$.proxy(this.ProceedCommitmentReminderEvent,this)),$(document).on(AgentConsoleDataStore.AgentMessageNotifyEvent,$.proxy(this.AgentMsgEvent,this)),this._textTrimmingDiv=$("<div>").css({width:this._availablePhoneButtonTextWidth,position:"absolute",top:-500,"font-size":12.5,overflow:"hidden","white-space":"nowrap"}),this._textTrimmingDiv.appendTo($(document.body)),this.setConsoleButtonStyle("width: 202px;"),this.setConsoleButtonText(IC_Localization.loggedOut),this.setConsoleButtonStyle(this.agentStateColors[IC_Localization.loggedOut]),this._isSupportedIEVersion=IC_Common.isSupportedIEVersion(),this._isSupportedIEVersion&&this._listenforDocumentFocusinIE(),this.audio=new Audio(this.resourceBase+"/audio/notify.mp3")},_textTrimmingDiv:null,_availablePhoneButtonTextWidth:145,_listenforDocumentFocusinIE:function(){var that=this;$(document).on("deactivate",function(){that._isDocumentFocussedinIE=!1}).on("activate",function(){that._isDocumentFocussedinIE=!0})},_isSupportedIEVersion:!1,_isDocumentFocussedinIE:!1,audio:null,agentStateColors:{Unavailable:"background:#E43A36;color:white",Refused:"background:#E43A36;color:white",PromisePending:"background:#E43A36;color:white",HeldPartyAbandoned:"background:#E43A36;color:white",Available:"background:#459F46;color:white","Logging in":"background:#55595C;color:white","Logged out":"background:#55595C;color:white",InboundContact:"background:purple;color:white",InboundConsult:"background:purple;color:white",OutboundContact:"background:#FFFF00;color:black",OutboundConsult:"background:#FFFF00;color:black",Dialer:"background:#0066FF;color:white",DialerPending:"background:#0066FF;color:white",ACW:"background:#FA8C00;color:white"},RescheduleCommitmentReminderEvent:function(){this.showConsoleApp()},ProceedCommitmentReminderEvent:function(){this.showConsoleApp()},getAgentStateColor:function(){var agentInfo=AgentConsoleDataStore.agentInfo;if(agentInfo&&agentInfo.cState){var state=agentInfo.cState.state;return this.isAgentInACWState()?this.agentStateColors.ACW:this.agentStateColors.hasOwnProperty(state)?this.agentStateColors[state]:"background:transparent"}},isAgentInACWState:function(){for(var currentContact,contacts=AgentConsoleDataStore.contacts,i=0,length=contacts.length;i<length;i++)if(currentContact=contacts[i],/Discarded|Disconnected/gi.test(currentContact.status)&&0==currentContact.finalState)return!0;return!1},checkandApplyACWStateColor:function(){this.isAgentInACWState()&&(this.setConsoleButtonText(this.getAgentStatus()),this.setConsoleButtonStyle(this.agentStateColors.ACW))},onContactUpdate:function(event,eventType){for(var contacts=AgentConsoleDataStore.contacts,that=this,currentContact=null,status=null,contactId=null,contactsLength=contacts.length,noticeBody=null,notificationOptions=null,i=0;i<contactsLength;i++)switch(status=(currentContact=contacts[i]).status,contactId=currentContact.id,noticeBody=IC_Localization.incoming,notificationOptions=this.getNotificationOptions("",contactId),currentContact.contactType.toUpperCase()){case"EMAILCONTACTEVENT":if("Active"===status){if(currentContact.isInbound&&localStorage.emailAlertFlashedId!=contactId)return localStorage.emailAlertFlashedId=contactId,notificationOptions.body=IC_Localization.incoming+" "+IC_Localization.email,void this.flashBackground(IC_Localization.incoming+" "+IC_Localization.email,this.toggleTheme.background1,this.toggleTheme.background2,!1,!1,noticeBody,notificationOptions)}else nonIncomingContact("emailAlertFlashedId","Discarded",status);break;case"CHATCONTACTEVENT":if("Incoming"===status)return void(null==this.getChatContactID("Interrupted")&&localStorage.chatAudioNotifiedId!=contactId&&(localStorage.chatAudioNotifiedId=contactId,notificationOptions.body=IC_Localization.incoming+" "+IC_Localization.chat,this.flashBackground(IC_Localization.incoming+" "+IC_Localization.chat,this.toggleTheme.background1,this.toggleTheme.background2,!0,!1,noticeBody,notificationOptions)));nonIncomingContact("chatAudioNotifiedId","Disconnected",status);break;case"WORKITEMCONTACTEVENT":if("Incoming"===status)return void(localStorage.wiAudioNotifiedId!=contactId&&(localStorage.wiAudioNotifiedId=contactId,notificationOptions.body=IC_Localization.incomingWorkItem,this.flashBackground(IC_Localization.incomingWorkItem,this.toggleTheme.background1,this.toggleTheme.background2,!0,!1,noticeBody,notificationOptions)));nonIncomingContact("wiAudioNotifiedId","Disconnected",status);break;case"CALLCONTACTEVENT":if("Consult"==currentContact.type)if("Incoming"===status||"Ringing"===status){if(currentContact.inbound&&localStorage.consultCallAlertFlashedId!=currentContact.id)return localStorage.consultCallAlertFlashedId=currentContact.id,notificationOptions.body=this.getAgentStatus(),void this.flashBackground(this.getAgentStatus(),this.toggleTheme.background1,this.toggleTheme.background2,!0,!1,noticeBody,notificationOptions)}else"Disconnected"===status&&(notificationOptions.body=IC_Localization.call+" Disconnected",this.flashBackground("$Localized:ChatSessionEnded",this.toggleTheme.background1,this.toggleTheme.background2,!0,!1,noticeBody,notificationOptions)),nonIncomingContact("consultCallAlertFlashedId","Disconnected",status);else if("Incoming"===status){if(currentContact.inbound&&localStorage.callAlertFlashedId!=currentContact.id)return localStorage.callAlertFlashedId=currentContact.id,notificationOptions.body=IC_Localization.incoming+" "+IC_Localization.call,void this.flashBackground(IC_Localization.incoming+" "+IC_Localization.call,this.toggleTheme.background1,this.toggleTheme.background2,!1,!1,noticeBody,notificationOptions)}else"Disconnected"===status&&(notificationOptions.body=IC_Localization.call+" Disconnected",this.flashBackground("$Localized:ChatSessionEnded",this.toggleTheme.background1,this.toggleTheme.background2,!0,!1,noticeBody,notificationOptions)),nonIncomingContact("callAlertFlashedId","Disconnected",status);break;case"VOICEMAILCONTACTEVENT":if("Incoming"===status){if(localStorage.voiceMailAlertFlashedId!=currentContact.id)return localStorage.voiceMailAlertFlashedId=currentContact.id,notificationOptions.body=IC_Localization.incoming+" "+IC_Localization.voicemail,void this.flashBackground(IC_Localization.incoming+" "+IC_Localization.voicemail,this.toggleTheme.background1,this.toggleTheme.background2,!1,!1,noticeBody,notificationOptions)}else nonIncomingContact("voiceMailAlertFlashedId","Discarded",status)}function nonIncomingContact(localStorageKey,disconnectStatusVal,status){"Active"===status?that._stopFlashing():status===disconnectStatusVal&&(that.checkandApplyACWStateColor(),localStorage[localStorageKey]=null)}},AgentInfoEvent:function(){IC_Validation.isNotNullOrEmpty(AgentConsoleDataStore.agentInfo.cState)&&this.showState({text:this.getAgentStatus(),background:this.getAgentStateColor()})},getAgentStatus:function(){var agentInfo=AgentConsoleDataStore.agentInfo,statusText=IC_Validation.isNullOrEmpty(agentInfo.cState.reason)?agentInfo.cState.state:agentInfo.cState.reason;return statusText=IC_Validation.isNotNullOrUndefinedString(this.agentStateLocalization[statusText])?this.agentStateLocalization[statusText]:statusText,this.getTrimmedText(this._availablePhoneButtonTextWidth,statusText)},getChatContactID:function(status){for(var contacts=AgentConsoleDataStore.contacts,currentContact=null,i=0,length=contacts.length;i<length;i++)if((currentContact=contacts[i]).status===status&&"CHATCONTACTEVENT"==currentContact.contactType.toUpperCase())return currentContact.id;return null},playNotification:function(){try{var that=this;IC_Validation.isNullOrEmpty(this.audio)?(this.audio=new Audio(this.resourceBase+"/audio/notify.mp3"),this.audio.onloadedmetadata=function(){that.audio.play()}):(0==this.audio.ended&&(this.audio.currentTime=0),this.audio.play())}catch(ex){logger.error("Audio Error",ex.message)}},ChatMsgEvent:function(){var contactId=localStorage.chatMsgUpdatedContactId;if(contactId){var messages=AgentConsoleDataStore.chatMsg[contactId];if(messages&&messages.length>0){var lastMessage=messages[messages.length-1],noticeBody=IC_Localization.visualNoticeAgentMessage;if(notificationOptions=this.getNotificationOptions(lastMessage.msg,contactId),localStorage.notifiedMessageId!=lastMessage.id&&"Client"==lastMessage.type){var isPausedChat=contactId!=this.getChatContactID("Active");this.flashBackground(this.getAgentStatus(),this.chatToggleTheme.background1,this.chatToggleTheme.background2,!1,isPausedChat,noticeBody,notificationOptions),localStorage.notifiedMessageId=lastMessage.id}else"$Localized:ChatSessionEnded"===lastMessage.msg&&(notificationOptions.body=IC_Localization.chatSessionEnded,this.flashBackground(lastMessage.msg,this.chatToggleTheme.background1,this.chatToggleTheme.background2,!1,isPausedChat,IC_Localization.chat,notificationOptions))}}},AgentMsgEvent:function(){var contactId=localStorage.chatMsgUpdatedContactId,noticeBody=IC_Localization.newAgentMessage;notificationOptions=this.getNotificationOptions(IC_Localization.agentMessageNotify,contactId),this.flashBackground(IC_Localization.newAgentMessage,this.chatToggleTheme.background1,this.chatToggleTheme.background2,!1,!1,noticeBody,notificationOptions)},getNotificationOptions:function(body,contactId){return{dir:"auto",body:body,tag:contactId,icon:"",requireInteraction:!1}},_stopFlashing:function(){localStorage.needFlashing="false",clearInterval(this._runningTimer),this.setConsoleButtonText(this.getAgentStatus()),this.setConsoleButtonStyle(this.getAgentStateColor())},flashBackground:function(text,background1,background2,maintainTextinEnd,isPausedChat,msg,options){var that=this;setTimeout(function(){that.showConsoleApp()},2e3),that._stopFlashing(),that.setConsoleButtonText(text);var userCreds=localStorage.customVariables?JSON.parse(localStorage.customVariables).UserAVSettings:void 0,audioSet=userCreds?userCreds.agentAudioSettings:void 0,visualSet=userCreds?userCreds.agentVisualSettings:void 0,aNotify=!0,vNotify=!0;if("$Localized:ChatSessionEnded"===text?(aNotify=audioSet&&audioSet.EndChatOrCall,vNotify=visualSet&&visualSet.EndChatOrCall):text&&text.includes(IC_Localization.incoming)?(aNotify=audioSet&&audioSet.Contacts,vNotify=visualSet&&visualSet.Contacts):text&&text.includes(IC_Localization.newAgentMessage)?(aNotify=audioSet&&audioSet.AgentMessages,vNotify=visualSet&&visualSet.AgentMessages):(aNotify=audioSet&&audioSet.ChatMessages,vNotify=visualSet&&visualSet.ChatMessages),this._isDocumentFocussed())isPausedChat&&aNotify&&this.playNotification(),maintainTextinEnd||that.setConsoleButtonText(that.getAgentStatus());else{if(localStorage.needFlashing="true",aNotify&&this.playNotification(),vNotify)if(!Notification in window)logger.error("Notification Error","Browser doesn't support notifications");else if("granted"==Notification.permission){new Notification(msg,options).onclick=function(){window.parent.focus(),this.close()}}else"granted"!==Notification.permission&&window.Notification.requestPermission(function(res){if("granted"==res)new Notification(msg,options)});var isBackground1=!0;that._runningTimer=setInterval(function(){if(that._isDocumentFocussed()||"false"==localStorage.needFlashing)that._stopFlashing(),maintainTextinEnd&&that.setConsoleButtonText(text);else{var background=isBackground1?background2:background1;that.setConsoleButtonStyle(background),isBackground1=!isBackground1}},that.toggleTheme.duration)}},_isDocumentFocussed:function(){var popoutWindow=IC_Common.toBoolean(localStorage.isPopupOpen)?window.open("","inContactAgentConsolePopout"):null;return popoutWindow&&IC_Validation.isNullOrEmpty(popoutWindow.location.hostname)&&(localStorage.isPopupOpen="false",popoutWindow.close(),popoutWindow=null),!(!popoutWindow||0!=popoutWindow.closed||!popoutWindow.document.hasFocus())||(this._isSupportedIEVersion?0!=document.hasFocus()&&("hidden"!=document.msVisibilityState&&this._isDocumentFocussedinIE):document.hasFocus()||popoutWindow&&0==popoutWindow.closed&&popoutWindow.document.hasFocus())},showConsoleApp:function(){sforce.console.isCustomConsoleComponentHidden(function(result){result.success&&result.hidden&&sforce.console.setCustomConsoleComponentVisible("visible")})},showState:function(state){logger.debug("showState>> state: "+JSON.stringify(state)),state.text!==this._currentStatus&&(this._currentStatus=state.text,this._stopFlashing(),this.setConsoleButtonText(state.text),this.setConsoleButtonStyle(state.background))},setConsoleButtonText:function(text){logger.debug("setConsoleButtonText >> text: "+text),sforce.console.setCustomConsoleComponentButtonText(text,function(result){logger.debug("setConsoleButtonText << result: "+JSON.stringify(result))})},setConsoleButtonStyle:function(style){logger.debug("setConsoleButtonStyle >> style: "+style),sforce.console.setCustomConsoleComponentButtonStyle(style,function(result){logger.debug("setConsoleButtonStyle << result: "+JSON.stringify(result))})},getTrimmedText:function(availableTextWidth,text){var jqElement=this._textTrimmingDiv,DOMelement=jqElement[0];this._textTrimmingDiv.text(text);try{if(DOMelement.scrollWidth>availableTextWidth)for(var j=text.length-1;j>0;j--)if(text=text.substr(0,j),jqElement.text(text+" ..."),DOMelement.scrollWidth<=availableTextWidth)return jqElement.text()}catch(error){return text}return text}},omniChannel={init:function(){var that=this;AgentConsoleDataStore.isScc(function(isInConsole){AgentConsoleDataStore.isInConsoleView&&that.refresh()})},omniChannelMappings:{master:"",presenceMappings:[]},lastAgentSetStatus:{status:"",reason:""},lastOmniSetStatus:{status:"",reason:""},refresh:function(){this.reset();var that=this;this.loadOmniChannelMappingDetails(function(settings){if("incontact"==settings.master)that.setIncontactasMaster(settings.presenceMappings);else{if("salesforce"!=settings.master)return;that.setSaleforceasMaster(settings.presenceMappings)}that.listenAgentStateEventChange(),that.listenOmniStateEventChange(),that.listenContactEventChange()})},listenContactEventChange:function(){var that=this;$(document).on(AgentConsoleDataStore.ContactEvent,function(){AgentConsoleDataStore.getNonParkedContactsCount()>0&&that.loadOmniChannelMappingDetails(function(settings){"incontact"==settings.master&&(that.omniChannelMappings={master:"incontact",presenceMappings:settings.presenceMappings},that.setOmniChannelAsBusy())})})},listenAgentStateEventChange:function(){var that=this;$(document).on(AgentConsoleDataStore.AgentInfoEvent,function(){var cState=AgentConsoleDataStore.agentInfo.cState;that.lastAgentSetStatus={status:cState.state,reason:cState.reason},that.loadOmniChannelMappingDetails(function(settings){"incontact"==settings.master&&that.setIncontactasMaster(settings.presenceMappings)})})},listenOmniStateEventChange:function(){var that=this;sforce.console.addEventListener(sforce.console.ConsoleEvent.PRESENCE.STATUS_CHANGED,function(result){AgentConsoleDataStore.isSessionStarted()&&(that.lastOmniSetStatus={status:result.statusId,reason:""},that.loadOmniChannelMappingDetails(function(settings){"salesforce"==settings.master&&that.setSaleforceasMaster(settings.presenceMappings)}))})},reset:function(){this.omniChannelMappings={master:"",presenceMappings:[]}},loadOmniChannelMappingDetails:function(callback){AgentConsoleDataStore.getOmniChannelMappingDetails(callback)},setSaleforceasMaster:function(presenceMappings){this.omniChannelMappings={master:"salesforce",presenceMappings:presenceMappings};var that=this;AgentConsoleDataStore.getServicePresenceStatusId(function(statusId){statusId&&that.changeIncontactAgentState(statusId)})},setIncontactasMaster:function(presenceMappings){this.omniChannelMappings={master:"incontact",presenceMappings:presenceMappings},this.changeOmniChannelPresence()},changeIncontactAgentState:function(currentStatusId){if("salesforce"==this.omniChannelMappings.master&&!IC_Validation.isNullOrEmpty(AgentConsoleDataStore.agentInfo.cState)){var i,presenceMappings=this.omniChannelMappings.presenceMappings,reason="",status="Unavailable";for(i=0;i<presenceMappings.length;i++)if(currentStatusId==presenceMappings[i].sfStatus.substr(0,15)){"Available"==(reason=presenceMappings[i].inContactStatus)?(status="Available",reason=""):"Unavailable"==reason&&(reason=""),setAgentState(status,reason);break}}function setAgentState(status,reason){var cState=AgentConsoleDataStore.agentInfo.cState;cState.state==status&&cState.reason==reason||(this.lastSetStatus={status:status,reason:reason},AgentConsoleDataStore.setAgentState(status,reason))}},changeOmniChannelPresence:function(){var agentCurrentState=AgentConsoleDataStore.agentInfo.cState;if("incontact"==this.omniChannelMappings.master&&!IC_Validation.isNullOrEmpty(agentCurrentState)){var i,status=agentCurrentState.state,reason=agentCurrentState.reason?agentCurrentState.reason:status,isAcw=agentCurrentState.acw,that=this,presenceMappings=this.omniChannelMappings.presenceMappings;if("Available"==status||"Unavailable"==status&&!0!==isAcw)for(i=0;i<presenceMappings.length;i++)if(reason==presenceMappings[i].inContactStatus){setServicePresenceStatus(presenceMappings[i].sfStatus.substr(0,15)||"");break}}function setServicePresenceStatus(id){that.lastOmniSetStatus.status!=id&&0!=id.length&&(this.lastSetStatus={status:id,reason:""},AgentConsoleDataStore.setServicePresenceStatus(id,function(){}))}},setOmniChannelAsBusy:function(){if("incontact"==this.omniChannelMappings.master){var i,presenceMappings=this.omniChannelMappings.presenceMappings;for(i=0;i<presenceMappings.length;i++)if("Unavailable"==presenceMappings[i].inContactStatus){AgentConsoleDataStore.setServicePresenceStatus(presenceMappings[i].sfStatus.substr(0,15),function(){});break}}}}}(jQuery);