!function($){$.widget("AgentConsole.promiseKeeperDetails",{options:{container:null,resourceBase:""},promiseKeeper:[],promisekeeperInfo:null,_initialCallbackTime:null,_isReschedule:!1,_runningIntervalId:null,notesAreaHeight:235,_isEvolve:!1,_create:function(){var firstNamePnl,lastNamePnl,phonePnl,promiseForPnl,skillPnl,dateTimePnl,dateTimeTxtDiv,editBtnDiv,okBtnDiv,saveBtn,cancelBtn,editBtn,parent=this.element,that=this;this.resourceBase=this.options.resourceBase,this.skillList=[],this.ReminderPlaceholderMsg=IC_Localization.enterNotes+"...",parent.addClass("promiseKeeperDetails"),$('<span class="dialogHidden">'+IC_Localization.begin+" "+IC_Localization.commitmentDetails+"</span>").appendTo(parent),this.rootPanel=$('<div class="modalDialogBackground" role = "dialog"/>').appendTo(parent),this.headerPanel=$('<div id="promiseKeeperDetail_HeaderPanel" class="modalDialogHeader" tabindex="-1" aria-labelledby="promiseKeeperDetail_Header" role="dialog"/>').appendTo(this.rootPanel),header=$('<div id = "promiseKeeperDetail_Header" class="modalDialogHeaderText"/>').text(IC_Localization.commitmentDetails).appendTo(this.headerPanel),IC_Common.setTextWithEllipsis(header,IC_Localization.commitmentDetails,150,!0),this.closeBtn=$('<div id = "PKD_CloseBtnId" aria-label = "'+IC_Localization.close+'" role="button" tabindex = "0" />').attr("title",IC_Localization.close).appendTo(this.headerPanel),this.closeBtnIcon=$("<img/>").addClass("closeBtnIcon").attr("src",this.resourceBase+"/css/images/section-close.png").attr("alt",IC_Localization.close+" "+IC_Localization.commitmentDetails).appendTo(this.closeBtn),this.closeBtn.on("click",$.proxy(this.okBtnClick,this)),IC_Common.enterKeyPress(this.closeBtn,function(){that.okBtnClick()}),IC_Common.setFocusToCloseIcon(this.closeBtn,this.closeBtnIcon,"closeBtnFocus","closeBtnIconFocus"),this.promiseKeeperDetails=$('<div class="infoPanel" id="pk_infoPnl"/>').appendTo(this.rootPanel),this.promiseKeeperContent=$("<div/>").appendTo(this.promiseKeeperDetails),firstNamePnl=$('<div class="pkInfoHeader">').appendTo(this.promiseKeeperContent),this.firstNameErrorPnl=$('<div class="errorPanel" id="firstNameErrorPnl" name="first"/>').text(IC_Localization.error+": "+IC_Localization.enterFirstName).appendTo(firstNamePnl),$('<div class="pkdHeader textEllipsis" >'+IC_Localization.firstName+"</div>").appendTo(firstNamePnl),this.firstNameValue=$('<div id = "firstNameValueId" class="pkdValue"></div>').appendTo(firstNamePnl),this.firstNameTxt=$('<input type="text" id = "firstNameId" class="userText" title="'+IC_Localization.firstName+'"/>').appendTo(firstNamePnl),lastNamePnl=$('<div class="pkInfoHeader">').appendTo(this.promiseKeeperContent),this.lastNameErrorPnl=$('<div class="errorPanel" id="lastNameErrorPnl" name="last"/>').text(IC_Localization.error+": "+IC_Localization.enterLastName).appendTo(lastNamePnl),$('<div class="pkdHeader textEllipsis">'+IC_Localization.lastName+"</div>").appendTo(lastNamePnl),this.lastNameValue=$('<div id = "lastNameValueId" class="pkdValue"></div>').appendTo(lastNamePnl),this.lastNameTxt=$('<input type="text" id = "lastNameId" class="userText" title="'+IC_Localization.lastName+'" />').appendTo(lastNamePnl),phonePnl=$('<div class="pkInfoHeader">').appendTo(this.promiseKeeperContent),this.phoneErrorPnl=$('<div class="errorPanel" id="phoneErrorPnl" name="phone"/>').text(IC_Localization.error+": "+IC_Localization.enterPhoneNumber).appendTo(phonePnl),this.phoneNumCountErrorPnl=$('<div class="errorPanel" id="phoneNumCountErrorPnl" name="phoneNumCount"/>').text(IC_Localization.inValidphoneNumber).appendTo(phonePnl),this.invalidPhoneNumPnl=$('<div class="errorPanel" id="invalidPhoneNumPnl"/>').text(IC_Localization.enterValidPhoneNumber).appendTo(phonePnl),$('<div class="pkdHeader textEllipsis" >'+IC_Localization.phone+"</div>").appendTo(phonePnl),this.phoneValue=$('<div id = "phoneValueId" class="pkdValue"></div>').appendTo(phonePnl),this.phoneTxt=$('<input type="text" id = "phoneId" class="userText" title="'+IC_Localization.phone+'"/>').appendTo(phonePnl),promiseForPnl=$('<div class="pkInfoHeader">').appendTo(this.promiseKeeperContent),this.assignToHeader=$('<div class="pkdHeader textEllipsis">'+IC_Localization.assignTo+"</div>").appendTo(promiseForPnl),this.assignTo=$('<div class="promiseForDiv" aria-label = "'+IC_Localization.assignTo+'" >').appendTo(promiseForPnl),this.forMe=$('<div class="radionBtnPnl">').appendTo(this.assignTo),this.me_Rbtn=$('<input type="radio" name="promiseBtnId" value = "A"/>').attr("title",IC_Localization.assignTo+" "+IC_Localization.me).css({float:"left"}).appendTo(this.forMe),this.me_BtnLbl=$("<div> </div>").css({"padding-top":"3px"}).appendTo(this.forMe),IC_Common.setTextWithEllipsis(this.me_BtnLbl,IC_Localization.me,55),this.forSkill=$('<div class="radionBtnPnl">').appendTo(this.assignTo),this.skill_Rbtn=$('<input type="radio" name="promiseBtnId" value = "S"/>').attr("title",IC_Localization.assignTo+" "+IC_Localization.skill).css({float:"left"}).appendTo(this.forSkill),this.skill_BtnLbl=$("<div> </div>").text(IC_Localization.skill).css({"padding-top":"3px"}).appendTo(this.forSkill),IC_Common.setTextWithEllipsis(this.skill_BtnLbl,IC_Localization.skill,55),this.assignToValue=$('<div id = "assignToValueId" class="pkdValue"></div>').appendTo(promiseForPnl),skillPnl=$('<div class="pkInfoHeader">').appendTo(this.promiseKeeperContent),this.skillLbl=$('<div class="pkdHeader textEllipsis">'+IC_Localization.skill+"</div>").appendTo(skillPnl),this.skillValue=$('<div id = "skillValueId" class="pkdValue"></div>').appendTo(skillPnl),this.skillErrorPnl=$('<div class="errorPanel" id="skillErrorPnl" name="skill"/>').text(IC_Localization.error+": "+IC_Localization.selectTheSkill).appendTo(skillPnl),this.skillCombo=$('<div id="skillComboId"/>').addClass("skillCombo").appendTo(skillPnl),dateTimePnl=$('<div class="pkInfoHeader">').appendTo(this.promiseKeeperContent),this.dateTimeErrorPnl=$('<div class="errorPanel" id="dateTimeErrorPnl"/>').appendTo(dateTimePnl).text(IC_Localization.error+": "+IC_Localization.inValidDateTimeErrorAttempt),$('<div class="pkdHeader textEllipsis">'+IC_Localization.timeAndDate+"</div>").appendTo(dateTimePnl),this.dateTimeValue=$('<div id = "dateTimeValueId" class="pkdValue"></div>').appendTo(dateTimePnl),this.dateTimeCombo=$('<div id="dateTimeComboId" />').addClass("dateTimeCombo").appendTo(dateTimePnl),this.dateTimeDiv=$('<div tabindex="0" aria-label = "'+IC_Localization.timeAndDate+'"/>').addClass("dateTimeDiv btnDivEnable roundBorder").appendTo(this.dateTimeCombo),dateTimeTxtDiv=$("<div/>").addClass("txtDiv").appendTo(this.dateTimeDiv),this.callBackTime=$("<div/>").addClass("txtSpn textEllipsis").appendTo(dateTimeTxtDiv),dateTimeIconDiv=$('<div class="dateTimeIconDiv"></div>').on("click",$.proxy(this.dateTimePicker,this)).appendTo(this.dateTimeDiv),$('<div class="icon"></div>').appendTo(dateTimeIconDiv),IC_Common.setFocusToElement(this.dateTimeDiv,"element-focus"),this.minutesDiv=$('<div class="pkInfoHeader">').appendTo(this.promiseKeeperContent).hide(),this.mins5=$('<div id = "mins5Id" class="btnDivEnable dateTimeMinutesDiv" role="button" aria-label = "5 '+IC_Localization.min+'" tabindex="0"/>').appendTo(this.minutesDiv),IC_Common.setTextWithEllipsis(this.mins5,"5 "+IC_Localization.min,28,!0),this.mins5.on("click",$.proxy(that.postponeScheduleCallback,that,{val:5,key:that.mins5})),IC_Common.enterKeyPress(this.mins5,function(){that.postponeScheduleCallback({val:5,key:that.mins5})}),IC_Common.setFocusToElement(this.mins5,"element-focus"),this.mins10=$('<div id="mins10" class="btnDivEnable dateTimeMinutesDiv" role="button" aria-label = "10 '+IC_Localization.min+'" tabindex="0"/>').appendTo(this.minutesDiv),IC_Common.setTextWithEllipsis(this.mins10,"10 "+IC_Localization.min,28,!0),this.mins10.on("click",$.proxy(that.postponeScheduleCallback,that,{val:10,key:that.mins10})),IC_Common.enterKeyPress(this.mins10,function(){that.postponeScheduleCallback({val:10,key:that.mins10})}),IC_Common.setFocusToElement(this.mins10,"element-focus"),this.mins15=$('<div id="mins15" class="btnDivEnable dateTimeMinutesDiv" role="button" aria-label = "15 '+IC_Localization.min+'" tabindex="0"/>').appendTo(this.minutesDiv),IC_Common.setTextWithEllipsis(this.mins15,"15 "+IC_Localization.min,28,!0),this.mins15.on("click",$.proxy(that.postponeScheduleCallback,that,{val:15,key:that.mins15})),IC_Common.enterKeyPress(this.mins15,function(){that.postponeScheduleCallback({val:15,key:that.mins15})}),IC_Common.setFocusToElement(this.mins15,"element-focus"),this.mins30=$('<div  id="mins30" class="btnDivEnable dateTimeMinutesDiv" role="button" aria-label = "30 '+IC_Localization.min+'" tabindex="0"/>').appendTo(this.minutesDiv),IC_Common.setTextWithEllipsis(this.mins30,"30 "+IC_Localization.min,28,!0),this.mins30.on("click",$.proxy(that.postponeScheduleCallback,that,{val:30,key:that.mins30})),IC_Common.enterKeyPress(this.mins30,function(){that.postponeScheduleCallback({val:30,key:that.mins30})}),IC_Common.setFocusToElement(this.mins30,"element-focus"),this.hour1=$('<div  id="hour1" class="btnDivEnable dateTimeMinutesDiv" role="button" aria-label = "1 '+IC_Localization.hour+'" tabindex="0"/>').appendTo(this.minutesDiv),IC_Common.setTextWithEllipsis(this.hour1,"1 "+IC_Localization.hour,28,!0),this.hour1.on("click",$.proxy(that.postponeScheduleCallback,that,{val:60,key:that.hour1})),IC_Common.enterKeyPress(this.hour1,function(){that.postponeScheduleCallback({val:60,key:that.hour1})}),IC_Common.setFocusToElement(this.hour1,"element-focus"),this.notesPnlDiv=$("<div>").appendTo(this.promiseKeeperContent),this.notesPnl=$('<div class="pkInfoHeader">').appendTo(this.notesPnlDiv),$('<div class="pkdHeader textEllipsis" title="'+IC_Localization.notes+'">'+IC_Localization.notes+"</div>").appendTo(this.notesPnl),this.notesValue=$('<div id = "notesValueId" class="pkdValue"></div>').css("word-wrap","break-word").appendTo(this.notesPnl),this.notesAreaDiv=$('<div id = "notesAreaDivId" class="notesAreaDiv">').appendTo(this.notesPnlDiv),this.notesTextArea=$('<textarea class="txtNotes" title="'+IC_Localization.commitmentDetails+" "+IC_Localization.notes+'"> </textarea>').appendTo(this.notesAreaDiv),this.rescheduleTimeout=$('<div class="rescheduleTioutLbl"/>').appendTo(this.promiseKeeperContent).hide(),this.editOKBtnControl=$('<div class="editOKBtnControl"/>').appendTo(this.promiseKeeperContent),deleteBtnDiv=$('<div class="btnDivEnable deleteBtnStyle" id = "deleteBtnID" ></div>').on("click",$.proxy(this.showDeleteCommitmentNotesPage,this)).appendTo(this.editOKBtnControl),deleteBtn=$('<div class="deleteBtn"></div>').appendTo(deleteBtnDiv),IC_Common.setTextWithEllipsis(deleteBtn,IC_Localization.delete,40),deleteBtnDiv.hoverfn(IC_Common.mouseEnterButton,IC_Common.mouseLeaveButton),editBtnDiv=$('<div class="btnDivEnable btnStyle" id = "editBtnID" ></div>').on("click",$.proxy(this.editView,this)).appendTo(this.editOKBtnControl),editBtn=$('<div class="editBtn"></div>').appendTo(editBtnDiv),IC_Common.setTextWithEllipsis(editBtn,IC_Localization.edit,30),editBtnDiv.hoverfn(IC_Common.mouseEnterButton,IC_Common.mouseLeaveButton),okBtnDiv=$('<div class="btnDivEnable btnStyle" id = "okBtnID" ></div>').on("click",$.proxy(this.okBtnClick,this)).appendTo(this.editOKBtnControl),this.okBtn=$('<div class="okBtn textEllipsis">'+IC_Localization.ok+"</div>").appendTo(okBtnDiv),okBtnDiv.hoverfn(IC_Common.mouseEnterButton,IC_Common.mouseLeaveButton),this.saveCancelBtnControl=$('<div class="saveCancelBtnControl"/>').appendTo(this.promiseKeeperContent),this.saveBtnDiv=$('<div class="btnDivEnable savebtnStyle" id = "saveBtnID" role="button" aria-label = "'+IC_Localization.submit+'" tabindex="0"></div>').on("click",$.proxy(this.saveBtnClick,this)).appendTo(this.saveCancelBtnControl),saveBtn=$('<div class="saveBtn"></div>').appendTo(this.saveBtnDiv),IC_Common.setTextWithEllipsis(saveBtn,IC_Localization.submit,45),$('<div class="saveBtnIcon" />').appendTo(this.saveBtnDiv),this.saveBtnDiv.hoverfn(IC_Common.mouseEnterButton,IC_Common.mouseLeaveButton),IC_Common.enterKeyPress(this.saveBtnDiv,function(){that.saveBtnClick()}),IC_Common.setFocusToElement(this.saveBtnDiv,"element-focus"),this.cancelBtnContainer=cancelBtn=$('<div class="btnDivEnable cancelbtnStyle" id = "cancelBtnID" role="button" aria-label = "'+IC_Localization.cancel+'" tabindex="0"></div>').appendTo(this.saveCancelBtnControl),this.cancelBtn=$('<div class="cancelBtn"></div>').appendTo(cancelBtn),IC_Common.setTextWithEllipsis(this.cancelBtn,IC_Localization.cancel,45),cancelBtn.hoverfn(IC_Common.mouseEnterButton,IC_Common.mouseLeaveButton),IC_Common.enterKeyPress(this.cancelBtnContainer,function(){that.cancelBtnClick()}),IC_Common.setFocusToElement(this.cancelBtnContainer,"element-focus"),this.deleteCommitmentPage=$("<div/>").appendTo(this.promiseKeeperDetails).hide(),this.deletePnlDiv=$("<div>").appendTo(this.deleteCommitmentPage),this.deleteNotesErrorPnl=$('<div class="errorPanel" id="deleteNotesErrorPnl"/>').appendTo(this.deletePnlDiv).hide(),this.deleteNotesLbl=$('<div class="pkInfoHeader">').appendTo(this.deletePnlDiv),$('<div class="pkdHeader textEllipsis" title="'+IC_Localization.notes+'">'+IC_Localization.notes+"</div>").appendTo(this.deleteNotesLbl),this.deleteNotesAreaDiv=$('<div id = "deleteNotesAreaDiv" class="deleteNotesAreaDiv">').appendTo(this.deletePnlDiv),this.deleteNotesTextArea=$('<textarea class="txtNotes" title="'+IC_Localization.commitmentDetails+" "+IC_Localization.delete+" "+IC_Localization.notes+'"> </textarea>').appendTo(this.deleteNotesAreaDiv),this.submitCancelBtnControl=$('<div class="deleteCancelBtnControl"/>').appendTo(this.deleteCommitmentPage),deletePageSubmitBtnDiv=$('<div class="btnDivEnable savebtnStyle" id = "deletePageSubmitBtnID" ></div>').on("click",$.proxy(this.deleteCallback,this)).appendTo(this.submitCancelBtnControl),submitBtn=$('<div class="saveBtn"></div>').appendTo(deletePageSubmitBtnDiv),IC_Common.setTextWithEllipsis(submitBtn,IC_Localization.submit,45),$('<div class="saveBtnIcon" />').appendTo(deletePageSubmitBtnDiv),deletePageSubmitBtnDiv.hoverfn(IC_Common.mouseEnterButton,IC_Common.mouseLeaveButton),deletePageCancelBtnDiv=$('<div class="btnDivEnable cancelbtnStyle" id = "deletePageCancelBtnID" ></div>').on("click",$.proxy(this.okBtnClick,this)).appendTo(this.submitCancelBtnControl),deletePageCancelBtn=$('<div class="cancelBtn"></div>').appendTo(deletePageCancelBtnDiv),IC_Common.setTextWithEllipsis(deletePageCancelBtn,IC_Localization.cancel,45),deletePageCancelBtnDiv.hoverfn(IC_Common.mouseEnterButton,IC_Common.mouseLeaveButton),$('<span class="dialogHidden">'+IC_Localization.end+" "+IC_Localization.commitmentDetails+"</span>").appendTo(parent),$(this.firstNameTxt).on("blur",function(){"block"===that.firstNameErrorPnl.css("display")&&IC_Validation.isNotNullOrUndefinedString($.trim(that.firstNameTxt.val()))&&that.firstNameErrorPnl.css("display","none")}),$(this.lastNameTxt).on("blur",function(){"block"===that.lastNameErrorPnl.css("display")&&IC_Validation.isNotNullOrUndefinedString($.trim(that.lastNameTxt.val()))&&that.lastNameErrorPnl.css("display","none")}),$(this.phoneTxt).on("blur",function(){that.validatePhoneNumber()}),this.skillCombo.comboBox({onDataChange:$.proxy(this.onSkillChange,this),resourceBase:this.resourceBase}),this.phoneTxt.on("keypress",function(e){if(8!=e.which&&0!=e.which&&(e.which<48||e.which>57)&&42!=e.which&&35!=e.which&&43!=e.which&&!0!==e.ctrlKey&&(86!=e.which||118!=e.which))return!1}),this.deleteNotesTextArea.on("keypress",function(e){"block"===that.deleteNotesErrorPnl.css("display")&&(that.deleteNotesAreaDiv.css("height",that.notesAreaHeight+"px"),that.deleteNotesErrorPnl.hide())}),IC_Common.enterKeyPress(this.dateTimeCombo,function(){that.dateTimePicker()})},_init:function(){this.localeDateFormat=this.options.container.options.localeDateFormat.replace("yy","yyyy")},validatePhoneNumber:function(){var phone=$.trim(this.phoneTxt.val().replace(/[`~!@#$%^&*()_|\-=?;:'",.<>\{\}\[\]\\\/\s]/gi,"")),phoneNumbLength=phone.length;return"block"===this.phoneErrorPnl.css("display")&&IC_Validation.isNotNullOrUndefinedString(phone)&&this.phoneErrorPnl.css("display","none"),0!=phoneNumbLength&&phoneNumbLength<10?(this.phoneNumCountErrorPnl.css("display","block"),this.invalidPhoneNumPnl.css("display","none"),!0):(this.phoneNumCountErrorPnl.css("display","none"),0==phoneNumbLength||IC_Validation.isNumber(phone)?void this.invalidPhoneNumPnl.css("display","none"):(this.invalidPhoneNumPnl.css("display","block"),this.phoneNumCountErrorPnl.css("display","none"),!0))},_enableViewMode:function(){this.promiseKeeperContent.showfn(),this.firstNameTxt.css("display","none"),this.lastNameTxt.css("display","none"),this.phoneTxt.css("display","none"),this.assignTo.css("display","none"),this.skillCombo.css("display","none"),this.dateTimeCombo.css("display","none"),this.minutesDiv.css("display","none"),this.notesAreaDiv.css("display","none"),this.firstNameValue.css("display","block"),this.lastNameValue.css("display","block"),this.phoneValue.css("display","block"),this.assignToValue.css("display","block"),this.skillValue.css("display","block"),this.skillLbl.css("display","block"),this.dateTimeValue.css("display","block"),this.notesPnl.css("display","block"),this.assignToHeader.css("display","block"),this.saveCancelBtnControl.css("display","none"),this.editOKBtnControl.css("display","block"),this.deleteCommitmentPage.hide()},onSkillChange:function(){var selectedSkillId=this.skillCombo.comboBox("getSelectedItem").id;IC_Validation.isNotNullOrUndefinedString(selectedSkillId)&&(this.skillErrorPnl.css("display","none"),$("#skillComboId .txtSpn").removeClass("dispComboText"))},okBtnClick:function(){this.promisekeeperInfo=null,this.options.container.hidePromiseKeeperDetails(),IC_Common.removeFocusFromCloseIcon(this.closeBtnIcon,"closeBtnIconFocus")},cancelBtnClick:function(){this._hideAllErrorLabels(),this.showCancelChanges()},reschedulecloseBtnClick:function(){this.promisekeeperInfo=null,this.options.container.closePromiseKeeperDetailsAndShowHome()},rescheduleCancelBtnClick:function(){this._hideAllErrorLabels();var that=this;this._initialCallbackTime.toString()!==this.callBackTime.data("callbackTime").toString()?this.options.container.showCancelChangesPrompt(function(){that.options.container.closePromiseKeeperDetailsAndShowHome()}):(this.options.container.closePromiseKeeperDetailsAndShowHome(),this.promisekeeperInfo=null)},showCancelChanges:function(){var firstName=this.firstNameTxt.val(),lastName=this.lastNameTxt.val(),phone=this.phoneTxt.val(),selectedSkillId=this.skillCombo.comboBox("getSelectedItem").id,selectedtarget=$("input[name=promiseBtnId]:radio:checked").val(),notesText=IC_Common.removePlaceholderText(this.notesTextArea.val(),this.ReminderPlaceholderMsg),initialDate=this._initialCallbackTime.toString(),currentDate=this.callBackTime.data("callbackTime").toString();IC_Validation.isNullOrEmpty(this.promisekeeperInfo)?IC_Validation.isNotNull(firstName)||IC_Validation.isNotNull(lastName)||IC_Validation.isNotNull(phone)||IC_Validation.isNotNull(selectedSkillId)||"A"!=selectedtarget||IC_Validation.isNotNull(notesText)||initialDate!==currentDate?this.options.container.showCancelChangesPrompt():(this.options.container.hidePromiseKeeperDetails(),this.promisekeeperInfo=null):firstName!==this.promisekeeperInfo.firstName||lastName!==this.promisekeeperInfo.lastName||phone!==this.promisekeeperInfo.dialNumber||selectedSkillId!==this.promisekeeperInfo.skillId||selectedtarget!==this.promisekeeperInfo.target||notesText!==this.promisekeeperInfo.notes||initialDate!==currentDate?this.options.container.showCancelChangesPrompt():(this.options.container.hidePromiseKeeperDetails(),this.promisekeeperInfo=null)},saveBtnClick:function(){if(IC_Common.isButtonEnabled(this.saveBtnDiv)||IC_Common.isButtonSelected(this.saveBtnDiv))if(this._isReschedule){var callbackTime=this.callBackTime.data("callbackTime"),isInValidDateSelected=new Date>=callbackTime;this.dateTimeErrorPnl.css("display",isInValidDateSelected?"block":"none"),this.enableDisableSubmitBtn(!1),this.options.container.reschedulePromieKeeper(this.promisekeeperInfo.callbackId,IC_Common.toUTCDateString(callbackTime),$.proxy(this._onPromiseKeeperAPISuccess,this,!1),$.proxy(this._onPromiseKeeperAPIFaliure,this))}else{var selectedSkillId=this.skillCombo.comboBox("getSelectedItem").id,selectedtarget=$("input[name=promiseBtnId]:radio:checked").val(),firstName=this.firstNameTxt.val(),lastName=this.lastNameTxt.val(),phone=$.trim(this.phoneTxt.val().replace(/[`~!@$%^&()_|\-=?;:'",.<>\{\}\[\]\\\/\s]/gi,"")),isErrorDisplay=!1;IC_Validation.isNullOrEmptyOrEmptySpace(firstName)&&(this.firstNameErrorPnl.css("display","block"),isErrorDisplay=!0),IC_Validation.isNullOrEmptyOrEmptySpace(lastName)&&(this.lastNameErrorPnl.css("display","block"),isErrorDisplay=!0),IC_Validation.isNullOrEmptyOrEmptySpace(phone)&&(this.phoneErrorPnl.css("display","block"),isErrorDisplay=!0),IC_Validation.isNullOrEmptyOrEmptySpace(selectedSkillId)&&(this.skillErrorPnl.css("display","block"),isErrorDisplay=!0);isInValidDateSelected=new Date>=this.callBackTime.data("callbackTime");if(this.dateTimeErrorPnl.css("display",isInValidDateSelected?"block":"none"),!0===isErrorDisplay&&this.renderCustomScrollBar(this.promiseKeeperDetails),this.validatePhoneNumber())return;if(!(IC_Validation.isNullOrEmptyOrEmptySpace(firstName)||IC_Validation.isNullOrEmptyOrEmptySpace(lastName)||IC_Validation.isNullOrEmptyOrEmptySpace(phone)||IC_Validation.isNullOrEmptyOrEmptySpace(selectedSkillId)||isInValidDateSelected)){callbackTime=IC_Common.toUTCDateString(this.callBackTime.data("callbackTime"));var notesText=IC_Common.removePlaceholderText(this.notesTextArea.val(),this.ReminderPlaceholderMsg),targetId="A"===selectedtarget?this.agentInfo.id:"";this.enableDisableSubmitBtn(!1),IC_Validation.isNullOrEmpty(this.promisekeeperInfo)||IC_Validation.isNullOrEmpty(this.promisekeeperInfo.callbackId)?this.options.container.createScheduledCallback(firstName,lastName,phone,selectedSkillId,targetId,callbackTime,notesText,$.proxy(this._onPromiseKeeperAPISuccess,this,!0),$.proxy(this._onPromiseKeeperAPIFaliure,this)):this.options.container.updateScheduledCallback(this.promisekeeperInfo.callbackId,firstName,lastName,phone,selectedSkillId,targetId,callbackTime,notesText,$.proxy(this._onPromiseKeeperAPISuccess,this,!0),$.proxy(this._onPromiseKeeperAPIFaliure,this))}}},enableDisableSubmitBtn:function(isBtnEnable){btnState=isBtnEnable?"enabled":"disabled","enabled"===btnState?IC_Common.enableButton(this.saveBtnDiv):"disabled"===btnState&&IC_Common.disableButton(this.saveBtnDiv)},_onPromiseKeeperAPISuccess:function(hidePromiseKeeper){!0===hidePromiseKeeper&&this.options.container.hidePromiseKeeperDetails(),this.enableDisableSubmitBtn(!0)},_onPromiseKeeperAPIFaliure:function(response){IC_Validation.isNotNull(response)&&("InvalidScheduleDate"==response.error_description||"InvalidRescheduleDate"==response.error_description?this.dateTimeErrorPnl.showfn():this._stopRescheduleTimer()),this.enableDisableSubmitBtn(!0)},updatePanelHeight:function(isDialerPanel,isShowIndicator,height){var notesAreaHeight=235;notesAreaHeight=isDialerPanel?notesAreaHeight-29:notesAreaHeight,notesAreaHeight=isShowIndicator?notesAreaHeight-24:notesAreaHeight,height-=14,this.promiseKeeperDetails.css({height:height+"px"}),this.deleteNotesAreaDiv.css("height",notesAreaHeight+"px"),this.notesAreaHeight=notesAreaHeight},_hideAllErrorLabels:function(){this.dateTimeErrorPnl.css("display","none"),this.firstNameErrorPnl.css("display","none"),this.lastNameErrorPnl.css("display","none"),this.phoneErrorPnl.css("display","none"),this.phoneNumCountErrorPnl.css("display","none"),this.invalidPhoneNumPnl.css("display","none"),this.skillErrorPnl.css("display","none")},createNewPromise:function(isEvolve){this.promisekeeperInfo=null,this.disableRescheduleMode(),this.disableMinutesDiv(),this._hideAllErrorLabels(),this.promiseKeeperContent.showfn(),this.firstNameValue.css("display","none"),this.firstNameTxt.css("display","block"),this.firstNameTxt.val(""),this.lastNameValue.css("display","none"),this.lastNameTxt.css("display","block"),this.lastNameTxt.val(""),this.phoneValue.css("display","none"),this.phoneTxt.css("display","block"),this.phoneTxt.val(""),isEvolve?(this.me_Rbtn.css("display","none"),this.me_Rbtn.prop("checked",!0),this.skill_Rbtn.css("display","none"),this.assignTo.css("display","none"),this.assignToValue.css("display","none"),this.assignToHeader.css("display","none")):(this.me_Rbtn.prop("checked",!0),this.assignToValue.css("display","none"),this.assignTo.css("display","block"),this.me_Rbtn.css("display","block"),this.skill_Rbtn.css("display","block")),this.skillLbl.css("display","none"),this.skillValue.css("display","none"),this.skillCombo.css("display","block"),this.skillCombo.comboBox("setStore",this.skillList),this.skillCombo.comboBox("setSelectedItem",{id:"",value:IC_Localization.selectSkill}),$("#skillComboId .txtSpn").addClass("dispComboText"),this.dateTimeValue.css("display","none"),this.dateTimeCombo.css("display","block"),this._initialCallbackTime=new Date,this.updateCallbackTime(this._initialCallbackTime),this.minutesDiv.css("display","block"),this.notesPnl.css("display","none"),this.notesAreaDiv.css("display","block"),this.notesTextArea.val(""),this.notesTextArea.placeholder(this.ReminderPlaceholderMsg),this.editOKBtnControl.css("display","none"),this.saveCancelBtnControl.css("display","block"),this.deleteCommitmentPage.hide(),this.renderCustomScrollBar(this.promiseKeeperDetails)},editView:function(){var data=this.promisekeeperInfo;this.promiseKeeperContent.showfn(),this.firstNameValue.css("display","none"),this.firstNameTxt.css("display","block"),this.firstNameTxt.val(data.firstName),this.lastNameValue.css("display","none"),this.lastNameTxt.css("display","block"),this.lastNameTxt.val(data.lastName),this.phoneValue.css("display","none"),this.phoneTxt.css("display","block"),this.phoneTxt.val(data.dialNumber),this._isEvolve?(this.me_Rbtn.css("display","none"),this.me_Rbtn.prop("checked",!0),this.skill_Rbtn.css("display","none"),this.assignTo.css("display","none"),this.assignToValue.css("display","none"),this.assignToHeader.css("display","none")):("A"===data.target?this.me_Rbtn.prop("checked",!0):this.skill_Rbtn.prop("checked",!0),this.assignToValue.css("display","none"),this.assignTo.css("display","block"),this.me_Rbtn.css("display","block"),this.skill_Rbtn.css("display","block")),this.skillLbl.css("display","none"),this.skillValue.css("display","none"),this.skillCombo.css("display","block"),this.skillCombo.comboBox("setSelectedItem",{id:data.skillId,value:this.getSkillName(data.skillId)}),this.dateTimeValue.css("display","none"),this.dateTimeCombo.css("display","block"),this.updateCallbackTime(new Date(this.promisekeeperInfo.callbackTime)),this.minutesDiv.css("display","block"),this.notesPnl.css("display","none"),this.notesAreaDiv.css("display","block"),this.notesTextArea.val(data.notes),IC_Validation.isNullOrEmpty(data.notes)&&this.notesTextArea.placeholder(this.ReminderPlaceholderMsg),this.editOKBtnControl.css("display","none"),this.saveCancelBtnControl.css("display","block"),this.disableMinutesDiv(),this.deleteCommitmentPage.hide(),this.renderCustomScrollBar(this.promiseKeeperDetails)},showDeleteCommitmentNotesPage:function(){this.deleteNotesAreaDiv.css("height",this.notesAreaHeight+"px"),this.deleteNotesTextArea.val(""),this.deleteNotesErrorPnl.hide(),this.promiseKeeperContent.hide(),this.deleteCommitmentPage.showfn(),this.renderCustomScrollBar(this.promiseKeeperDetails)},hideDeleteCommitmentPage:function(){this.promiseKeeperContent.showfn(),this.deleteCommitmentPage.hide(),this.renderCustomScrollBar(this.promiseKeeperDetails)},deleteCallback:function(){var notes=$.trim(this.deleteNotesTextArea.val());IC_Validation.isNotNullOrUndefinedString(notes)?this.options.container.deleteCallback(this.promisekeeperInfo.callbackId,notes):(this.deleteNotesErrorPnl.showfn(),this.deleteNotesErrorPnl.text(IC_Localization.error+": "+IC_Localization.deleteCommitmentErrorAttempt),this.deleteNotesAreaDiv.css("height",this.notesAreaHeight-25+"px"))},dateTimePicker:function(){var time=this.promisekeeperInfo?new Date(this.promisekeeperInfo.callbackTime):new Date;this.options.container.dateTimePicker(time)},renderCustomScrollBar:function(objName){"block"===objName.css("display")&&(objName.mCustomScrollbar("destroy"),objName.mCustomScrollbar({scrollButtons:{enable:!0},scrollInertia:0}))},getSkillName:function(id){var skills=this.skills;for(var i in skills)if(skills[i].id==id)return skills[i].name;return id},refresh:function(data,skills,isEvolve){this.disableRescheduleMode(),this.disableMinutesDiv(),this._enableViewMode(),this._hideAllErrorLabels(),this._isEvolve=isEvolve,this.promisekeeperInfo=data,this.skills=skills;var skillName=this.getSkillName(data.skillId),promiseFor="A"===data.target?IC_Localization.me:skillName;IC_Common.setTextWithEllipsis(this.firstNameValue,data.firstName,150),IC_Common.setTextWithEllipsis(this.lastNameValue,data.lastName,150),IC_Common.setTextWithEllipsis(this.skillValue,skillName,150),this.phoneValue.text(data.dialNumber),this.phoneValue.prop("title",data.dialNumber),this.assignToValue.text(promiseFor),this._initialCallbackTime=new Date(data.callbackTime),this.dateTimeValue.text(this.getDisplayCallbackTime(this._initialCallbackTime)),this.notesValue.text(data.notes),this.skillCombo.comboBox("setStore",this.skillList),this.renderCustomScrollBar(this.promiseKeeperDetails)},updateSkillList:function(skillListMap){for(var skillId in this.skillList=[],skillListMap)skillListMap.hasOwnProperty(skillId)&&4===skillListMap[skillId].typeId&&!0===skillListMap[skillId].isOutbound&&"Manual"===skillListMap[skillId].strategy&&this.skillList.push({id:skillListMap[skillId].id,value:$.trim(skillListMap[skillId].name)});this.skillList.sort(function(a,b){var x=a.value.toLowerCase(),y=b.value.toLowerCase();return 1*(x==y?0:x>y?1:-1)})},updateAgentInfo:function(agentInfo){this.agentInfo=agentInfo},updateMetaData:function(type,list){IC_Validation.isNotNullOrEmpty(list)&&("Skill"===type?this.updateSkillList(list):"Info"===type&&this.updateAgentInfo(list))},getDisplayCallbackTime:function(date){var callbackTime,callbackDate;return callbackTime=IC_Common.getAMPMLocale(date.format(this.options.container.options.localeTimeFormat),this.options.container.options.localeCode),callbackDate=date.format(this.localeDateFormat),"time - date".replace("time",callbackTime).replace("date",callbackDate)},updateCallbackTime:function(callbackTime){this.dateTimeErrorPnl.hide(),this.callBackTime.text(this.getDisplayCallbackTime(callbackTime)).attr("title",this.getDisplayCallbackTime(callbackTime)),this.callBackTime.data("callbackTime",callbackTime)},disableMinutesDiv:function(){this.mins5.removeClass("btnDivDisable").addClass("btnDivEnable"),this.mins10.removeClass("btnDivDisable").addClass("btnDivEnable"),this.mins15.removeClass("btnDivDisable").addClass("btnDivEnable"),this.mins30.removeClass("btnDivDisable").addClass("btnDivEnable"),this.hour1.removeClass("btnDivDisable").addClass("btnDivEnable")},postponeScheduleCallback:function(incByMinutes){this.dateTimeErrorPnl.css("display","none");var minsDiv=incByMinutes.key;this.disableMinutesDiv(),minsDiv.removeClass("btnDivEnable").addClass("btnDivDisable");var callbackTime=new Date,existingMinutes=callbackTime.getMinutes();callbackTime.setMinutes(0),callbackTime.setMinutes(existingMinutes+incByMinutes.val),this.updateCallbackTime(callbackTime)},enableRescheduleMode:function(){this.dateTimeValue.hide(),this.dateTimeCombo.showfn(),this.updateCallbackTime(new Date(this.promisekeeperInfo.callbackTime)),this.saveCancelBtnControl.showfn(),this.editOKBtnControl.hide(),this.minutesDiv.showfn(),this.rescheduleTimeout.showfn(),this._isReschedule=!0,clearInterval(this._runningIntervalId),this.cancelBtnContainer.off("click").on("click",$.proxy(this.rescheduleCancelBtnClick,this)).hide(),this.closeBtn.off("click").on("click",$.proxy(this.reschedulecloseBtnClick,this)).hide()},disableRescheduleMode:function(){this.cancelBtnContainer.off("click").on("click",$.proxy(this.cancelBtnClick,this)).showfn(),this.closeBtn.off("click").on("click",$.proxy(this.okBtnClick,this)).showfn(),this.rescheduleTimeout.hide(),this._isReschedule=!1,clearInterval(this._runningIntervalId)},_stopRescheduleTimer:function(){clearInterval(this._runningIntervalId),this.options.container.closePromiseKeeperDetailsAndShowHome(),this.promisekeeperInfo=null},rescheduleCommitmentReminder:function(data,skills){var that=this;that.refresh(data,skills),that.enableRescheduleMode();var remainingTime=data._timeout;function setFormattedTime(remainingTime){var minutes=parseInt(remainingTime/60),seconds=remainingTime%60;minutes<10&&(minutes="0"+minutes),seconds<10&&(seconds="0"+seconds),that.rescheduleTimeout.text(IC_Localization.commitmentRefusedTime.replace("{0}",minutes).replace("{1}",seconds))}setFormattedTime(remainingTime),that._runningIntervalId=setInterval(function(){setFormattedTime(remainingTime),0==--remainingTime&&that._stopRescheduleTimer()},1e3),this.renderCustomScrollBar(this.promiseKeeperDetails),this.promiseKeeperDetails.mCustomScrollbar("scrollTo","bottom")},setFocusToCommitmentDetailsHeader:function(){this.headerPanel.trigger("focus")},setFocusToDateTimeDiv:function(){this.dateTimeDiv.trigger("focus")},resize:function(availableWidth,availableHeight){this.promiseKeeperDetails.css({height:availableHeight-35})}})}(jQuery);