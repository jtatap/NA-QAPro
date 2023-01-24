!function($){$.widget("AgentConsole.promiseKeeperDateTime",{options:{container:null,popout:null,resourceBase:"",dateTimeUpdatedCallback:function(value){}},_create:function(){var parent=this.element;this.resourceBase=this.options.resourceBase;var that=this;parent.addClass("promiseKeeperDateTime"),$('<span class="dialogHidden">'+IC_Localization.begin+" "+IC_Localization.commitmentDate+"</span>").appendTo(parent),this.rootPanel=$('<div class="modalDialogBackground"/>').appendTo(parent),this.headerPanel=$('<div class="modalDialogHeader" tabindex="-1" aria-labelledby="promiseKeeperDate_Header" role="region"/>').appendTo(this.rootPanel),this.container=$("<div class='infoPanel'>").appendTo(this.rootPanel),that.dateFilter=$("<div class='promiseKeeperDatePicker'>").appendTo(this.container),that.dateFilter.datepicker({minDate:"0",inline:!0,onSelect:function(){var selectedData=that.dateFilter.datepicker("getDate"),formattedDate=$.datepicker.formatDate("D "+that.localeDateFormat,selectedData);that.datePickerTxt.val(formattedDate),that._hideInvalidTimeError()},onChangeMonthYear:function(){that._hideInvalidTimeError()}}),that.promiseKeeperDateTimeControls=$("<div class='promiseKeeperDateTimeControls'>").appendTo(this.container),that.datePickerLabel=$("<div class='datePickerLabel'>").text(IC_Localization.date).appendTo(that.promiseKeeperDateTimeControls),that.datePickerTxt=$("<input type='text' class='promiseKeeperDateTxt' title='"+IC_Localization.date+"' readonly disabled>").appendTo(that.promiseKeeperDateTimeControls),that.expiredTimeError=$("<div class='errorPanel'>").appendTo(that.promiseKeeperDateTimeControls).hide(),that.timePickerLabel=$("<div class='timePickerLabel'>").text(IC_Localization.time).appendTo(that.promiseKeeperDateTimeControls);var selectParent=$("<div>").appendTo(that.promiseKeeperDateTimeControls);that.timePickerOptions=$("<div id = 'timePickerOptionsId' class='timeZoneSelect'>").appendTo(selectParent),that.timePickerOptions.comboBox({onDataChange:function(){that._hideInvalidTimeError(),that.timePickerOptionsTxt.val(that.timePickerOptions.comboBox("getSelectedItem").id)},resourceBase:this.resourceBase}),that.timePickerOptionsTxt=$("<input type='text' class='timePickerSelect timePickerOptionsTxt' id='timePickerInputTxt' title='"+IC_Localization.time+"'>").appendTo(selectParent).on("keydown",$.proxy(that._onTimeType,that)),that._loadTimeIntervals(),that.timePickerOptions.find(".txtDiv .txtSpn").css({opacity:0}),that.timeZoneLabel=$("<div class='timeZoneLabel'>").text(IC_Localization.timezone).appendTo(that.promiseKeeperDateTimeControls),that.timeZoneOptions=$("<div id = 'timeZoneOptionsId' class='timeZoneSelect'>").appendTo(that.promiseKeeperDateTimeControls),that.timeZoneOptions.comboBox({onDataChange:function(){that._hideInvalidTimeError()},dispPosition:"top",resourceBase:this.resourceBase}),this.saveCancelBtnControl=$('<div class="saveCancelBtnControl"/>').appendTo(that.promiseKeeperDateTimeControls),this.saveBtnDiv=$('<div class="btnDivEnable btnStyle" id = "saveBtn" ></div>').appendTo(this.saveCancelBtnControl),this.saveBtn=$('<div class="editBtn"></div>').appendTo(this.saveBtnDiv),IC_Common.setTextWithEllipsis(this.saveBtn,IC_Localization.save,40),this.saveBtnDiv.hoverfn(IC_Common.mouseEnterButton,IC_Common.mouseLeaveButton).on("click",$.proxy(this._onSaveClick,this)),this.cancelBtnDiv=$('<div class="btnDivEnable btnStyle" id = "cancelBtn" ></div>').appendTo(this.saveCancelBtnControl),this.cancelBtn=$('<div class="okBtn"></div>').appendTo(this.cancelBtnDiv),IC_Common.setTextWithEllipsis(this.cancelBtn,IC_Localization.cancel,40),this.cancelBtnDiv.hoverfn(IC_Common.mouseEnterButton,IC_Common.mouseLeaveButton).on("click",$.proxy(this._closeBtnClick,this)),$('<div id = "promiseKeeperDate_Header" class="modalDialogHeaderText textEllipsis"/>').text(IC_Localization.commitmentDate).appendTo(this.headerPanel),this.closeBtn=$('<div id = "promiseKeeperDate_CloseBtnId" role="button" aria-label = "'+IC_Localization.close+'" tabindex = "0"/>').attr("title",IC_Localization.close).appendTo(this.headerPanel),this.closeBtnIcon=$("<img/>").addClass("closeBtnIcon").attr("src",this.resourceBase+"/css/images/section-close.png").attr("alt",IC_Localization.close+" "+IC_Localization.commitmentDate).appendTo(this.closeBtn),this.closeBtn.on("click",$.proxy(this._closeBtnClick,this)),IC_Common.enterKeyPress(this.closeBtn,function(){that._closeBtnClick()}),IC_Common.setFocusToCloseIcon(this.closeBtn,this.closeBtnIcon,"closeBtnFocus","closeBtnIconFocus"),$('<span class="dialogHidden">'+IC_Localization.end+" "+IC_Localization.commitmentDate+"</span>").appendTo(parent)},_init:function(){this.localeDateFormat=this.options.container.options.localeDateFormat.replace(/M/g,"m")},_hideInvalidTimeError:function(){this.expiredTimeError.hide()},_showInvalidTimeError:function(errorMessage){this.expiredTimeError.text(IC_Localization.error+": "+errorMessage).showfn()},_timeZones:[],MS_IANA_MapperList:null,_onTimeType:function(evt){this._hideInvalidTimeError()},_getDisplayTime:function(date){return IC_Common.getAMPMLocale(date.format(this.options.container.options.localeTimeFormat),this.options.container.options.localeCode)},_loadTimeIntervals:function(){var dispTime,options=[],currentTime=new Date;currentTime.setHours(0),currentTime.setMinutes(0);for(var i=0,intervalInc=0;i<96;i++)currentTime.setHours(0),currentTime.setMinutes(intervalInc),dispTime=this._getDisplayTime(currentTime),options.push({id:dispTime,value:dispTime}),intervalInc+=15;this.timePickerOptions.comboBox("setStore",options)},_isValidTimeSelected:function(timeValue,time){var parts,ampm={ar:{AM:"م",PM:"ص"},sq:{AM:".PD",PM:".MD"},zh:{AM:"上午",PM:"下午"},el:{AM:"πμ",PM:"μμ"},hi:{AM:"पूर्वाह्न",PM:"अपराह्न"},ko:{AM:"오전",PM:"오후"},th:{AM:"น",PM:"น"}},langCode=this.options.container.options.localeCode,isPM=!1;if(langCode=langCode.substr(0,2),this.localeTimeReg.test(timeValue))if(this.is12HrFormat?(ampmVal=ampm.hasOwnProperty(langCode)?ampm[langCode]:{AM:"AM",PM:"PM"},RegExp(ampmVal.PM,"i").test(timeValue)&&(isPM=!0),parts=(parts=timeValue.replace(RegExp(ampmVal.AM,"i"),"").replace(RegExp(ampmVal.PM,"i"),"")).split(/[:.]/)):parts=timeValue.split(/[:.]/),time.hours=parseInt(parts[0],10),time.minutes=parseInt(parts[1],10),this.is12HrFormat){if(time.hours>0&&time.hours<=12&&time.minutes>=0&&time.minutes<=59)return isPM?12!==time.hours&&(time.hours=12+time.hours):time.hours=time.hours%12,!0}else if(time.hours>=0&&time.hours<=23&&time.minutes>=0&&time.minutes<=59)return!0;return this._showInvalidTimeError(IC_Localization.inValidTimeFormatErrorAttempt),!1},getIANAName:function(){var standardName=this.timeZoneOptions.comboBox("getSelectedItem").standardName;if(null!=this.MS_IANA_MapperList){var name=this.MS_IANA_MapperList.find("mapZone[other='"+standardName+"']").attr("type");return name?name.split(" ")[0]:""}},_onSaveClick:function(){if(selectDateTime=this.dateFilter.datepicker("getDate"),time={},selectedTime=$.trim(this.timePickerOptionsTxt.val()),this._isValidTimeSelected(selectedTime,time)){selectDateTime.setHours(time.hours),selectDateTime.setMinutes(time.minutes);var currentTime=new Date,that=this;AgentConsoleDataStore.getIANATimeZoneOffset(that.getIANAName(),function(offset,error){var hours,minutes,dif,targetZoneCallbackTime=null;if(error||0==offset){var data=function(dateTime){var targetZoneID=that.timeZoneOptions.comboBox("getSelectedItem").id,hoursMinsSplit=targetZoneID.split(":"),hours=parseFloat(hoursMinsSplit[0]),minutes=parseFloat(hoursMinsSplit[1]),dif="-"!==targetZoneID[0]?"+":"-";dateTime.isDSTzone()&&(hours+=1);return{hours:hours=Math.abs(hours),minutes:minutes,dif:dif}}(selectDateTime);hours=data.hours,minutes=data.minutes,dif=data.dif}else offset=parseFloat(offset/36e5),hours=Math.abs(parseInt(offset)),minutes=60*(Math.abs(offset)-hours),dif=offset>0?"+":"-";var pad=function(num){var norm=Math.abs(Math.floor(num));return(norm<10?"0":"")+norm},isoDateFormat=selectDateTime.getFullYear()+"-"+pad(selectDateTime.getMonth()+1)+"-"+pad(selectDateTime.getDate())+"T"+pad(selectDateTime.getHours())+":"+pad(selectDateTime.getMinutes())+":"+pad(selectDateTime.getSeconds())+dif+pad(hours)+":"+pad(minutes);(targetZoneCallbackTime=new Date(isoDateFormat))<=currentTime?that._showInvalidTimeError(IC_Localization.inValidDateTimeErrorAttempt):(that._hideInvalidTimeError(),that.options.dateTimeUpdatedCallback(targetZoneCallbackTime),that._closeBtnClick())})}},_loadMapperList:function(callback){var that=this;$.ajax({url:that.resourceBase+"/js/data/windowsZones.xml",method:"get",dataType:"text",success:function(data){var parsedData=$.parseXML(data);that.MS_IANA_MapperList=$(parsedData),callback()},error:function(){that.MS_IANA_MapperList=[],callback()}})},_setUserTimeZone:function(){var that=this,tz=jstz.determine().name();function findIANA_Match(){var standardTimeZoneName,itemToSelect,targetTZ=that.MS_IANA_MapperList.find('mapZone[type="'+tz+'"]');null!=targetTZ?(standardTimeZoneName=targetTZ.attr("other"),(itemToSelect=findinTimeZonesList("standardName",standardTimeZoneName))?that.timeZoneOptions.comboBox("setSelectedItem",itemToSelect):selectClientTimeZoneByOffset()):selectClientTimeZoneByOffset()}function selectClientTimeZoneByOffset(){var timeZoneOffset=function(){var now=new Date,offset=now.getTimezoneOffset();now.isDSTzone()&&(offset+=60);return offset}(),hours=Math.abs(parseInt(timeZoneOffset/60,10)),minutes=Math.abs(parseInt(timeZoneOffset%60,10));hours<10&&(hours="0"+hours),minutes<10&&(minutes="0"+minutes);var itemToSelect=findinTimeZonesList("id",(timeZoneOffset>0?"-":"")+hours+":"+minutes);that.timeZoneOptions.comboBox("setSelectedItem",itemToSelect)}function findinTimeZonesList(property,value){for(var timeZones=that._timeZones,i=0,length=timeZones.length;i<length;i++)if(timeZones[i][property]===value)return timeZones[i]}null==that.MS_IANA_MapperList?that._loadMapperList(findIANA_Match):findIANA_Match()},setDate:function(callbackTime){var date=new Date(callbackTime);this.dateFilter.datepicker("setDate",date),this.datePickerTxt.val($.datepicker.formatDate("D "+this.localeDateFormat,date)),this.timePickerOptionsTxt.val(this._getDisplayTime(date)),this._setUserTimeZone(),this.renderCustomScrollBar(this.container),this.saveSelectedTimeForValidation(this._getDisplayTime(date))},saveSelectedTimeForValidation:function(time){var ampm={ar:{AM:"م",PM:"ص"},sq:{AM:".PD",PM:".MD"},zh:{AM:"上午",PM:"下午"},el:{AM:"πμ",PM:"μμ"},hi:{AM:"पूर्वाह्न",PM:"अपराह्न"},ko:{AM:"오전",PM:"오후"},th:{AM:"น",PM:"น"}},en_ampmVal_AM="AM",en_ampmVal_PM="PM";if(langCode=this.options.container.options.localeCode,langCode=langCode.substr(0,2),ampm.hasOwnProperty(langCode)){if(ampmVal=ampm[langCode],0===time.search(RegExp(ampmVal.AM,"i"))||0===time.search(RegExp(ampmVal.PM,"i"))){var appendSpace=" "==time.replace(RegExp(ampmVal.AM,"i"),"").replace(RegExp(ampmVal.PM,"i"),"")[0];this.localeTimeReg=new RegExp("^"+ampmVal.AM+"|"+ampmVal.PM+(appendSpace?" ":"")+"[0-9]{1,2}[:|.][0-9]{1,2}$","i"),this.is12HrFormat=!0}else if(time.search(RegExp(ampmVal.AM,"i"))>0||time.search(RegExp(ampmVal.PM,"i"))>0){var temp=time.replace(RegExp(ampmVal.AM,"i"),"").replace(RegExp(ampmVal.PM,"i"),""),prependSpace=" "==temp[temp.length-1];this.localeTimeReg=new RegExp("^[0-9]{1,2}[:|.][0-9]{1,2}"+(prependSpace?" ":"")+ampmVal.AM+"|"+ampmVal.PM+"$","i"),this.is12HrFormat=!0}}else-1===time.search(RegExp(en_ampmVal_AM,"i"))&&-1===time.search(RegExp(en_ampmVal_PM,"i"))?(this.localeTimeReg=new RegExp("^[0-9]{1,2}[:|.][0-9]{1,2}$","i"),this.is12HrFormat=!1):(this.localeTimeReg=new RegExp("[0-9]{1,2}[:|.][0-9]{1,2} [A|P]M","i"),this.is12HrFormat=!0)},setTimezones:function(timeZones){this._timeZones=[];for(var timezone=null,i=0,length=timeZones.length;i<length;i++)timezone=timeZones[i],this._timeZones.push({id:timezone.offset,value:timezone.displayName,standardName:timezone.standardName});this.timeZoneOptions.comboBox("setStore",this._timeZones)},_closeBtnClick:function(){this._hideInvalidTimeError(),this.options.container.closePromiseKeeperDateTimeAndShowHome(),IC_Common.removeFocusFromCloseIcon(this.closeBtnIcon,"closeBtnIconFocus")},renderCustomScrollBar:function(objName){"block"===objName.css("display")&&(objName.mCustomScrollbar("destroy"),objName.mCustomScrollbar({scrollButtons:{enable:!0},advanced:{updateOnContentResize:!0},scrollInertia:0}))},updatePanelHeight:function(height){height-=8,this.container.css({height:height+"px"})},setFocusToCommitmentDateHeader:function(){this.headerPanel.trigger("focus")},resize:function(availableWidth,availableHeight){this.container.css({height:availableHeight-35})}})}(jQuery);