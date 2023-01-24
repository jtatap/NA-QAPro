!function($){$.widget("AgentConsole.evolveSchedule",{options:{container:null,resourceBase:""},_create:function(){var headerText,parent=this.element;this.resourceBase=this.options.resourceBase,parent.addClass("evolveSchedule"),$('<span class="dialogHidden">'+IC_Localization.begin+" "+IC_Localization.schedule+"</span>").appendTo(parent),this.rootPanel=$('<div class="modalDialogBackground"/>').appendTo(parent),this.headerPanel=$('<div class="modalDialogHeader" tabindex="-1" aria-labelledby="schedule_Header" role="dialog"/>').appendTo(this.rootPanel),headerText=$('<div id = "schedule_Header" class="modalDialogHeaderText"/>').appendTo(this.headerPanel),IC_Common.setTextWithEllipsis(headerText,IC_Localization.schedule,150,!0),this.closeBtn=$('<div id = "schedule_CloseBtnId" title="'+IC_Localization.close+'" aria-label = "'+IC_Localization.close+'" role="button" tabindex = "0"/>').appendTo(this.headerPanel),this.closeBtnIcon=$("<img/>").addClass("closeBtnIcon").attr("src",this.resourceBase+"/css/images/section-close.png").attr("alt",IC_Localization.close+" "+IC_Localization.schedule).appendTo(this.closeBtn),this.closeBtn.on("click",$.proxy(this.closeBtnClick,this)),IC_Common.enterKeyPress(this.closeBtn,function(){that.closeBtnClick()}),IC_Common.setFocusToCloseIcon(this.closeBtn,this.closeBtnIcon,"closeBtnFocus","closeBtnIconFocus"),createNew=$('<div class="newBtnDiv">').css("padding","0px 7px 5px 7px").appendTo(this.rootPanel),newBtnDiv=$('<div class="btnDivEnable btnStyle" id = "newCommitmentBtnId" tabindex="0"></div>').on("click",$.proxy(this.createNewCommitment,this)).appendTo(createNew),newBtn=$('<div class="newBtn"></div>').appendTo(newBtnDiv),IC_Common.setTextWithEllipsis(newBtn,IC_Localization.new,30),$("<img/>").addClass("newBtnIcon").attr("src",this.resourceBase+"/css/images/arrow-right.png").attr("alt",IC_Localization.newCommitment).appendTo(newBtnDiv),newBtnDiv.hoverfn(IC_Common.mouseEnterButton,IC_Common.mouseLeaveButton),IC_Common.enterKeyPress(newBtnDiv,function(){that.createNewCommitment()}),IC_Common.setFocusToElement(newBtnDiv,"element-focus"),this.loadingDiv=$('<div class="loadingDiv"/>').appendTo(this.rootPanel),this.loadingIcn=$('<div class="icn"><div id = "loadingDivId" class="loadingTxt textEllipsis">'+IC_Localization.loading+"</div></div>").appendTo(this.loadingDiv),$("<div></div>").css("border-top","1px solid #D1D1D1").appendTo(this.rootPanel),this.noSchedule=$('<div id="noSchedule" class = "noSchedule"/>').appendTo(this.rootPanel),this.listSchedule=$('<div id = "schedulePanelId" class="schedulePanel"/>').appendTo(this.rootPanel),this.openWFMDiv=$('<div id="openWFMDivId" class="openWFM" />').appendTo(this.rootPanel),this.openWFMBtn=$('<div id = "schedule_openWFMBtnId" title="'+IC_Localization.openWFM+'" aria-label = "'+IC_Localization.openWFM+'" role="button" tabindex = "0"/>').appendTo(this.openWFMDiv),this.openWFMBtnIcon=$("<img/>").addClass("openWFMIcon").attr("src",this.resourceBase+"/css/images/openWFM.png").attr("alt",IC_Localization.openWFM).appendTo(this.openWFMBtn),openWFMTxt=$('<div class="openWFMTxt"/>').appendTo(this.openWFMDiv),IC_Common.setTextWithEllipsis(openWFMTxt,IC_Localization.openWFM,60),this.openWFMDiv.on("click",$.proxy(this.openWFMClick,this)),this.evolveSchedules={},this.commitmentsForMe=[]},_init:function(){this.localeDateFormat=this.options.container.options.localeDateFormat.replace("yy","yyyy")},closeBtnClick:function(){this.options.container.closeEvolveScheduleAndShowHome(),IC_Common.removeFocusFromCloseIcon(this.closeBtnIcon,"closeBtnIconFocus")},setVisibility:function(visibility,isEvolveWFMEnabled){!0===visibility&&(this.loadingDiv.fadeIn(500),isEvolveWFMEnabled?this.getEvolveSchedule():(this.loadingDiv.fadeOut(),this.listSchedule.css("display","block")))},createNewCommitment:function(){this.options.container.createNewpromiseKeeper(!0)},onCommitmentClick:function(data){this.options.container.viewPromiseKeeperDetails(data,!0)},updateCommitments:function(data){this.commitmentsForMe=$.grep(data,function(item){return"A"===item.target}),this.formSchedule()},getEvolveSchedule:function(){var that=this;this.options.container.getEvolveSchedule(function(response){that.evolveSchedules=response.schedules,that.formSchedule()},function(){that.listSchedule.empty(),$("#noSchedule").showfn(),that.loadingDiv.fadeOut()})},formSchedule:function(){if(this.listSchedule.empty(),IC_Validation.isNotNullOrEmpty(this.evolveSchedules)&&this.evolveSchedules.length>0||IC_Validation.isNotNullOrEmptyArray(this.commitmentsForMe)){var shifts=IC_Validation.isNotNullOrEmpty(this.evolveSchedules)&&this.evolveSchedules.length>0?this.evolveSchedules[0].shifts:[],activityIntervals=IC_Validation.isNotNullOrEmpty(this.evolveSchedules)&&this.evolveSchedules.length>0?this.evolveSchedules[0].activityIntervals:[];this.formRecords(shifts,activityIntervals,this.commitmentsForMe)?($("#noSchedule").hide(),this.loadingDiv.fadeOut(500),this.listSchedule.css("display","block")):(this.loadingDiv.fadeOut(500),$("#noSchedule").showfn(),$("#noSchedule").text(IC_Localization.noSchedule))}else this.loadingDiv.fadeOut(500),$("#noSchedule").showfn(),$("#noSchedule").text(IC_Localization.noSchedule)},setFocusToScheduleHeader:function(){this.headerPanel.trigger("focus")},formRecords:function(shifts,activitiesOutOfShift,commitmentsForMe){var container,header,child,groupedSchedules=this.getEvolveSchedulesGroupedByDate(shifts,activitiesOutOfShift,commitmentsForMe),hasSchedules=!1,that=this;for(var item in groupedSchedules){hasSchedules=!0;break}for(var key in groupedSchedules)container=$("<div id = 'panelContainerId_"+key+"'>").css("width","100%"),header=$("<div id = 'panelHeaderId' class='panelHeader'/>").appendTo(container),child=$("<div>").appendTo(container),header.text(key),populateSchedules(groupedSchedules[key],child),this.listSchedule.append(container);return hasSchedules;function populateSchedules(schedules,parent){var scheduleDiv,label,scheduleTitleDiv,notesDiv,date,record=null;for(schedules.sort(function(a,b){return new Date(a.activityStart).getUTCTime()-new Date(b.activityStart).getUTCTime()}),i=0;i<schedules.length;i++)if(record=schedules[i],scheduleDiv=$('<div id = "activity_'+record.activityId+'" class="evolveScheduleDiv"/>').appendTo(parent),label=record.activityTitle,scheduleTitleDiv=$('<div id = "activityIntervalDivId" class="nameDiv"/>').appendTo(scheduleDiv),IC_Common.setTextWithEllipsis(scheduleTitleDiv,label,100),$('<div id = "activityIntervalTimeDivId" class="timeDiv"/>').text((date=new Date(record.activityStart),IC_Common.getAMPMLocale(date.format(that.options.container.options.localeTimeFormat),that.options.container.options.localeCode))).appendTo(scheduleDiv),IC_Validation.isNotNullOrEmpty(record.notes)&&(notesDiv=$('<br><div id = "activityNotesDivId" class="notesDiv"/>').appendTo(scheduleDiv),IC_Common.setTextWithEllipsis(notesDiv,record.notes,160)),record.canViewDetail){var commitment=$.grep(commitmentsForMe,function(item){return item.callbackId===record.activityId});scheduleDiv.on("click",$.proxy(that.onCommitmentClick,that,commitment[0])),scheduleDiv.addClass("commitmentDiv")}}},getEvolveSchedulesGroupedByDate:function(shifts,activitiesOutOfShift,commitmentsForMe){var dateValue,item,shiftActivities,activity,groupedSchedules={},groupedSchedulesSorted={},sortedSchedules=[],weekdays=[IC_Localization.sunday,IC_Localization.monday,IC_Localization.tuesday,IC_Localization.wednesday,IC_Localization.thursday,IC_Localization.friday,IC_Localization.saturday],today=(new Date).format(this.localeDateFormat);for(i=0;i<shifts.length;i++){for(item=shifts[i],key=(key=(dateValue=new Date(item.start)).format(this.localeDateFormat))===today?IC_Localization.today+" "+key:weekdays[dateValue.getDay()]+" "+key,activityObj={activityId:"shiftStart_"+item.id,activityStart:item.start,activityTitle:IC_Localization.startShift,canViewDetail:!1,notes:""},groupedSchedules.hasOwnProperty(key)?groupedSchedules[key].push(activityObj):groupedSchedules[key]=[activityObj],shiftActivities=item.activityIntervals,k=0;k<shiftActivities.length;k++)activityObj={activityId:(activity=shiftActivities[k]).id,activityStart:activity.start,activityTitle:activity.activityCode.title,canViewDetail:!1,notes:activity.activityNotes},groupedSchedules[key].push(activityObj);activityObj={activityId:"shiftEnd_"+item.id,activityStart:item.end,activityTitle:IC_Localization.endShift,canViewDetail:!1,notes:""},groupedSchedules[key].push(activityObj)}for(j=0;j<activitiesOutOfShift.length;j++){item=activitiesOutOfShift[j],key=(key=(dateValue=new Date(item.start)).format(this.localeDateFormat))===today?IC_Localization.today+" "+key:weekdays[dateValue.getDay()]+" "+key;var activityObj={activityId:item.id,activityStart:item.start,activityTitle:item.activityCode.title,canViewDetail:!1,notes:item.activityNotes};groupedSchedules.hasOwnProperty(key)?groupedSchedules[key].push(activityObj):groupedSchedules[key]=[activityObj]}for(k=0;k<commitmentsForMe.length;k++){item=commitmentsForMe[k],key=(key=(dateValue=new Date(item.callbackTime)).format(this.localeDateFormat))===today?IC_Localization.today+" "+key:weekdays[dateValue.getDay()]+" "+key;activityObj={activityId:item.callbackId,activityStart:item.callbackTime,activityTitle:item.firstName+" "+item.lastName,canViewDetail:!0,notes:item.notes};groupedSchedules.hasOwnProperty(key)?groupedSchedules[key].push(activityObj):groupedSchedules[key]=[activityObj]}for(var key in groupedSchedules)sortedSchedules.push([key,groupedSchedules[key]]);return sortedSchedules.sort(function(a,b){return new Date(a[0]).getUTCTime()-new Date(b[0]).getUTCTime()}),sortedSchedules.forEach(function(schedules){groupedSchedulesSorted[schedules[0]]=schedules[1]}),groupedSchedulesSorted},toggleNewButton:function(hasOBSkills){hasOBSkills?(newBtnDiv.attr("tabindex",0),IC_Common.enableButton(newBtnDiv,"",""),newBtnDiv.on("click",$.proxy(this.createNewCommitment,this))):(newBtnDiv.addClass("btnDivDisable").removeClass("btnDivEnable"),newBtnDiv.removeAttr("tabindex"),newBtnDiv.off("click"))},updatePanelHeight:function(height){var loadinDivHeight;loadinDivHeight=(height-=54)+20,this.listSchedule.css({height:height+"px"}),this.loadingDiv.css({height:loadinDivHeight+"px"})},openWFMClick:function(){this.options.container.openWFM()}})}(jQuery);