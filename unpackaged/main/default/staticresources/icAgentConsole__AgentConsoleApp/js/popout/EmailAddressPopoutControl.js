!function($){$.widget("AgentConsole.emailAddressPopoutControl",{options:{controller:null,resourceBase:"",contact:null},_init:function(){},_contact:null,hiddenMailDiv:null,toAddr:[],ccAddr:[],bccAddr:[],index:-1,emailType:"",sendIconClicked:!1,attachmentFilesNode:{},totalFilesSize:0,totalFilesAttachedCount:0,totalFilesAttachedObj:{},attachmentNamesList:[],attachmentContentList:[],countTotalFiles:0,toTextChildWidth:0,iconsDisabled:!1,emailAddress:{},isDblClick:!1,_create:function(){this.mailCompSend=$("<div class='sendDiv' title = '"+IC_Localization.send+"' />").appendTo(this.element),this.mailCompSendIMG=$('<img class="sendIMG" id="sentMail" src="'+this.options.resourceBase+'/css/images/mailsend.png" />').appendTo(this.mailCompSend),that=this,this.enableSendIcon();var addressRoot=$('<div class="addressRoot" />').appendTo(this.element);this.fromDateDiv=$('<div class="fromDateDiv"> </div>').appendTo(addressRoot);var fromDiv=$('<div class = "fromDiv" />').appendTo(this.fromDateDiv);this.fromLabel=$('<div class = "fromLabel" > '+IC_Localization.from+"</div>").appendTo(fromDiv),IC_Common.setTextWithEllipsis(this.fromLabel,IC_Localization.from,50),this.fromValue=$('<div class = "fromValue" />').appendTo(fromDiv),this.dateDiv=$('<div class = "dateDiv" />').appendTo(this.fromDateDiv);var emailAddrLayout=$('<div class = "emailAddrLayout" />').appendTo(addressRoot);this.toDiv=$('<div class="toDiv"> </div>').appendTo(emailAddrLayout),this.toLabelDiv=$('<div class="elabelDiv">'+IC_Localization.to+":</div>").appendTo(this.toDiv),this.toTxt=$('<div class="toTxtDiv"></div>').appendTo(this.toDiv),this.toTxtContent=$('<div class="toTxtContent"></div>').appendTo(this.toTxt),this.ccLnk=$('<div class="toLnk" >'+IC_Localization.cc+"</div>").appendTo(this.toDiv).on("click",$.proxy(this.toggleCcLnk,this)),IC_Common.setTextWithEllipsis(this.ccLnk,IC_Localization.cc,22),this.bccLnk=$('<div class="toLnk" >'+IC_Localization.bcc+"</div>").appendTo(this.toDiv).on("click",$.proxy(this.toggleBccLnk,this)),IC_Common.setTextWithEllipsis(this.bccLnk,IC_Localization.bcc,22),this.ccDiv=$('<div class="ccDiv"> </div>').appendTo(emailAddrLayout),this.ccDiv.hide(),this.ccLabelDiv=$('<div class="elabelDiv">'+IC_Localization.cc+"</div>").appendTo(this.ccDiv),IC_Common.setTextWithEllipsis(this.ccLabelDiv,IC_Localization.cc+":",50),this.ccTxt=$('<div class="ccTxtDiv ccTxtDivAlign"></div>').appendTo(this.ccDiv),this.ccTxtContent=$('<div class="toTxtContent"></div>').appendTo(this.ccTxt),this.bccDiv=$('<div class="bccDiv"> </div>').appendTo(emailAddrLayout),this.bccDiv.hide(),this.bccLabelDiv=$('<div class="elabelDiv">'+IC_Localization.bcc+"</div>").appendTo(this.bccDiv),IC_Common.setTextWithEllipsis(this.bccLabelDiv,IC_Localization.bcc+":",50),this.bccTxt=$('<div class="ccTxtDiv"></div>').appendTo(this.bccDiv),this.bccTxtContent=$('<div class="toTxtContent"></div>').appendTo(this.bccTxt),this.subjectDiv=$('<div class="subjectDiv"> </div>').appendTo(emailAddrLayout),this.subLabelDiv=$('<div class="elabelDiv">'+IC_Localization.subject+"</div>").appendTo(this.subjectDiv),IC_Common.setTextWithEllipsis(this.subLabelDiv,IC_Localization.subject+":",50),this.subTxtDiv=$('<div class="subTxtDiv"></div>').appendTo(this.subjectDiv),this.subTxt=$('<input type="text" class = "userselectable subjectTxt" name="subjectTxt" title="'+IC_Localization.subject+'"/>').appendTo(this.subTxtDiv),this.attachementDiv=$('<div class="attachementDiv"> </div>').appendTo(emailAddrLayout),this.attachementDiv.hide(),this.attachIconDiv=$('<div class="elabelDiv"> </div>').appendTo(this.attachementDiv);$('<img src = "'+this.options.resourceBase+'/css/images/Attach.png" class="attachIcon" />').appendTo(this.attachIconDiv);this.attachmentNamesDiv=$('<div class="attachmentNamesDiv"> </div>').appendTo(this.attachementDiv),setTimeout($.proxy(this.setToTextWidth,this),0),this.subTxt.on("keyup",function(e){that.persistAddressSet("SUB")}),this.subTxt.on("keydown",function(e){if(!e.shiftKey&&9===e.keyCode||59===e.keyCode)return e.preventDefault&&e.preventDefault(),document.getElementById("emailEditor_ifr").contentDocument.body.focus(),!1});var lastClick=0;this.subTxt.on("mousedown",function(e){lastClick=e.which}).on("focus",function(e){var that=this;1!=lastClick&&setTimeout(function(){that.selectionStart=that.selectionEnd=1e4},0),lastClick=0})},enableEmailAddressIcons:function(){var that=this;this.iconsDisabled&&(this.enableSendIcon(),this.ccLnk.on("click",function(){that.toggleCcLnk()}),this.bccLnk.on("click",function(){that.toggleBccLnk()}),this.iconsDisabled=!1)},toggleEmailIcon:function(toggle){toggle?(this.mailCompSendIMG.css("cursor","pointer"),this.mailCompSendIMG.attr("src",this.options.resourceBase+"/css/images/enable-mailsend.png")):(this.mailCompSendIMG.css("cursor","defulat"),this.mailCompSendIMG.attr("src",this.options.resourceBase+"/css/images/mailsend.png"))},enableSendIcon:function(){var that=this;this.mailCompSend.hoverfn(function(){!1===that.sendIconClicked&&that.toggleEmailIcon(!0)},function(){(""===that.ccTxtContent.text().trim()&&""===that.bccTxtContent.text().trim()&&""===that.toTxtContent.text().trim()||IC_Validation.isNotNullOrUndefinedString(that.emailAddress)&&that.emailAddress.isError)&&that.toggleEmailIcon(!1)}),this.mailCompSend.on("click",function(){!1===that.sendIconClicked&&(that.options.controller.getMailContent(),(""===that.ccTxtContent.text().trim()&&""===that.bccTxtContent.text().trim()&&""===that.toTxtContent.text().trim()||IC_Validation.isNotNullOrUndefinedString(that.emailAddress)&&that.emailAddress.isError)&&that.toggleEmailIcon(!1))})},disableEmailAddressIcons:function(){this.mailCompSend.off("mouseenter mouseleave click"),this.ccLnk.off("click"),this.bccLnk.off("click"),$(".mailClose").hide(),this.iconsDisabled=!0},setSendIconClicked:function(sendIconClicked){this.sendIconClicked=sendIconClicked},startNewWorker:function(event){var files=event.target.files,countFileSize=0,countFiles=0,that=this;if(countFiles+=this.countTotalFiles,$.each(files,function(i,file){countFileSize+=file.size,countFiles++}),countFiles>99)this.options.controller.showEmailErrorMsg(IC_Localization.attachmentError1);else{if(!(countFileSize>10485760))return this.totalFilesSize+=countFileSize,this.totalFilesSize>10485760?(this.options.controller.showEmailErrorMsg(IC_Localization.attachmentError),void(this.totalFilesSize-=countFileSize)):void $.each(files,function(i,file){var worker=new Worker(that.options.resourceBase+"/js/common/AttachmentWorker.js"),elements={};that.countTotalFiles+=1,that.totalFilesAttachedCount+=1,that.totalFilesAttachedObj[file.name+that.totalFilesAttachedCount]={name:file.name,content:"",isNewAttachment:!0},worker.postMessage(file),elements.fileNumber=that.totalFilesAttachedCount;var newDiv=$('<div class="attachment"></div>').appendTo(that.attachmentNamesDiv),attachmentFile=$('<div class="attachmentName">'+file.name+"</div>").appendTo(newDiv);IC_Common.setTextWithEllipsis(attachmentFile,file.name,150),elements.attachmentFile=attachmentFile;var loading=$('<img src = "'+that.options.resourceBase+'/css/images/spinner.gif" class="loadingAttachment" />').appendTo(newDiv);elements.loading=loading;var crossIcon=$('<img src = "'+that.options.resourceBase+'/css/images/close.png" class="loadingAttachment" />').appendTo(newDiv);crossIcon.on("click",function(){newDiv.remove(),that.totalFilesSize-=file.size,that.countTotalFiles-=1,0===that.countTotalFiles&&that.attachementDiv.hide(),delete that.totalFilesAttachedObj[file.name+elements.fileNumber]}),elements.crossIcon=crossIcon,elements.newDiv=newDiv,that.attachmentFilesNode[file.name]=elements,worker.onmessage=function(event){var splitResultObj=event.data.split(","),fileName=splitResultObj[0],fileNumber=that.attachmentFilesNode[fileName].fileNumber;that.attachmentFilesNode[fileName].loading.remove(),that.totalFilesAttachedObj[fileName+fileNumber].content=splitResultObj[1],this.terminate()},that.countTotalFiles>0&&(that.attachementDiv.showfn(),that.options.controller.resizeEditorPanel())});this.options.controller.showEmailErrorMsg(IC_Localization.attachmentError)}},showInboundAttachments:function(attachments){var that=this;$.each(attachments,function(i,fileServerPath){var splitFileServerPath=fileServerPath.split("\\"),fileName=splitFileServerPath[splitFileServerPath.length-1];that.totalFilesAttachedObj[fileName]={name:fileName,content:"",size:0,isNewAttachment:!1,serverPath:fileServerPath},that.countTotalFiles+=1;var newDiv=$('<div class="attachment"></div>').appendTo(that.attachmentNamesDiv),attachmentFile=$('<div class="attachmentName">'+fileName+"</div>").appendTo(newDiv);IC_Common.setTextWithEllipsis(attachmentFile,fileName,150);var crossIcon=$('<img src = "'+that.options.resourceBase+'/css/images/close.png" class="loadingAttachment" />').appendTo(newDiv);that.attachementDiv.showfn(),crossIcon.on("click",function(){newDiv.remove(),that.totalFilesSize-=that.totalFilesAttachedObj[fileName].size,that.countTotalFiles-=1,0===that.countTotalFiles&&that.attachementDiv.hide(),delete that.totalFilesAttachedObj[fileName]})})},addInboundAttachmentContent:function(fileName,fileContent,emailType){var that=this;this.totalFilesAttachedObj[fileName].content=fileContent,this.decodeFileContent(fileName,fileContent),"forward"!==emailType&&"draft"!==emailType||setTimeout(function(){that.updateView(emailType)},2e3)},decodeFileContent:function(name,content){var bytes=atob(content);IC_Validation.isNotNullOrUndefinedString(this.totalFilesAttachedObj[name])&&(this.totalFilesAttachedObj[name].size=bytes.length,this.totalFilesSize+=bytes.length)},getAttachmentContentList:function(){var attachmentContentList="";return $.each(this.totalFilesAttachedObj,function(key,obj){$.each(obj,function(prop,val){"content"===prop&&(attachmentContentList=""==attachmentContentList?val:attachmentContentList+"|"+val)})}),attachmentContentList},getAttachmentNamesList:function(){var attachmentNamesList="";return $.each(this.totalFilesAttachedObj,function(key,obj){$.each(obj,function(prop,val){"name"===prop&&(attachmentNamesList=""==attachmentNamesList?val:attachmentNamesList+"|"+val)})}),attachmentNamesList},getOriginalAttachmentNames:function(){var originalAttachments="";return $.each(this.totalFilesAttachedObj,function(i,fileAttachObj){0==fileAttachObj.isNewAttachment&&(originalAttachments+=fileAttachObj.serverPath+"|")}),originalAttachments.substr(0,originalAttachments.length-1)},getNewAttachmentNames:function(){var newAttachmentNames="";return $.each(this.totalFilesAttachedObj,function(i,fileAttachObj){1==fileAttachObj.isNewAttachment&&(newAttachmentNames+=fileAttachObj.name+"|")}),newAttachmentNames.substr(0,newAttachmentNames.length-1)},getNewAttachmentContents:function(){var newAttachmentContents="";return $.each(this.totalFilesAttachedObj,function(i,fileAttachObj){1==fileAttachObj.isNewAttachment&&(newAttachmentContents+=fileAttachObj.content+"|")}),newAttachmentContents.substr(0,newAttachmentContents.length-1)},resetAttachmentVariables:function(){this.attachmentFilesNode={},this.totalFilesSize=0,this.totalFilesAttachedCount=0,this.totalFilesAttachedObj={},this.attachmentNamesList=[],this.attachmentContentList=[],this.countTotalFiles=0,this.attachementDiv.hide(),this.attachmentNamesDiv.empty()},toggleBccLnk:function(){"block"===this.bccDiv.css("display")?(this.bccDiv.hide(),this.bccTxtContent.children().not(".mailTxt").remove(),this.persistAddressSet("BCC")):(this.bccDiv.showfn(),this.bccTxtBox.trigger("focus"),this.resizeBccTextDiv()),this.options.controller.renderCustomScroll()},toggleCcLnk:function(){"block"===this.ccDiv.css("display")?(this.ccDiv.hide(),this.ccTxtContent.children().not(".mailTxt").remove(),this.persistAddressSet("CC")):(this.ccDiv.showfn(),this.resizeCcTextDiv(),this.ccTxtBox.trigger("focus")),this.options.controller.resizeEditorPanel()},toggleAttachement:function(){"block"===this.attachementDiv.css("display")?this.attachementDiv.hide():this.attachementDiv.showfn(),this.options.controller.resizeEditorPanel()},setToTextWidth:function(){var fullWidth=this.emailPanelWidth,fromValueWidth=(this.subLabelDiv.outerWidth(),this.fromDateDiv.width()-60-this.dateDiv.width()-this.fromLabel.width());toRemainWidth=207,this.toTxt.css("width",fullWidth-toRemainWidth+"px"),this.ccTxt.css("width",fullWidth-157+"px"),this.bccTxt.css("width",fullWidth-157+"px"),this.subTxtDiv.css("width",fullWidth-163+"px"),this.fromValue.css("width",fromValueWidth+"px"),IC_Common.setTextWithEllipsis(this.fromValue,this.fromValue.text(),fromValueWidth,!0);var emailWidth=fullWidth-252,emailCcWidth=fullWidth-210,that=this;setTimeout(function(){that.resizeMailDiv(that.toTxtContent,emailWidth),that.resizeMailDiv(that.ccTxtContent,emailCcWidth),that.resizeMailDiv(that.bccTxtContent,emailCcWidth),that.resizeToTextDiv()},0)},resizeMailDiv:function(domObj,width){var mailContent,mailValue,childObject=null;domObj.children().each(function(){!0===(childObject=$(this)).is("div")&&(mailContent=childObject.children()[0],mailContent=$(mailContent),mailValue=mailContent.text(),mailContent.css("width","auto"),mailContent.text(mailValue),IC_Common.setTextWithEllipsis(mailContent,mailValue,width))})},resizeWidget:function(emailPanelWidth){emailPanelWidth&&(this.emailPanelWidth=emailPanelWidth),setTimeout($.proxy(this.setToTextWidth,this),0),setTimeout($.proxy(this.resizeToTextDiv,this),0),setTimeout($.proxy(this.resizeCcTextDiv,this),0),setTimeout($.proxy(this.resizeBccTextDiv,this),0)},createTextBox:function(){if(void 0==this.toTxtBox){var that=this;this.toTxtBox=$('<input type="text" class="userselectable mailTxt mailTxtAlign" name="toTxtBox" title="'+IC_Localization.to+" "+IC_Localization.address+'"/>').appendTo(this.toTxtContent),this.toTxtBox.on("keydown",function(e){if(e.shiftKey){if(9===e.keyCode||59===e.keyCode)return e.preventDefault&&e.preventDefault(),document.getElementById("emailEditor_ifr").contentDocument.body.focus(),!1}else if(9===e.keyCode||59===e.keyCode){if(""!==$.trim(that.toTxtBox.val()))return e.preventDefault&&e.preventDefault(),that.createToEmailDiv(that.toTxtBox.val()),that.persistAddressSet("TO"),!1}else if(8===e.keyCode&&""===$.trim(that.toTxtBox.val())){var txtBoxParent=that.toTxtBox.parent();if(that.hiddenMailDiv=null,that.isDblClick=!1,that.toTxtBox.appendTo(that.toTxtContent),that.toTxtBox.addClass("mailTxtAlign"),that.toTxtBox.val(""),that.toTxtBox.trigger("focus"),txtBoxParent.hasClass("toTxtContent")){var mailDivNodes=$(".toDiv .mailDiv");mailDivNodes.length>=1&&$(mailDivNodes[mailDivNodes.length-1]).remove()}else txtBoxParent.remove();that.createToEmailDiv(that.toTxtBox.val()),that.persistAddressSet("TO"),that.resizeToTextBox(that.toTxtBox,that.toTxtContent,$.proxy(that.resizeToTextDiv,that))}}),this.toTxtBox.on("keyup",function(e){that.resizeToTextBox(that.toTxtBox,that.toTxtContent,$.proxy(that.resizeToTextDiv,that))}),this.toTxtBox.on("focusout",function(e){that.createToEmailDiv(that.toTxtBox.val()),that.persistAddressSet("TO")});var lastClick=0;this.toTxtBox.on("mousedown",function(e){lastClick=e.which}).on("focus",function(e){var that=this;1!=lastClick&&setTimeout(function(){that.selectionStart=that.selectionEnd=1e4},0),lastClick=0}),this.toTxtContent.on("click",function(e){-1===e.target.className.indexOf("mailContent")&&that.toTxtBox.trigger("focus")})}},resizeToTextBox:function(txtObj,txtContainer,callback){var txtWidth=txtObj.val().width(),maxWidth=txtContainer.width()-4,adjust=maxWidth/2;txtWidth=txtWidth>adjust?txtWidth+adjust/2:maxWidth-adjust/2,maxWidth=!0===IC_Validation.isValidObject(this.hiddenMailDiv)?maxWidth-28:maxWidth,(txtWidth=!0===IC_Validation.isValidObject(this.hiddenMailDiv)&&txtObj.val().width()+30<=maxWidth?txtObj.val().width()+30:txtWidth<maxWidth?txtWidth:maxWidth-1)>0&&txtObj.css("width",txtWidth+"px"),"function"==typeof callback&&callback()},createToEmailDiv:function(mailValue){if(IC_Validation.isNullOrEmptyOrEmptySpace(mailValue))return!0;var mailDiv,mailContent,mailClose,isValidEmail=!0===/^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/.test(mailValue),that=this;if(IC_Validation.isValidObject(this.hiddenMailDiv)?((mailContent=this.hiddenMailDiv).showfn(),this.hiddenMailDiv=null,this.toTxtBox.detach(),this.toTxtBox.appendTo(this.toTxtContent),this.toTxtBox.addClass("mailTxtAlign"),this.toTxtBox.val(""),this.toTxtBox.trigger("focus")):this.isDblClick?this.isDblClick=!1:(this.isDblClick=!1,mailDiv=$('<div class="mailDiv"></div>').insertBefore(this.toTxtBox),mailContent=$('<div class = "mailContent"></div>').appendTo(mailDiv),mailClose=$('<img class="mailClose" src = "'+this.options.resourceBase+'/css/images/close.png" />').appendTo(mailDiv),"Parked"!==this._contact.status?(mailClose.on("click",function(){that.hiddenMailDiv=null,that.toTxtBox.detach(),that.toTxtBox.appendTo(that.toTxtContent),that.toTxtBox.addClass("mailTxtAlign"),that.toTxtBox.val(""),that.toTxtBox.trigger("focus"),mailDiv.remove(),that.persistAddressSet("TO"),that.resizeToTextBox(that.toTxtBox,that.toTxtContent,$.proxy(that.resizeToTextDiv,that))}),mailContent.on("dblclick",function(){that.isDblClick=!0,IC_Validation.isValidObject(that.hiddenMailDiv)&&that.hiddenMailDiv.showfn(),that.hiddenMailDiv=mailContent,mailContent.hide(),that.toTxtBox.detach(),that.toTxtBox.prependTo(mailDiv),that.toTxtBox.removeClass("mailTxtAlign"),that.toTxtBox.val(mailContent.text()),that.toTxtBox.trigger("focus"),that.resizeToTextBox(that.toTxtBox,that.toTxtContent,$.proxy(that.resizeToTextDiv,that))})):mailClose.hide()),mailContent){!1===isValidEmail?mailContent.addClass("invalidEmail"):mailContent.removeClass("invalidEmail"),this.toTxtBox.val(""),mailContent.text(mailValue);var maxWidth=this.toTxtContent.width()-35;mailContent.css("width","auto"),IC_Common.setTextWithEllipsis(mailContent,mailValue,maxWidth),this.resizeToTextBox(this.toTxtBox,this.toTxtContent,$.proxy(this.resizeToTextDiv,this)),this.setToTextWidth()}},resizeToTextDiv:function(){var txtContentHeight=this.toTxtContent.height();txtContentHeight>=55?(this.toTxt.css({height:"54px","overflow-y":"scroll","overflow-x":"hidden"}),this.toDiv.css("height","56px")):(this.toTxt.css({height:"auto","overflow-y":"hidden","overflow-x":"hidden"}),this.toDiv.css("height",txtContentHeight+2+"px")),this.options.controller.resizeEditorPanel()},createCcTextBox:function(){var that=this;if(void 0==this.ccTxtBox){this.ccTxtBox=$('<input type="text" class="userselectable mailTxt mailTxtAlign"  title="'+IC_Localization.cc+'"/>').appendTo(this.ccTxtContent),this.ccTxtBox.on("keydown",function(e){if(9===e.keyCode||59===e.keyCode){if(""!==$.trim(that.ccTxtBox.val()))return e.preventDefault&&e.preventDefault(),that.createCcEmailDiv(that.ccTxtBox.val()),that.persistAddressSet("CC"),!1}else if(8===e.keyCode&&""===$.trim(that.ccTxtBox.val())){var txtBoxParent=that.ccTxtBox.parent();if(that.hiddenMailDiv=null,that.isDblClick=!1,that.ccTxtBox.appendTo(that.ccTxtContent),that.ccTxtBox.addClass("mailTxtAlign"),that.ccTxtBox.val(""),that.ccTxtBox.trigger("focus"),txtBoxParent.hasClass("toTxtContent")){var mailDivNodes=$(".ccDiv .mailDiv");mailDivNodes.length>=1&&$(mailDivNodes[mailDivNodes.length-1]).remove()}else txtBoxParent.remove();that.createCcEmailDiv(that.ccTxtBox.val()),that.persistAddressSet("CC"),that.resizeToTextBox(that.ccTxtBox,that.ccTxtContent,$.proxy(that.resizeCcTextDiv,that))}}),this.ccTxtBox.on("keyup",function(e){that.resizeToTextBox(that.ccTxtBox,that.ccTxtContent,$.proxy(that.resizeCcTextDiv,that))});var lastClick=0;this.ccTxtBox.on("mousedown",function(e){lastClick=e.which}).on("focus",function(e){var that=this;1!=lastClick&&setTimeout(function(){that.selectionStart=that.selectionEnd=1e4},0),lastClick=0}),this.ccTxtBox.on("focusout",function(e){that.createCcEmailDiv(that.ccTxtBox.val()),that.persistAddressSet("CC")}),this.ccTxtContent.on("click",function(e){-1===e.target.className.indexOf("mailContent")&&that.ccTxtBox.trigger("focus")})}},createCcEmailDiv:function(mailValue){if(IC_Validation.isNullOrEmptyOrEmptySpace(mailValue))return!0;var mailDiv,mailContent,isValidEmail=!0===/^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/.test(mailValue),that=this;if(IC_Validation.isValidObject(this.hiddenMailDiv)?((mailContent=this.hiddenMailDiv).showfn(),this.hiddenMailDiv=null,this.ccTxtBox.detach(),this.ccTxtBox.appendTo(this.ccTxtContent),this.ccTxtBox.addClass("mailTxtAlign"),this.ccTxtBox.val(""),this.ccTxtBox.trigger("focus")):this.isDblClick?this.isDblClick=!1:(mailDiv=$('<div class="mailDiv"></div>').insertBefore(this.ccTxtBox),mailContent=$('<div class = "mailContent"></div>').appendTo(mailDiv),$('<img class="mailClose" src = "'+this.options.resourceBase+'/css/images/close.png" />').appendTo(mailDiv).on("click",function(){that.hiddenMailDiv=null,that.ccTxtBox.detach(),that.ccTxtBox.appendTo(that.ccTxtContent),that.ccTxtBox.addClass("mailTxtAlign"),that.ccTxtBox.val(""),that.ccTxtBox.trigger("focus"),mailDiv.remove(),that.persistAddressSet("CC"),that.resizeToTextBox(that.ccTxtBox,that.ccTxtContent,$.proxy(that.resizeCcTextDiv,that))}),mailContent.on("dblclick",function(){that.isDblClick=!0,IC_Validation.isValidObject(that.hiddenMailDiv)&&that.hiddenMailDiv.showfn(),that.hiddenMailDiv=mailContent,mailContent.hide(),that.ccTxtBox.detach(),that.ccTxtBox.prependTo(mailDiv),that.ccTxtBox.removeClass("mailTxtAlign"),that.ccTxtBox.val(mailContent.text()),that.ccTxtBox.trigger("focus"),that.resizeToTextBox(that.ccTxtBox,that.ccTxtContent,$.proxy(that.resizeCcTextDiv,that))})),mailContent){!1===isValidEmail?mailContent.addClass("invalidEmail"):mailContent.removeClass("invalidEmail"),this.ccTxtBox.val("");var maxWidth=this.ccTxtContent.width()-30;mailContent.css("width","auto"),IC_Common.setTextWithEllipsis(mailContent,mailValue,maxWidth),this.resizeToTextBox(this.ccTxtBox,this.ccTxtContent,$.proxy(this.resizeCcTextDiv,this)),this.setToTextWidth()}},resizeCcTextDiv:function(){var txtContentHeight=this.ccTxtContent.height();txtContentHeight>=55?(this.ccTxt.css({height:"54px","overflow-y":"scroll","overflow-x":"hidden"}),this.ccDiv.css("height","56px")):(this.ccTxt.css({height:"auto","overflow-y":"hidden","overflow-x":"hidden"}),this.ccDiv.css("height",txtContentHeight+2+"px")),this.options.controller.resizeEditorPanel()},createBccTextBox:function(){var that=this;if(void 0==this.bccTxtBox){this.bccTxtBox=$('<input type="text" class="userselectable mailTxt mailTxtAlign" title="'+IC_Localization.bcc+'"/>').appendTo(this.bccTxtContent),this.bccTxtBox.on("keydown",function(e){if(9===e.keyCode||59===e.keyCode){if(""!==$.trim(that.bccTxtBox.val()))return e.preventDefault&&e.preventDefault(),that.createBccEmailDiv(that.bccTxtBox.val()),that.persistAddressSet("BCC"),!1}else if(8===e.keyCode&&""===$.trim(that.bccTxtBox.val())){var txtBoxParent=that.bccTxtBox.parent();if(that.hiddenMailDiv=null,that.isDblClick=!1,that.bccTxtBox.appendTo(that.bccTxtContent),that.bccTxtBox.addClass("mailTxtAlign"),that.bccTxtBox.val(""),that.bccTxtBox.trigger("focus"),txtBoxParent.hasClass("toTxtContent")){var mailDivNodes=$(".bccDiv .mailDiv");mailDivNodes.length>=1&&$(mailDivNodes[mailDivNodes.length-1]).remove()}else txtBoxParent.remove();that.createBccEmailDiv(that.bccTxtBox.val()),that.persistAddressSet("BCC"),that.resizeToTextBox(that.bccTxtBox,that.bccTxtContent,$.proxy(that.resizeBccTextDiv,that))}}),this.bccTxtBox.on("focusout",function(e){that.createBccEmailDiv(that.bccTxtBox.val()),that.persistAddressSet("BCC")});var lastClick=0;this.bccTxtBox.on("mousedown",function(e){lastClick=e.which}).on("focus",function(e){var that=this;1!=lastClick&&setTimeout(function(){that.selectionStart=that.selectionEnd=1e4},0),lastClick=0}),this.bccTxtBox.on("keyup",function(e){that.resizeToTextBox(that.bccTxtBox,that.bccTxtContent,$.proxy(that.resizeBccTextDiv,that))}),this.bccTxtContent.on("click",function(e){-1===e.target.className.indexOf("mailContent")&&that.bccTxtBox.trigger("focus")})}},createBccEmailDiv:function(mailValue){if(IC_Validation.isNullOrEmptyOrEmptySpace(mailValue))return!0;var mailDiv,mailContent,isValidEmail=!0===/^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/.test(mailValue),that=this;if(IC_Validation.isValidObject(this.hiddenMailDiv)?((mailContent=this.hiddenMailDiv).showfn(),this.hiddenMailDiv=null,this.bccTxtBox.detach(),this.bccTxtBox.appendTo(this.bccTxtContent),this.bccTxtBox.removeClass("mailTxtAlign"),this.bccTxtBox.val(""),this.bccTxtBox.trigger("focus")):this.isDblClick?this.isDblClick=!1:(mailDiv=$('<div class="mailDiv"></div>').insertBefore(this.bccTxtBox),mailContent=$('<div class = "mailContent"></div>').appendTo(mailDiv),$('<img class="mailClose" src = "'+this.options.resourceBase+'/css/images/close.png" />').appendTo(mailDiv).on("click",function(){that.hiddenMailDiv=null,that.bccTxtBox.detach(),that.bccTxtBox.appendTo(that.bccTxtContent),that.bccTxtBox.addClass("mailTxtAlign"),that.bccTxtBox.val(""),that.bccTxtBox.trigger("focus"),mailDiv.remove(),that.persistAddressSet("BCC"),that.resizeToTextBox(that.bccTxtBox,that.bccTxtContent,$.proxy(that.resizeBccTextDiv,that))}),mailContent.on("dblclick",function(){that.isDblClick=!0,IC_Validation.isValidObject(that.hiddenMailDiv)&&that.hiddenMailDiv.showfn(),that.hiddenMailDiv=mailContent,mailContent.hide(),that.bccTxtBox.detach(),that.bccTxtBox.prependTo(mailDiv),that.bccTxtBox.removeClass("mailTxtAlign"),that.bccTxtBox.val(mailContent.text()),that.bccTxtBox.trigger("focus"),that.resizeToTextBox(that.bccTxtBox,that.bccTxtContent,$.proxy(that.resizeBccTextDiv,that))})),mailContent){!1===isValidEmail?mailContent.addClass("invalidEmail"):mailContent.removeClass("invalidEmail"),this.bccTxtBox.val("");var maxWidth=this.bccTxtContent.width()-30;mailContent.css("width","auto"),IC_Common.setTextWithEllipsis(mailContent,mailValue,maxWidth),this.resizeToTextBox(this.bccTxtBox,this.bccTxtContent,$.proxy(this.resizeBccTextDiv,this)),this.setToTextWidth()}},resizeBccTextDiv:function(){var txtContentHeight=this.bccTxtContent.height();txtContentHeight>=55?(this.bccTxt.css({height:"54px","overflow-y":"scroll","overflow-x":"hidden"}),this.bccDiv.css("height","56px")):(this.bccTxt.css({height:"auto","overflow-y":"hidden","overflow-x":"hidden"}),this.bccDiv.css("height",txtContentHeight+2+"px")),this.options.controller.resizeEditorPanel()},getEmailAddress:function(sendMail){var mailId,address={},to="",cc="",bcc="",filter=/^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/,noOfRecepient=0,messageTxt="";return this.toTxtContent.children(".mailDiv").each(function(){if(mailId=this.children[0].textContent,!0!==filter.test(mailId))return messageTxt=mailId,!1;to+=mailId+",",noOfRecepient+=1}),!1===IC_Validation.isNullOrEmptyOrEmptySpace(messageTxt)?(this.options.controller.showEmailErrorMsg(IC_Localization.errorMsgBadMailId.replace("{0}",messageTxt)),address.isError=!0,address):0===noOfRecepient&&!0===sendMail?(this.options.controller.showEmailErrorMsg(IC_Localization.errorMsgReqToAddr),address.isError=!0,address):(to.length>1&&(to=to.substr(0,to.length-1)),this.ccTxtContent.children(".mailDiv").each(function(){if(mailId=this.children[0].textContent,!0!==filter.test(mailId))return messageTxt=mailId,!1;cc+=mailId+",",noOfRecepient+=1}),!1===IC_Validation.isNullOrEmptyOrEmptySpace(messageTxt)?(this.options.controller.showEmailErrorMsg(IC_Localization.errorMsgBadMailId.replace("{0}",messageTxt)),address.isError=!0,address):(cc.length>1&&(cc=cc.substr(0,cc.length-1)),this.bccTxtContent.children(".mailDiv").each(function(){if(mailId=this.children[0].textContent,!0!==filter.test(mailId))return messageTxt=mailId,!1;bcc+=mailId+",",noOfRecepient+=1}),!1===IC_Validation.isNullOrEmptyOrEmptySpace(messageTxt)?(this.options.controller.showEmailErrorMsg(IC_Localization.errorMsgBadMailId.replace("{0}",messageTxt)),address.isError=!0,address):(bcc.length>1&&(bcc=bcc.substr(0,bcc.length-1)),address.to=to,address.cc=cc,address.bcc=bcc,address.sub=this.subTxt.val(),address.emailType=this.emailType,address)))},getEmailDetails:function(){var mailId,toAddr="",ccAddr="",bccAddr="",fromAddr="",subject="",isDraft=!!IC_Validation.isNotNullOrEmpty(this.options.controller.persistEmailInfo.action);return isDraft?(fromAddr=this.fromValue.text(),subject=this.subTxt.val(),this.toTxtContent.children(".mailDiv").each(function(){mailId=this.children[0].textContent,toAddr+=mailId+","}),this.ccTxtContent.children(".mailDiv").each(function(){mailId=this.children[0].textContent,ccAddr+=mailId+","}),this.bccTxtContent.children(".mailDiv").each(function(){mailId=this.children[0].textContent,bccAddr+=mailId+","})):(fromAddr=this._contact.fromAddress,toAddr=this._contact.toAddress,ccAddr=this._contact.ccAddress,subject=this._contact.subject),{skillId:this._contact.skillId,fromAddress:fromAddr,toAddress:toAddr,ccAddress:ccAddr,bccAddress:bccAddr,subject:subject,attachmentNames:this.getNewAttachmentNames(),attachments:this.getNewAttachmentContents(),isDraft:isDraft,originalAttachmentNames:this.getOriginalAttachmentNames()}},getSubject:function(){var isNewMail=!0,sub=this._contact.subject;return(/FW:/i.test(sub)||/RE:/i.test(sub))&&(isNewMail=!1),isNewMail?"reply"===this.emailType||"replyAll"===this.emailType?sub="RE: "+sub:"forward"===this.emailType&&(sub="FW: "+sub):"reply"===this.emailType||"replyAll"===this.emailType?sub=sub.replace(/fw:/gi,"RE:"):"forward"===this.emailType&&(sub=sub.replace(/re:/gi,"FW:")),sub},updateView:function(emailType){var that=this;this.emailType=emailType,this.toTxtContent.children().not(".mailTxt").remove(),this.ccTxtContent.children().not(".mailTxt").remove(),this.bccTxtContent.children().not(".mailTxt").remove();var subject=this.getSubject();this.subTxt.attr("readonly",!1),this.bccDiv.hide(),IC_Common.setTextWithEllipsis(this.toLabelDiv,IC_Localization.to+":",50),this.toTxt.css("margin-left","0px"),this.ccLnk.css("cursor","pointer"),this.ccTxtBox.attr("readonly",!1),this.toTxtBox.attr("readonly",!1);var localeTimeFormat=this.options.controller.options.controller.options.localeDateTimeFormat,localeCode=this.options.controller.options.controller.options.localeCode,mailDate=new Date;if(IC_Validation.isNullOrEmpty(this._contact.ccAddress)&&this.ccDiv.hide(),"outbound"===emailType){var outBoundSub;this._contact.time;mailDate=new Date(this._contact.time);var persistEmailInfo=this.options.controller.persistEmailInfo;IC_Validation.isNullOrEmptyOrEmptySpace(persistEmailInfo.to)&&IC_Validation.isNotNullOrUndefinedString(this._contact.toAddress)&&(this.createToEmailDiv(this._contact.toAddress),this.toggleEmailIcon(!0)),this.toTxtContent.one("mouseenter",function(){that.resizeToTextBox(that.toTxtBox,that.toTxtContent,$.proxy(that.resizeToTextDiv,that))}),outBoundSub=IC_Validation.isNotNullOrUndefinedString(persistEmailInfo.sub)?persistEmailInfo.sub:this._contact.subject,this.subTxt.val(outBoundSub)}else"reply"===emailType||"replyAll"===emailType?(mailDate=new Date,this.createToEmailDiv(this._contact.fromAddress),this.subTxt.val(subject),this.toggleEmailIcon(!0),"replyAll"===emailType&&(drawToandCC.apply(this),""===this.ccTxtContent.text().trim()&&""===this.bccTxtContent.text().trim()&&""===this.toTxtContent.text().trim()||this.toggleEmailIcon(!0))):"forward"===emailType?(mailDate=new Date,this.toLabelDiv.text(IC_Localization.to+":"),this.toTxt.css("margin-left","0px"),this.subTxt.val(subject),this.toTxtBox.attr("readonly",!1)):"draft"===emailType&&(mailDate=new Date(this._contact.lastStateTime),this.toLabelDiv.text(IC_Localization.to+":"),this.toTxt.css("margin-left","0px"),this.subTxt.val(subject),drawToandCC.apply(this));function drawToandCC(){var toAddr=this._contact.toAddress.split(";"),toggleEmailIcon=!1;for(i=0;i<toAddr.length;i++)IC_Validation.isNotNullOrUndefinedString(this._contact.pocAddress)&&this._contact.pocAddress.toLowerCase()!=toAddr[i].toLowerCase()&&(this.createToEmailDiv(toAddr[i]),toggleEmailIcon=!0);if(this.toggleEmailIcon(toggleEmailIcon),!1===IC_Validation.isNullOrEmpty(this._contact.ccAddress)){this.ccTxtContent.children().not(".mailTxt").remove(),this.ccDiv.showfn(),this.resizeCcTextDiv();var ccAddr=this._contact.ccAddress.split(";");for(i=0;i<ccAddr.length;i++)this.createCcEmailDiv(ccAddr[i],!0)}}""!==this.toTxtContent.text().trim()&&"Parked"!==this._contact.status||this.toggleEmailIcon(!1),this.dateDiv.text(IC_Common.getAMPMLocale(mailDate.format(localeTimeFormat),localeCode)),this.setToTextWidth(),this.options.controller.showToolsOnLoad()},persistAddressGet:function(){var persistEmailAddress=this.options.controller.persistEmailInfo,i=0,toAddress="",ccAddress="",bccAddress="",toggleEmailIcon=!1;if(IC_Validation.isNotNullOrUndefinedString(persistEmailAddress.to)&&IC_Validation.isNotNullOrUndefinedString(persistEmailAddress.action)&&"reply"!==persistEmailAddress.action&&"replyAll"!==persistEmailAddress.action){for(toAddress=persistEmailAddress.to.split(","),this.toTxtContent.children().not(".mailTxt").remove(),i=0;i<toAddress.length;i++)this.createToEmailDiv(toAddress[i]);toggleEmailIcon=!0}if(IC_Validation.isNotNullOrUndefinedString(persistEmailAddress.cc)&&IC_Validation.isNotNullOrUndefinedString(persistEmailAddress.action)&&"replyAll"!==persistEmailAddress.action){for(ccAddress=persistEmailAddress.cc.split(","),this.ccTxtContent.children().not(".mailTxt").remove(),ccAddress.length>=1?this.ccDiv.showfn():this.ccDiv.hide(),i=0;i<ccAddress.length;i++)this.createCcEmailDiv(ccAddress[i],!1);toggleEmailIcon=!0}if(IC_Validation.isNotNullOrUndefinedString(persistEmailAddress.bcc)){for(bccAddress=persistEmailAddress.bcc.split(","),this.bccTxtContent.children().not(".mailTxt").remove(),bccAddress.length>=1?this.bccDiv.showfn():this.bccDiv.hide(),i=0;i<bccAddress.length;i++)this.createBccEmailDiv(bccAddress[i],!1);toggleEmailIcon=!0}"Parked"!==this._contact.status&&toggleEmailIcon&&this.toggleEmailIcon(!0),IC_Validation.isNotNullOrUndefinedString(persistEmailAddress.sub)&&this.subTxt.val(persistEmailAddress.sub)},persistAddressSet:function(type){this.emailAddress=this.getEmailAddress(!1),""===this.ccTxtContent.text().trim()&&""===this.bccTxtContent.text().trim()&&""===this.toTxtContent.text().trim()||this.emailAddress.isError||"Parked"===this._contact.status?this.toggleEmailIcon(!1):this.toggleEmailIcon(!0),"TO"===type?(this.options.controller.persistEmailInfo.to=this.emailAddress.to,this.options.controller.setEmailPersist()):"CC"===type?(this.options.controller.persistEmailInfo.cc=this.emailAddress.cc,this.options.controller.setEmailPersist()):"BCC"===type?(this.options.controller.persistEmailInfo.bcc=this.emailAddress.bcc,this.options.controller.setEmailPersist()):"SUB"===type&&(this.options.controller.persistEmailInfo.sub=this.emailAddress.sub,this.options.controller.setEmailPersist())},textBoxDisable:function(status){"Interrupted"===status?($(".mailTxt").attr("disabled","disabled"),$(".subjectTxt").attr("disabled","disabled")):($(".mailTxt").removeAttr("disabled","disabled"),$(".subjectTxt").removeAttr("disabled","disabled"))},updateData:function(contact){this._contact=contact;this.fromValue.text(contact.emailFromAddress),IC_Common.setTextWithEllipsis(this.fromValue,this.fromValue.text(),this.fromValue.width()),!1===contact.inbound&&(this.emailType="outbound",this.dateDiv.text(IC_Common.toMailShortDateTimeString(new Date(this._contact.time)))),this.createTextBox(),this.createCcTextBox(),this.createBccTextBox()}})}(jQuery);