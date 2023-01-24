!function($){$.widget("AgentConsole.tagControl",{options:{container:null,resourceBase:"",contact:null,skillTags:null,isPopout:""},availableTags:[],selectedTags:[],_init:function(){},_create:function(){this.availableTags=[],this.selectedTags=[],this.DefaultSearchText=IC_Localization.addTags+" ...",this.skillTags=Object.clone(this.options.skillTags),this.availableTags=Object.clone(this.options.skillTags),this.selectedTags=this.options.contact.tags,this.tagsControl=$('<div class = "container"/>').appendTo(this.element),this.addTagsDiv=$('<div class="addTagsDiv"/>').appendTo(this.tagsControl),this.searchTagsDiv=$('<div class="addTagsSearchDiv"/>').appendTo(this.addTagsDiv),this.searchTextInput=$('<input type="text" id="searchTags" class="addTagsSearchInputText" title="'+IC_Localization.addTags+'" >').addClass("searchTextInput defaultSearchText").appendTo(this.searchTagsDiv),this.searchTextInput.val(this.DefaultSearchText),this.searchTextInput.on("keyup",$.proxy(this.onFilterChange,this)),this.searchTextInput.on("focus",$.proxy(this.onSearchTextClick,this)),this.searchTextInput.on("click",$.proxy(this.onSearchTextClick,this)),this.searchTextInput.on("blur",$.proxy(this.onSearchTextBlur,this)),$("<div/>").css({"border-bottom":"1px solid #CCC","padding-top":"5px"}).appendTo(this.tagsControl),this.listTagContainer=$('<div class="listTagsContainer"/>').appendTo(this.tagsControl),this.listTagsDiv=$('<div class="listTagsDiv"/>').appendTo(this.listTagContainer),this.tagsSelectedPanel=$('<div class = "selectedTags" />').appendTo(this.tagsControl),this.tagsSelectedCont=$('<div class = "tagsSelectedCont" />').appendTo(this.tagsSelectedPanel),this.populateTags(),this.populateSelectedTags(),this.contact=this.options.contact},onFilterChange:function(){for(var tags=this.skillTags,unAssignedTags=[],pattern=this.searchTextInput.val(),i=0;i<tags.length;i++){0==$.grep(this.selectedTags,function(tag){return tag.tagId===tags[i].tagId}).length&&unAssignedTags.push(tags[i])}if(this.availableTags=[],IC_Validation.isNullOrEmptyOrEmptySpace(pattern))this.availableTags=unAssignedTags;else for(var j=0;j<unAssignedTags.length;j++)-1!==unAssignedTags[j].tagName.toLowerCase().indexOf(pattern.toLowerCase())&&this.availableTags.push(unAssignedTags[j]);this.populateTags(),this.availableTags.length>0?(this.listTagsDiv.showfn(),this.addTagsDiv.addClass("addTagsDivRadius"),this.listTagsDiv.mCustomScrollbar("destroy"),this.renderCustomScrollBar(this.listTagsDiv)):(this.listTagsDiv.hide(),this.addTagsDiv.removeClass("addTagsDivRadius"))},onSearchTextClick:function(){this.searchTextInput.val()==this.DefaultSearchText&&(this.searchTextInput.val(""),this.searchTextInput.removeClass("defaultSearchText")),this.onFilterChange()},onSearchTextBlur:function(){""==this.searchTextInput.val()&&(this.searchTextInput.val(this.DefaultSearchText),this.searchTextInput.addClass("defaultSearchText"))},ontagsSelected:function(tag){for(var len=this.availableTags.length,i=0;i<len;i++)if(this.availableTags[i].tagId==tag.tagId){this.selectedTags.push(tag),this.availableTags.splice(i,1);break}this.listTagsDiv.hide(),this.populateTags(),this.populateSelectedTags(),this.addTagsDiv.removeClass("addTagsDivRadius"),this.updateTags(),!this.options.isPopout&&this.options.container.scrollToBottom&&this.options.container.scrollToBottom()},populateSelectedTags:function(){this.tagsSelectedCont.empty();var cssClass=this.searchTextInput.attr("disabled")?"disable":"enable";if(IC_Validation.isNotNullOrEmptyArray(this.selectedTags)){var i=0,len=this.selectedTags.length;for(i=0;i<len;i++){var tag=this.selectedTags[i];""!==tag.tagName&&(tagIndicator=$('<div class="tagIndicator"/>').appendTo(this.tagsSelectedCont),tagHanger=$('<div class="tagHanger '+cssClass+'"/>').appendTo(tagIndicator),tagBody=$('<div class="tagBody '+cssClass+'"></div>').appendTo(tagIndicator),tagBodyTxt=$('<div class="tagBodyText textEllipsis">'+tag.tagName+"</div>").appendTo(tagBody),tagClose=$('<div class="tagCloseDiv '+cssClass+'"><div class="tagCloseTxt"> x </div></div>').appendTo(tagIndicator),tagHanger.append($("<p>")),IC_Common.setTextWithEllipsis(tagBodyTxt,tag.tagName,45,!0),"enable"==cssClass&&tagClose.on("click",$.proxy(this.ontagsDeselected,this,tag.tagId)))}}this.updatePanelHeight()},onClose:function(){this.availableTags.length;this.options.container.hideTagsPanel(),IC_Common.removeFocusFromCloseIcon(this.closeBtnIcon,"closeBtnIconFocus")},onHideTagList:function(){this.listTagsDiv.hide(),this.addTagsDiv.removeClass("addTagsDivRadius")},ontagsDeselected:function(tagId){var tag,tagslen=this.skillTags.length,selectedTagsLen=this.selectedTags.length;if(IC_Validation.isNotNull(tagId)){for(var i=0;i<tagslen;i++)this.skillTags[i].tagId==tagId&&(tag=this.skillTags[i],this.availableTags.push(tag));for(var j=0;j<selectedTagsLen;j++)if(this.selectedTags[j].tagId==tagId){this.selectedTags.splice(j,1);break}}this.populateTags(),this.populateSelectedTags(),this.updateTags()},updateTags:function(){this.contact.tags=this.selectedTags,this.options.container.updateTagsforContact(this.contact)},populateTags:function(isReload){var that=this;if(this.listTagsDiv.empty(),IC_Validation.isNotNullOrEmptyArray(this.availableTags)&&IC_Validation.isNotNullOrEmptyArray(this.selectedTags))for(var i=0;i<this.selectedTags.length;i++)for(var j=0;j<this.availableTags.length;j++)if(this.selectedTags[i].tagId==this.availableTags[j].tagId){this.availableTags.splice(j,1);break}this.availableTags.sort(function(a,b){var x=a.tagName.toLowerCase(),y=b.tagName.toLowerCase();return 1*(x==y?0:x>y?1:-1)});for(i=0;i<this.availableTags.length;i++)$('<div class="tag-item textEllipsis" />').text(this.availableTags[i].tagName).attr("title",this.availableTags[i].tagName).appendTo(this.listTagsDiv).on("click",$.proxy(this.ontagsSelected,this,this.availableTags[i]));this.listTagsDiv.on("mouseleave",function(){that.listTagsDiv.hide(),that.addTagsDiv.removeClass("addTagsDivRadius")})},onResizeTagsPanel:function(){var _height;_height=this.options.container.notesPanel.height()-(60+this.options.container.getDispPanelHeight()+(this.options.isPopout?8:1)),this.tagsSelectedPanel.css({"min-height":_height+"px",height:"100%"})},updatePanelHeight:function(){var tagsPanel=this.options.container.tagsPanel,that=this;function setPanelHeight(element){if(element.hasClass("open")){var tagsSelectedCont=parseInt(that.tagsSelectedCont.height())+5;_height=(tagsSelectedCont>70?tagsSelectedCont:70)+26+34,element.css({height:"auto"}),parseInt(element.height())-60<tagsSelectedCont&&element.css({height:_height+"px"})}}this.options.isPopout?this.options.container.isChatPanel||this.options.container.isEmailPanel?(this.tagsSelectedPanel.mCustomScrollbar("destroy"),setPanelHeight(tagsPanel)):this.renderCustomScrollBar(this.tagsSelectedPanel):setPanelHeight(tagsPanel)},updateSelectedTagHeight:function(isChatOrEmail){isChatOrEmail||this.tagsSelectedPanel.css({height:"86px","margin-top":"0"})},renderCustomScrollBar:function(objName){objName.mCustomScrollbar("destroy"),objName.mCustomScrollbar({scrollButtons:{enable:!0},advanced:{updateOnContentResize:!0},scrollInertia:0})},parkedEmailTagHeight:function(){var tagsSelectedHeight=this.tagsSelectedCont.height(),tagsPanel=this.options.container.tagsPanel,tagControlPanel=this.options.container.tagControlPanel,tagsSelectedPanel=this.tagsSelectedPanel;tagsSelectedHeight>50?tagsPanel.css({height:tagsSelectedHeight+26+40+"px"}):tagsPanel.css({height:"125px"}),tagsSelectedPanel.css({height:parseInt(tagsSelectedHeight)-25+"px"}),tagControlPanel.css({height:parseInt(tagsPanel.css("height"))-25+"px"})},updateData:function(skillTags,contact){this.skillTags=skillTags,this.availableTags=Object.clone(skillTags),this.selectedTags=contact.tags?contact.tags:[],this.contact=contact,this.fillAllAttributesofSelectedTags(),this.populateTags(),this.populateSelectedTags()},fillAllAttributesofSelectedTags:function(){var unFilledTag=null,matchedTag=null;"Parked"==this.contact.status?this.searchTextInput.attr("disabled","disabled"):this.searchTextInput.removeAttr("disabled");for(var i=0,outerLength=this.selectedTags.length;i<outerLength;i++)if((unFilledTag=this.selectedTags[i]).isLoaded+""=="false")for(var j=0,length=this.availableTags.length;j<length;j++)unFilledTag.tagId==this.availableTags[j].tagId&&(matchedTag=this.availableTags[j],unFilledTag.isActive=matchedTag.isActive,unFilledTag.notes=matchedTag.notes,unFilledTag.tagName=matchedTag.tagName,unFilledTag.isLoaded="true")},destroy:function(){this.listTagsDiv.empty(),this.tagsSelectedCont.empty(),this.availableTags=[],this.selectedTags=[]},setFocusToTagsHeader:function(){this.headerPanel.trigger("focus")},resetSearchText:function(){this.searchTextInput.val(this.DefaultSearchText),this.searchTextInput.addClass("defaultSearchText")}})}(jQuery);