!function($){$.widget("AgentConsole.agentReports",{options:{container:null,resourceBase:""},_init:function(){document.getElementById("renderTextSize")||$('<div id="renderTextSize"/>').addClass("renderTextSize").appendTo("Body")},_create:function(){var headerText,agentReports_Perf,performanceDiv,performanceLabelDiv,contactsHandledDiv,agentReports_Prod,productivityDiv,productivityLabelDiv,prodHandledDiv,availaleIconDiv,workingIconDiv,unavailableIconDiv,parent=this.element;this.resourceBase=this.options.resourceBase;var that=this;parent.addClass("agentReports"),$('<span class="dialogHidden">'+IC_Localization.begin+" "+IC_Localization.agentReports+"</span>").appendTo(parent),this.rootPanel=$('<div class="modalDialogBackground"/>').appendTo(parent),this.headerPanel=$('<div id="agentReports_HeaderPanel" class="modalDialogHeader" tabindex="-1" aria-labelledby="agentReports_Header" role="dialog"/>').appendTo(this.rootPanel),headerText=$('<div id = "agentReports_Header" class="modalDialogHeaderText"/>').appendTo(this.headerPanel),IC_Common.setTextWithEllipsis(headerText,IC_Localization.agentReports,150,!0),this.closeBtn=$('<div id = "reportsCloseId" title="'+IC_Localization.close+'"  role="button" aria-label = "'+IC_Localization.close+'" tabindex = "0" />').appendTo(this.headerPanel),this.closeBtnIcon=$("<img/>").addClass("closeBtnIcon").attr("src",this.resourceBase+"/css/images/section-close.png").attr("alt",IC_Localization.close+" "+IC_Localization.agentReports).appendTo(this.closeBtn),this.closeBtn.on("click",$.proxy(this.closeBtnClick,this)),IC_Common.enterKeyPress(this.closeBtn,function(){that.closeBtnClick()}),IC_Common.setFocusToCloseIcon(this.closeBtn,this.closeBtnIcon,"closeBtnFocus","closeBtnIconFocus"),this.loadingDiv=$('<div class="loadingDiv"/>').appendTo(this.rootPanel),this.loadingIcn=$('<div class="icn"><div id = "loadingDivId" class="loadingTxt textEllipsis">'+IC_Localization.loading+"</div></div>").appendTo(this.loadingDiv),agentReports_Perf=$('<div tabindex = "0"/>').appendTo(this.rootPanel),performanceDiv=$('<div class="performanceDiv"/>').appendTo(agentReports_Perf),this.agentPerformanceDiv=$('<div class="agentPerformanceDiv" id="agentPerformanceDivId"/>').appendTo(performanceDiv),performanceLabelDiv=$('<div class="performanceLabelDiv"/>').appendTo(this.agentPerformanceDiv),IC_Common.setTextWithEllipsis(performanceLabelDiv,IC_Localization.performance,100,!0),this.performanceValueInPerc=$("<div>").css({width:"20px",float:"left"}).appendTo(this.agentPerformanceDiv),this.perfRightArrow=$("<img/>").addClass("rightArrowImg").attr("src",this.resourceBase+"/css/images/arrowright-enabled.png").attr("alt",IC_Localization.navigateToAgentPerf).appendTo(this.agentPerformanceDiv),contactsHandledDiv=$('<div class="contactsHandledDiv" id="contactsHandledDivId"/>').appendTo(performanceDiv),this.totContactsDiv=$('<div class="totContactsHandledDiv"/>').appendTo(contactsHandledDiv),this.totContacts=$("<div>").addClass("totalContactsDiv").appendTo(this.totContactsDiv),this.totContactsLbl=$("<div>").appendTo(this.totContactsDiv),IC_Common.setTextWithEllipsis(this.totContactsLbl,IC_Localization.overallContactsHandled,165,!0),this.ibHandledDiv=$("<div>").css({float:"left"}).appendTo(contactsHandledDiv),this.inboundHandled=$("<div>").addClass("totalContactsDiv").appendTo(this.ibHandledDiv),this.inboundHandledLbl=$("<div>").css({float:"left","margin-right":"15px"}).appendTo(this.ibHandledDiv),IC_Common.setTextWithEllipsis(this.inboundHandledLbl,IC_Localization.inbound,60,!0),this.obHandledDiv=$("<div>").appendTo(contactsHandledDiv),this.outboundHandled=$("<div>").addClass("totalContactsDiv").appendTo(this.obHandledDiv),this.outboundHandledLbl=$("<div>").css({float:"left"}).appendTo(this.obHandledDiv),IC_Common.setTextWithEllipsis(this.outboundHandledLbl,IC_Localization.outbound,60,!0),agentReports_Prod=$('<div tabindex = "0"/>').appendTo(this.rootPanel),productivityDiv=$('<div class="productivityDiv">').appendTo(agentReports_Prod),this.agentProductivityDiv=$('<div class="agentProductivityDiv" id="agentProductivityDivId">').appendTo(productivityDiv),productivityLabelDiv=$('<div class="productivityLabelDiv">').appendTo(this.agentProductivityDiv),IC_Common.setTextWithEllipsis(productivityLabelDiv,IC_Localization.productivity,100,!0),this.productivityValueInPerc=$("<div>").css({width:"20px",float:"left"}).appendTo(this.agentProductivityDiv),this.prodRightArrow=$("<img/>").addClass("rightArrowImg").attr("src",this.resourceBase+"/css/images/arrowright-enabled.png").attr("alt",IC_Localization.navigateToAgentProd).appendTo(this.agentProductivityDiv),prodHandledDiv=$('<div class="prodHandledDiv" id="prodHandledDivId">').appendTo(productivityDiv),this.availaleStateDiv=$('<div class="statesDiv" id="availaleStateDivId">').appendTo(prodHandledDiv),availaleIconDiv=$("<div>").appendTo(this.availaleStateDiv),$("<img/>").addClass("state-available").attr({src:this.resourceBase+"/css/images/ap-state-available.png",alt:IC_Localization.agentTimeAvailable,title:IC_Localization.agentTimeAvailable}).appendTo(availaleIconDiv),this.availaleInPerc=$("<div>").appendTo(this.availaleStateDiv),this.workingStateDiv=$('<div class="statesDiv" id="workingStateDivId">').appendTo(prodHandledDiv),workingIconDiv=$("<div>").appendTo(this.workingStateDiv),$("<img/>").addClass("state-working").attr({src:this.resourceBase+"/css/images/ap-state-outbound.png",alt:IC_Localization.agentTimeWorking,title:IC_Localization.agentTimeWorking}).appendTo(workingIconDiv),this.workingInPerc=$("<div>").appendTo(this.workingStateDiv),this.unavailableStateDiv=$('<div class="statesDiv" id="unavailableStateDivId">').css("margin-right","0px").appendTo(prodHandledDiv),unavailableIconDiv=$("<div>").appendTo(this.unavailableStateDiv),$("<img/>").addClass("state-unavailable").attr({src:this.resourceBase+"/css/images/ap-state-unavailable.png",alt:IC_Localization.agentTimeUnavailable,title:IC_Localization.agentTimeUnavailable}).appendTo(unavailableIconDiv),this.unavailableInPerc=$("<div>").appendTo(this.unavailableStateDiv),$('<span class="dialogHidden">'+IC_Localization.end+" "+IC_Localization.agentReports+"</span>").appendTo(parent),agentReports_Perf.hoverfn(function(){that.mouseEnterButton(this)},function(){that.mouseLeaveButton(this)}),agentReports_Prod.hoverfn(function(){that.mouseEnterButton(this)},function(){that.mouseLeaveButton(this)}),IC_Common.setFocusToElement(agentReports_Perf,"reportsFocus"),IC_Common.enterKeyPress(agentReports_Perf,function(){that.onClickAgentReportsPerformance()}),IC_Common.setFocusToElement(agentReports_Prod,"reportsFocus"),IC_Common.enterKeyPress(agentReports_Prod,function(){that.onClickAgentReportsProductivity()}),agentReports_Perf.on("click",$.proxy(this.onClickAgentReportsPerformance,this)),agentReports_Prod.on("click",$.proxy(this.onClickAgentReportsProductivity,this)),this.perfRightArrow.on("click",$.proxy(this.onClickAgentReportsPerformance,this)),this.prodRightArrow.on("click",$.proxy(this.onClickAgentReportsProductivity,this))},mouseEnterButton:function(that){var btnDiv=$(that);(IC_Common.isButtonEnabled(btnDiv)||IC_Common.isButtonSelected(btnDiv))&&btnDiv.addClass("reportsGradient")},mouseLeaveButton:function(that){$(that).removeClass("reportsGradient")},onClickAgentReportsPerformance:function(){this.options.container.showAgentPerformance(this.agentPerformance,this.teamPerformance,"Performance")},onClickAgentReportsProductivity:function(){this.options.container.showAgentPerformance(this.agentPerformance,this.teamPerformance,"Productivity")},setVisibility:function(visibility){this.loadingDiv.fadeIn(500),!0===visibility&&this.getAgentReportsHistory()},setFocusToReportsHeader:function(){this.headerPanel.trigger("focus")},getAgentReportsHistory:function(){var from,to,startDate,endDate,minutes,today,that=this;today=new Date,startDate=new Date(today.getFullYear(),today.getMonth(),today.getDate(),0,0,0),(minutes=today.getMinutes())>0&&minutes<15?today.setMinutes(0):minutes>15&&minutes<30?today.setMinutes(15):minutes>30&&minutes<45?today.setMinutes(30):minutes>45&&today.setMinutes(45),today.setSeconds(0),today.setMinutes(today.getMinutes()+15),endDate=today,from=IC_Common.toISODateString(startDate),to=IC_Common.toISODateString(endDate),this.options.container.getAgentPerformanceHistory(from,to,function(data){that.agentPerformance=data,that.options.container.getTeamPerformanceHistory(from,to,function(data){that.teamPerformance=data,that.updateAgentReports(that.agentPerformance,that.teamPerformance)})})},updateAgentReports:function(agentPer,teamPer){var agentData=agentPer,teamData=teamPer,productivityAgentAvailableMilliseconds=0,productivityAgentUnavailableMilliseconds=0,productivityAgentWorkingMilliseconds=0,productivityAgentTotalMilliseconds=(productivityAgentUnavailableMilliseconds=0,0),productivityTeamAvailableMilliseconds=0,productivityTeamWorkingMilliseconds=0,productivityTeamUnavailableMilliseconds=0,productivityTeamTotalMilliseconds=0,productivityAgentAvailablePercentage=0,productivityAgentUnavailablePercentage=0;this.performancePercentage=0,this.productivityAgentWorkingPercentage=0,this.productivityTeamWorkingPercentage=0,this.loadingDiv.fadeOut(500),IC_Validation.isNotNullOrUndefinedString(teamData)&&"0"!==teamData.inboundHandled&&Math.round(agentData.inboundHandled/teamData.inboundHandled*100),IC_Validation.isNotNullOrUndefinedString(teamData)&&"0"!==teamData.outboundHandled&&Math.round(agentData.outboundHandled/teamData.outboundHandled*100),IC_Validation.isNotNullOrUndefinedString(teamData)&&"0"!==teamData.totalHandled&&(this.performancePercentage=Math.round(agentData.totalHandled/teamData.totalHandled*100)),IC_Validation.isNotNullOrUndefinedString(agentData)&&(productivityAgentAvailableMilliseconds=IC_Common.getMilliseconds(agentData.availableTime),productivityAgentUnavailableMilliseconds=IC_Common.getMilliseconds(agentData.unavailableTime),productivityAgentWorkingMilliseconds=IC_Common.getMilliseconds(agentData.inboundTalkTime)+IC_Common.getMilliseconds(agentData.outboundTalkTime),productivityAgentUnavailableMilliseconds=IC_Common.getMilliseconds(agentData.unavailableTime),productivityAgentTotalMilliseconds=IC_Common.getMilliseconds(agentData.loginTime)),IC_Validation.isNotNullOrUndefinedString(teamData)&&(productivityTeamAvailableMilliseconds=IC_Common.getMilliseconds(teamData.availableTime),productivityTeamWorkingMilliseconds=IC_Common.getMilliseconds(teamData.inboundTalkTime)+IC_Common.getMilliseconds(teamData.outboundTalkTime),productivityTeamUnavailableMilliseconds=IC_Common.getMilliseconds(teamData.unavailableTime),productivityTeamTotalMilliseconds=IC_Common.getMilliseconds(teamData.loginTime)),productivityAgentTotalMilliseconds>=1e3&&(productivityAgentAvailablePercentage=Math.round(productivityAgentAvailableMilliseconds/productivityAgentTotalMilliseconds*100),productivityAgentUnavailablePercentage=Math.round(productivityAgentUnavailableMilliseconds/productivityAgentTotalMilliseconds*100),this.productivityAgentWorkingPercentage=Math.round(productivityAgentWorkingMilliseconds/productivityAgentTotalMilliseconds*100)),productivityTeamTotalMilliseconds>=1e3&&(Math.round(productivityTeamAvailableMilliseconds/productivityTeamTotalMilliseconds*100),Math.round(productivityTeamUnavailableMilliseconds/productivityTeamTotalMilliseconds*100),this.productivityTeamWorkingPercentage=Math.round(productivityTeamWorkingMilliseconds/productivityTeamTotalMilliseconds*100)),this.performanceValueInPerc.text(this.performancePercentage+"%"),this.inboundHandled.text(agentData.inboundHandled),this.outboundHandled.text(agentData.outboundHandled),this.totContacts.text(agentData.totalHandled),this.agentPerformanceDiv.attr("aria-label",this.performancePercentage+"% "+IC_Localization.performance),this.totContactsDiv.attr("aria-label",IC_Localization.overallContactsHandled+" "+agentData.totalHandled),this.ibHandledDiv.attr("aria-label",agentData.inboundHandled+" "+IC_Localization.inbound),this.obHandledDiv.attr("aria-label",agentData.outboundHandled+" "+IC_Localization.outbound),this.productivityValueInPerc.text(this.productivityAgentWorkingPercentage+"%"),this.availaleInPerc.text(productivityAgentAvailablePercentage+"%"),this.workingInPerc.text(this.productivityAgentWorkingPercentage+"%"),this.unavailableInPerc.text(productivityAgentUnavailablePercentage+"%"),this.agentProductivityDiv.attr("aria-label",this.productivityAgentWorkingPercentage+"% "+IC_Localization.productivity),this.availaleStateDiv.attr("aria-label",productivityAgentAvailablePercentage+"% "+IC_Localization.agentTimeAvailable),this.workingStateDiv.attr("aria-label",this.productivityAgentWorkingPercentage+"% "+IC_Localization.agentTimeWorking),this.unavailableStateDiv.attr("aria-label",productivityAgentUnavailablePercentage+"% "+IC_Localization.agentTimeUnavailable),this.textMask(agentData.totalHandled,this.totContactsLbl,IC_Localization.overallContactsHandled,165),this.textMask(agentData.inboundHandled,this.inboundHandledLbl,IC_Localization.inbound,70),this.textMask(agentData.outboundHandled,this.outboundHandledLbl,IC_Localization.outbound,70)},closeBtnClick:function(){this.options.container.closeAgentReportsAndShowHome(),IC_Common.removeFocusFromCloseIcon(this.closeBtnIcon,"closeBtnIconFocus")},textMask:function(getObjText,objName,setObjText,divWidth){var width;$("#renderTextSize").text(getObjText),width=divWidth-$("#renderTextSize").width(),IC_Common.setTextWithEllipsis(objName,setObjText,width,!0),$("#renderTextSize").text("")},updatePanelHeight:function(isDialerPanel,isShowIndicator){var loadingHeight=92;loadingHeight=isDialerPanel||isShowIndicator?loadingHeight-1:loadingHeight,loadingHeight=isDialerPanel&&isShowIndicator?loadingHeight-1:loadingHeight,this.loadingDiv.css("height",loadingHeight+"%")}})}(jQuery);