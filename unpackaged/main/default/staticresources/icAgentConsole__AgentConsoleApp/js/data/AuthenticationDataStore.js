!function($){var logger=IC_Common.getLogger("AuthenticationDataStore");AuthenticationDataStore={authUrl:"",authMode:"",OAuthInfo:{},JSONEncoded:"application/json; charset=UTF-8",agentInfo:{},customDomainAuthInfo:{},openIdAuthRequestStateParam:"classicAgent",idpType:"OpenID Connect",_LightningHeight:646,_LightningWidth:202,_init:function(){logger.setLevel(log4javascript.getLevelByName("ALL"))},isTokenExpired:function(){if(IC_Validation.isNotNullOrUndefinedString(localStorage.OAuthInfo)&&"{}"!==localStorage.OAuthInfo){var oAuthInfo=IC_Common.parseJSON(localStorage.OAuthInfo);return((new Date).getTime()-oAuthInfo.accessTokenTime)/1e3>=oAuthInfo.expiresIn-120}return!0},getEvolveLoginPageUrl:function(redirectUrl){var evolvePageUrl=this.callCenterSettings.evolveAuthUrl+"/login/#/?redirectURL="+encodeURIComponent(redirectUrl+"?state="+this.openIdAuthRequestStateParam);return logger.debug("Evolve page url "+evolvePageUrl),evolvePageUrl},getSSOLoginPageUrl:function(customDomainAuthInfo,redirectUrl){var authRequestParams={response_type:"code",client_id:customDomainAuthInfo.openIdClientId,redirect_uri:redirectUrl,scope:"openid email profile",state:this.openIdAuthRequestStateParam};return IC_Validation.isNotNullOrEmpty(customDomainAuthInfo.openIdAuthRequestParams)&&$.each(customDomainAuthInfo.openIdAuthRequestParams,function(key,value){authRequestParams[key]=value}),IC_Common.appendQueryString(customDomainAuthInfo.openIdAuthorize,authRequestParams)},validateCallbackRequest:function(state){return this.openIdAuthRequestStateParam===state},getCustomDomainAuthInfo:function(onSuccess,onError){var that=this,customDomain=this.callCenterSettings.icCustomDomain;if(logger.debug("inContact custom domain for SSO "+customDomain),IC_Validation.isNotNullOrEmpty(customDomain)){var url=-1!==(customDomain=customDomain.toLowerCase()).indexOf("https://")?customDomain+"/inContact/Login.aspx":"https://"+customDomain+"/inContact/Login.aspx";IC_Ajax.xmlHttpRequest("GET",url,{Accept:"application/json"},null,function(data,statusCode,statusText){200===statusCode?(that.customDomainAuthInfo=data,onSuccess(that.customDomainAuthInfo)):onError(statusCode,statusText,null)},onError,null,null,null)}else logger.error("inContact custom domain for SSO is empty")},getCallCenterSettings:function(sfSessionId,callback){if(localStorage.sfSession!==sfSessionId&&(localStorage.callCenterSettings="{}",localStorage.authCode="",localStorage.sfSession=sfSessionId),IC_Validation.isNotNullOrUndefinedString(localStorage.callCenterSettings)&&"{}"!==localStorage.callCenterSettings)this.callCenterSettings=IC_Common.parseJSON(localStorage.callCenterSettings),callback(),this.setSoftphoneHeightWidth();else{this.callCenterSettings={icAuthorizationUrl:"https://api.incontact.com/InContactAuthorizationServer/Token",authMode:"inContact",evolveAuthUrl:"https://auth.nice-incontact.com",evolveNotificationUrl:"https://na1-ws.nice-incontact.com/ws/notifications",evolveWebServerUrl:"https://na1.nice-incontact.com",lightningHeight:this._LightningHeight,lightningWidth:this._LightningWidth};var that=this;AgentConsoleSalesforce.getCallCenterSettings(function(settings){IC_Validation.isValidObject(settings.result)&&(IC_Validation.isNotNullOrEmpty(settings.result.icAuthorizationUrl)&&(that.callCenterSettings.icAuthorizationUrl=settings.result.icAuthorizationUrl),IC_Validation.isNotNullOrEmpty(settings.result.authMode)&&(that.callCenterSettings.authMode=settings.result.authMode),IC_Validation.isNotNullOrEmpty(settings.result.evolveAuthUrl)&&(that.callCenterSettings.evolveAuthUrl=settings.result.evolveAuthUrl),IC_Validation.isNotNullOrEmpty(settings.result.evolveNotificationUrl)&&(that.callCenterSettings.evolveNotificationUrl=settings.result.evolveNotificationUrl),IC_Validation.isNotNullOrEmpty(settings.result.evolveWebServerUrl)&&(that.callCenterSettings.evolveWebServerUrl=settings.result.evolveWebServerUrl),IC_Validation.isNotNullOrEmpty(settings.result.lightningHeight)&&(that.callCenterSettings.lightningHeight=settings.result.lightningHeight),IC_Validation.isNotNullOrEmpty(settings.result.lightningWidth)&&(that.callCenterSettings.lightningWidth=settings.result.lightningWidth),IC_Validation.isNotNullOrEmpty(settings.result.icCustomDomain)&&(that.callCenterSettings.icCustomDomain=settings.result.icCustomDomain)),localStorage.callCenterSettings=JSON.stringify(that.callCenterSettings),localStorage.lightningHeight=that.callCenterSettings.lightningHeight,localStorage.lightningWidth=that.callCenterSettings.lightningWidth,callback(),that.setSoftphoneHeightWidth()})}},setSoftphoneHeightWidth:function(){IC_Validation.isNotNullOrEmpty(localStorage.lightningHeight)&&IC_Validation.isNotNullOrEmpty(localStorage.lightningWidth)&&AgentConsoleSalesforce.setSoftphonePanelLayout(localStorage.lightningHeight,localStorage.lightningWidth)},isEvolve:function(){return IC_Validation.isNotNullOrUndefinedString(this.callCenterSettings.authMode)&&"evolve"===this.callCenterSettings.authMode.toLowerCase()},isSSO:function(){return IC_Validation.isNotNullOrUndefinedString(this.callCenterSettings.icCustomDomain)},getAuthMode:function(){return IC_Validation.isNotNullOrUndefinedString(this.callCenterSettings.authMode)?this.callCenterSettings.authMode.toLowerCase():"incontact"},updateNewAccessToken:function(data){this.OAuthInfo.accessToken=data.access_token,this.OAuthInfo.baseUri=IC_Common.trimUrl(data.resource_server_base_uri),this.OAuthInfo.refreshToken=data.refresh_token,this.OAuthInfo.refreshTokenUri=data.refresh_token_server_uri,this.OAuthInfo.expiresIn=data.expires_in,this.OAuthInfo.accessTokenTime=(new Date).getTime(),localStorage.agentId=data.agent_id,this.updateAuthInfo()},updateEvolveAccessToken:function(response){this.OAuthInfo.accessToken=response.accessToken,this.OAuthInfo.baseUri=IC_Common.trimUrl(response.resource_server_base_uri),this.OAuthInfo.refreshToken=response.refreshToken,this.OAuthInfo.refreshTokenUri=this.callCenterSettings.evolveAuthUrl+"/public/user/refresh",this.OAuthInfo.expiresIn=response.expiresIn,this.OAuthInfo.accessTokenTime=(new Date).getTime(),this.updateAuthInfo()},whoAmI:function(token,onSuccess,onError){var url=this.callCenterSettings.icAuthorizationUrl+"/WhoAmI",payload={token:token};this.postRequestEvolve(url,this.JSONEncoded,JSON.stringify(payload),function(response,status,statusText){logger.trace("whoAmI success. status: "+status+" statusText: "+statusText,JSON.stringify(response)),onSuccess(response)},function(status,statusText,response){logger.error("whoAmI failed. status: "+status+" statusText: "+statusText,JSON.stringify(response)),onError(status,statusText,response)})},updateAuthInfo:function(){localStorage.OAuthInfo=JSON.stringify(this.OAuthInfo)},upsertUserCredentials:function(username,password,isAutoLogin,callback){AgentConsoleSalesforce.upsertUserCredentials(username,password,isAutoLogin,callback)},getAccessToken:function(tokenUrl,authCode,idpType,busNo,redirectUri,onSuccess,onError){logger.trace("getAccessToken >>> tokenUrl:"+tokenUrl+" authCode:"+authCode),AgentConsoleSalesforce.authenticate(tokenUrl,this.getAuthMode(),authCode,idpType,busNo,redirectUri,function(result){IC_Validation.isNullOrEmpty(result.error)?200===result.statusCode?onSuccess(IC_Common.parseJSON(result.data)):onError(result.statusCode,result.statusText,result.data):onError(0,result.error)})},cx1Authenticate:function(sfUserId,authCode,onSuccess,onError){localStorage.sfUserId!==sfUserId&&(this.flushWebStorage(),localStorage.sfUserId=sfUserId);var that=this;this.getAccessToken(this.callCenterSettings.evolveAuthUrl+"/public/user/token",authCode,null,null,null,function(response){var cx1Response={};cx1Response.accessToken=response.accessToken,cx1Response.expiresIn=response.accessTokenExpiry,cx1Response.refreshToken=response.refreshToken,that.whoAmI(response.accessToken,function(response){localStorage.agentId=response.agent_id,cx1Response.resource_server_base_uri=response.resource_server_base_uri,that.updateEvolveAccessToken(cx1Response),that.agentInfo.webServer=IC_Common.parseUrl(response.resource_server_base_uri).hostname,localStorage.agentInfo=JSON.stringify(that.agentInfo),onSuccess()},function(status,statusText,response){logger.error("cx1AuthToken<<whoami status:"+status+" statusText:"+statusText+" data:"+JSON.stringify(response)),that.flushWebStorage(),onError(status,statusText,response)})},function(status,statusText,response){logger.error("cx1AuthToken<<getAccessToken status:"+status+" statusText:"+statusText+" data:"+JSON.stringify(response)),onError(status,statusText,response)}),localStorage.authCode=""},postRequestEvolve:function(url,contentType,data,onSuccess,onError,withCred){var errorHandler=onError;"function"!=typeof errorHandler&&(errorHandler=$.proxy(this.onDataStoreError,this)),IC_Ajax.xmlHttpRequest("POST",url,{"Content-Type":contentType},data,onSuccess,errorHandler,null,null,withCred)},cx1Logout:function(onSuccess,onError){url=this.callCenterSettings.evolveAuthUrl+"/public/user/logout",this.postRequestEvolve(url,this.JSONEncoded,null,function(response,status,statusText){logger.debug("CXone logout:- status:"+status+" statusText:"+statusText,response),"function"==typeof onSuccess&&onSuccess()},function(status,statusText,response){logger.error("CXone logout:- status:"+status+" statusText:"+statusText,response),"function"==typeof onError&&onError()},!0),AgentConsoleSalesforce.closeCXone()},flushWebStorage:function(){logger.trace("flushWebStorage triggered"),localStorage.OAuthInfo="{}",localStorage.icSessionId="",localStorage.lastIcSessionIdUpdate="0",localStorage.allUnavailableList="{}",localStorage.allUnavailableListUpdateTime=(new Date).getTime(),localStorage.allSkillList="{}",localStorage.allSkillListUpdateTime=(new Date).getTime(),localStorage.teamUnavailableList="[]",localStorage.teamUnavailableListUpdateTime=(new Date).getTime(),localStorage.agentSkillList="[]",localStorage.agentSkillListUpdateTime=(new Date).getTime(),localStorage.agentListMap="{}",localStorage.agentSkillMap="{}",localStorage.agentSkillMapUpdateTime=(new Date).getTime(),localStorage.teamList="[]",localStorage.teamListUpdateTime=(new Date).getTime(),localStorage.contacts="[]",localStorage.errorList="[]",localStorage.sfResult="[]",localStorage.customVariables="{}",localStorage.skillQueueMap="{}",localStorage.skillQueueMapUpdateTime=(new Date).getTime(),localStorage.addressBookList="[]",localStorage.serverTimestampOnStart="",localStorage.localTimestampOnStart="",localStorage.pcQueueContacts="[]",localStorage.isSkillRunningLow="true",localStorage.chatMsg="{}",localStorage.chatMsgUpdatedContactId="",localStorage.priority="[]",localStorage.category="[]",localStorage.agentMessage=JSON.stringify(this.agentMessage),localStorage.indicators="",localStorage.skillRealTimeEventCount="0",localStorage.isLoaded="false",localStorage.lastDispContactId="",localStorage.lastAttentedContactId="",localStorage.persistEmailInfo="[]",localStorage.quickReply="[]",localStorage.vmPlayBack="{}",localStorage.permissionsList="[]",localStorage.fileExtList="[]",localStorage.promiseKeeperList="[]",localStorage.isMailSending="false",localStorage.timeZoneList="[]",localStorage.parkedEmailList="[]",localStorage.parkEmailId="",localStorage.persistChatEditorSetting="{}",localStorage.commitmentReminder=null,localStorage.openedCommitmentReminderWindow="",localStorage.ProceedCommitmentReminderPending="0",localStorage.isRescheduleInProgress="false",localStorage.brandingProfile="{}",localStorage.previewParkedEmailId="",localStorage.clickedAddresbookEmail="",localStorage.sfMode="",localStorage.lastNewSkillQueueUpdateTime="0",localStorage.pcPreviewNotes="{}",localStorage.skillTagsMap="{}",localStorage.tagsLoadedContacts="[]",localStorage.tagsUpdatedContact="{}",localStorage.featuresList="[]",localStorage.wfoUrl="",localStorage.isScreenAgentConnected="false",localStorage.getNextEventFailureCount="0",localStorage.maxConference="3",localStorage.removeItem("nextEventUpdated"),localStorage.isIntegratedSoftphone=null,localStorage.agentSettings="{}",localStorage.agentId="",localStorage.isSessionStarted="false",localStorage.connectedAudioCodeServer=null,localStorage.agentLegCall=null,localStorage.agentLegAcceptRejectActions=""},redirectToLoginPage:function(disableAutoLogin){var icAgentUrl=window.location.href.split("?")[0],icLoginPageUrl=location.protocol+"//"+location.host+"/apex/authenticate",queryParams=IC_Common.parseQueryString(window.location.search);IC_Validation.isNotNullOrEmpty(queryParams)&&(icAgentUrl=IC_Common.appendQueryString(icAgentUrl,queryParams),queryParams.redirectURL=icAgentUrl,queryParams.disableAutoLogin=disableAutoLogin,icLoginPageUrl=IC_Common.appendQueryString(icLoginPageUrl,queryParams)),window.location.href=icLoginPageUrl},getOAuthInfo:function(){var oAuthInfo=null;return IC_Validation.isNotNullOrUndefinedString(localStorage.OAuthInfo)&&"{}"!==localStorage.OAuthInfo&&(oAuthInfo=IC_Common.parseJSON(localStorage.OAuthInfo),this.OAuthInfo=oAuthInfo),oAuthInfo},refreshAccessToken:function(tokenUrl,refreshToken,onSuccess,onError){logger.trace("refreshAccessToken >>> tokenUrl:"+tokenUrl),AgentConsoleSalesforce.refreshToken(tokenUrl,this.getAuthMode(),refreshToken,function(result){if(IC_Validation.isNullOrEmpty(result.error)&&200===result.statusCode&&!IC_Validation.isNullOrEmpty(result.data)){var data=IC_Common.parseJSON(result.data);IC_Validation.isValidObject(data)?onSuccess(data):onError()}else onError()})},getAccessTokenByRefreshToken:function(onSuccess,onError){var that=this;if(IC_Validation.isNullOrEmpty(that.getOAuthInfo()))return logger.debug("getAccessTokenByRefreshToken >>Token information not available"),void onError();this.refreshAccessToken(this.OAuthInfo.refreshTokenUri,this.OAuthInfo.refreshToken,function(data){if(that.isEvolve()){var response={};response.accessToken=data.token,response.refreshToken=data.refreshToken,response.resource_server_base_uri=that.OAuthInfo.baseUri,response.expiresIn=data.tokenExpirationTimeSec,that.updateEvolveAccessToken(response)}else that.updateNewAccessToken(data);onSuccess()},onError)},downloadLog:function(){logger.trace("downloadLog fired");var pattern=/^icLog_/,key="",i=0,logData="",keyArray=[];for(i=0;i<sessionStorage.length;i++)key=sessionStorage.key(i),!0===pattern.test(key)&&keyArray.push(parseInt(key.replace("icLog_","")));for(keyArray.sort(function(a,b){return a-b}),i=0;i<keyArray.length;i++)key="icLog_"+keyArray[i],logData+=sessionStorage.getItem(key);AgentConsoleSalesforce.downloadLog(logData)}},AuthenticationDataStore._init()}(jQuery);