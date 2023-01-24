/* 
* To change this template, choose Tools | Templates
* and open the template in the editor.
*/
(function ($) {
    $.widget("AgentConsole.addressBook", {

        options: {
            container: null,
            resourceBase: ''
        },

        _create: function () {
            /// <summary>
            /// Creates the Root panel and necessary UI items to display Address Book
            /// </summary>

            var searchPanel,
                filterPanel,
                that = this;
            this.isOBSkillMenuOn = false;
            this._addressBookSearchTimerId = null;

            this.hideExpandMenuObj = {
                'slick-cell': 'slick-cell',
                'mCustomScrollBox': 'mCustomScrollBox',
                'mobileIcn': 'mobileIcn',
                'mobileVal': 'mobileVal',
                'menuItem': 'menuItem',
                'emailIcn': 'emailIcn',
                'emailVal': 'emailVal',
                'phoneIcn': 'phoneIcn',
                'phoneVal': 'phoneVal',
                'border1': 'border1',
                'ic_obSkillListMenu': 'ic_obSkillListMenu',
                'selectedRow': 'selectedRow',
                'textEllipsis': 'textEllipsis',
                'columnBorderDiv': 'columnBorderDiv',
                'slick-viewport': 'slick-viewport',
                'ui-widget-content': ' ui-widget-content'
            };

            this.curRowId = null;
            this.filterArgs = {
                context: this
            };

            this.isWorkItemTransferClicked = false;

            if (this.options.container.isPopout) {
                this.gridScrollHeight = 269;
                this.addressBookPanelWidth = 168;
            } else {
                this.gridScrollHeight = 250;
                this.addressBookPanelWidth = 168;
            }

            this.DefaultSearchText = IC_Localization.search + '...';

            this.lastselectedAddressBookItem = {};
            this.resourceBase = this.options.resourceBase;

            this.element.addClass('addressBook');
            $('<span class="dialogHidden">' + IC_Localization.begin + ' ' + IC_Localization.addressBook + '</span>').appendTo(this.element);     // ADA
            this.agentListPanel = $('<div/>').addClass('modalDialogBackground').appendTo(this.element);
            this.headerPanel = $('<div tabindex="-1" aria-labelledby="addressBookHeader" />').addClass('modalDialogHeader').appendTo(this.agentListPanel);
            $('<div id="addressBookHeader"/>').addClass('modalDialogHeaderText textEllipsis').text(IC_Localization.addressBook).appendTo(this.headerPanel);
            this.closeBtn = $('<div role="button" aria-label = "' + IC_Localization.close + '" tabindex = "0"/>').attr('title', IC_Localization.close).appendTo(this.headerPanel);
            this.closeBtnIcon = $('<img/>').addClass('closeBtnIcon').attr('src', this.resourceBase + '/css/images/section-close.png').appendTo(this.closeBtn);
            this.closeBtn.on("click", $.proxy(this.onClose, this));

            IC_Common.enterKeyPress(this.closeBtn, function () { that.onClose(); });
            IC_Common.setFocusToCloseIcon(this.closeBtn, this.closeBtnIcon, 'closeBtnFocus', 'closeBtnIconFocus');

            this.contentPanel = $('<div class="skillListContentPnl"/>').appendTo(this.agentListPanel);
            this.searchAndFilterPanel = $('<div id = "addrBookSearchAndFilterPanelId" />').addClass('searchAndFilterPanel').appendTo(this.contentPanel);
            searchPanel = $('<div id = "addrBookSearchPnlId" />').addClass('searchPanel').appendTo(this.searchAndFilterPanel);
            filterPanel = $('<div id = "addrBookFilterPnlId" />').addClass('filterPanel').appendTo(this.searchAndFilterPanel);

            this.searchBtn = $('<div/>').addClass('searchBtn').appendTo(searchPanel);
            $('<div id = "addrBookSearchBtnIconId" />').addClass('searchBtnIcon').appendTo(this.searchBtn).attr('title', IC_Localization.search);

            this.searchText = $('<div/>').addClass('searchText').appendTo(searchPanel);
            this.searchTextInput = $('<input type="text" id = "addrBookSearchTextInputId" title = "' + IC_Localization.search + ' ' + IC_Localization.addressBook + '">').addClass('searchTextInput defaultSearchText').appendTo(this.searchText);
            this.searchTextInput.val(this.DefaultSearchText);
            this.searchTextInput.trigger("focus");
            this.searchTextInput.on("input keyup", $.proxy(this.debounceOnFilterSearch, this));
            this.searchTextInput.on("focus", $.proxy(this.onSearchTextClick, this));
            this.searchTextInput.on("click", $.proxy(this.onSearchTextClick, this));
            this.searchTextInput.on("blur", $.proxy(this.onSearchTextBlur, this));

            this.teamFilterBtn = $('<div/>').addClass('filter').appendTo(filterPanel);
            $('<div id = "addrBookFilterIcnId" />').addClass('icn').appendTo(this.teamFilterBtn).attr('title', IC_Localization.addressBook);
            this.teamFilterBtn.on("click", $.proxy(this.showTeamFilter, this));

            this.filterCombo = $('<div/>').addClass('filterCombo').appendTo(filterPanel);
            this.filterCombo.comboBox({
                onDataChange: $.proxy(this.onFilterChange, this),
                resourceBase: this.resourceBase
            });

            if (this.options.container.isPopout) {
                this.firstNameColWidth = 185;
                this.lastNameColWidth = 185;
            } else {
                this.firstNameColWidth = 58;
                this.lastNameColWidth = 116;
            }
            this.statusColWidth = 60;


            this.loadingDiv = $('<div class="loadingDiv"/>').appendTo(this.contentPanel);
            this.loadingIcn = $('<div class="icn"><div class="loadingTxt textEllipsis">' + IC_Localization.loading + '</div></div>').appendTo(this.loadingDiv);

            this.gridId = IC_Common.generateUniqueId('addressBook');
            this.addressBookListGrid = $('<div id="' + this.gridId + '"></div>').addClass('addressBookGrid').appendTo(this.contentPanel);
            this.contentPanel.on("mousemove", $.proxy(this.hideExpandMenu, this));
            this.addressBookListGrid.on("mousemove", $.proxy(this.hideExpandMenu, this));
            this.setGridColumn();

            //$("body").mousemove($.proxy(this.hideExpandMenu, this));
            this.createaddressBookListGrid();
            $('<span class="dialogHidden">' + IC_Localization.end + ' ' + IC_Localization.addressBook + '</span>').appendTo(this.element);     // ADA
        },

        _init: function () {
            this.inboundSkillList = [];
            this.workItemSkillList = [];
            this.skillQueueList = {};
            this.filter = {};
            this.gridFocusOut = {};
            this.teamList = [];
            this.sortGrid = {};
        },

        setGridColumn: function () {
            /// <summary>
            /// 
            /// </summary>
            /// <param name="firstNameColWidth">Width of the First Name Column</param>
            /// <param name="lastNameColWidth">Width of the Last Name column</param>

            this.gridFocusOut = {};
            var that = this,
                firstNameColWidth = this.firstNameColWidth,
                lastNameColWidth = this.lastNameColWidth,
                firstNameTextWidth = firstNameColWidth - 16,
                lastNameTextWidth = lastNameColWidth - 21,
                that = this,
                totalGridWidth = this.addressBookListGrid.width();

            var getAccordianItems = function (row) {
                if (row.type === 'Mobile') {
                    return " <div id='" + row.id + "' ><div class='mobileIcn' ></div><div class='mobileVal textEllipsis' title='" + row.value + "' >" + row.value + "</div></div>";
                }
                if (row.type === 'Phone') {
                    return " <div id='" + row.id + "' ><div class='phoneIcn' ></div><div class='phoneVal textEllipsis' title='" + row.value + "' >" + row.value + "</div></div>";
                }
                if (row.type === 'Email') {
                    return " <div id='" + row.id + "' ><div class='emailIcn' ></div><div class='emailVal textEllipsis' title='" + row.value + "' >" + row.value + "</div></div>";
                }
            }

            var dynamicAddressBookStates = {
                1: { text: IC_Localization.available, color: '#29D28B' },
                2: { text: IC_Localization.away, color: '#F69D1F' },
                3: { text: IC_Localization.busy, color: '#E85D46' },
                4: { text: IC_Localization.doNotDisturb, color: '#E85D46' },
                5: { text: IC_Localization.offline, color: '#A6A8AB' },
            };

            var fullNameTemplate = function (record) {
                var template = $("<div>"),
                    nameRow = $("<div>").css("margin-left", "5px").appendTo(template),
                    agentFullName = record["FirstName"] + "  " + record["LastName"];

                IC_Common.setTextWithEllipsis(nameRow, agentFullName, totalGridWidth - 25);
                nameRow.attr('title', agentFullName);
                return "<div class='gridBorder'>" + template.html() + "</div>";
            };

            var getStatusTemplate = function (record) {
                var template = $("<div>");
                var statusRow = $("<div>").appendTo(template),
                    statusIconElement = $("<span class='stateIcon'>").appendTo(statusRow),
                    statusTextElement = $("<div>").css({ "margin-left": 5 }).appendTo(statusRow);

                var dynamicStateString = record.stateId || '',
                    dynamicExternalStateString = record.externalState || '',
                    statusText = "";

                if (dynamicAddressBookStates.hasOwnProperty(dynamicStateString)) {
                    var indicatorData = dynamicAddressBookStates[dynamicStateString];
                    statusText = indicatorData.text;
                    statusIconElement.css("background-color", indicatorData.color);
                }
                if (dynamicExternalStateString.length != 0) {
                    statusText = dynamicExternalStateString;
                }
                IC_Common.setTextWithEllipsis(statusTextElement, statusText, totalGridWidth - 35);
                return "<div>" + template.html() + "</div>";
            };

            var ExpandMenu = function (row, cell, value, columnDef, dataContext) {
                if (value !== undefined) {
                    value = value.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
                }

                var idx = that.dataView.getIdxById(dataContext.id),
                    record = that.tableRow[idx];

                if (IC_Validation.isNotNullOrEmpty(record) && record.parent !== null) {
                    // return the template only for standar address book.
                    // bcoz for dynamic address book in status colum we will return this template
                    if (!that._isDynamicAddressBook)
                        return getAccordianItems(record);

                } else {
                    return fullNameTemplate(record);
                }
            };

            this.colModel = [{
                id: 'FirstName',
                field: 'FirstName',
                name: IC_Common.textMask(IC_Localization.first, firstNameTextWidth),
                width: firstNameColWidth,
                sortable: true,
                resizable: false,
                height: 'auto',
                headerCssClass: 'decorationHeader',
                cssClass: 'alignLeft',
                toolTip: IC_Localization.first,
                formatter: ExpandMenu
            }, {
                id: 'LastName',
                field: 'LastName',
                name: IC_Common.textMask(IC_Localization.last, lastNameTextWidth),
                height: 'auto',
                width: lastNameColWidth,
                sortable: true,
                resizable: false,
                headerCssClass: 'decorationHeaderTopRight',
                cssClass: 'alignLeft',
                toolTip: IC_Localization.last,
                formatter: function (row, cell, value, columnDef, dataContext) {
                    return "";
                }
            }];

            // add stauts column for dynamic address book
            if (this._isDynamicAddressBook) {
                // remove firstName columns class
                this.colModel[0].headerCssClass = "";
                this.colModel[0].formatter = function (row, cell, value, columnDef, dataContext) {
                    return "";
                }

                var formatStatusColumn = function (row, cell, value, columnDef, dataContext) {
                    if (value !== undefined) {
                        value = value.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
                    }
                    var idx = that.dataView.getIdxById(dataContext.id),
                        record = that.tableRow[idx];
                    if (IC_Validation.isNotNullOrEmpty(record) && record.parent !== null) {
                        // return the accordian templates
                        return getAccordianItems(record);
                    }
                    else {
                        if (record.isPartialRecord == true) {
                            return fullNameTemplate(record)
                        }
                        else {
                            return getStatusTemplate(record)
                        }
                    }
                };
                var statusColWidth = this.statusColWidth,
                    statusColTextWidth = this.statusColWidth - 15;

                this.colModel.unshift({
                    id: 'Status',
                    field: 'stateId',
                    name: IC_Common.textMask("Status", statusColTextWidth),
                    width: statusColWidth,
                    sortable: true,
                    resizable: false,
                    height: 'auto',
                    headerCssClass: 'decorationHeader',
                    cssClass: 'alignLeft',
                    toolTip: "Status",
                    formatter: formatStatusColumn
                });
            } else {
                if (IC_Validation.isNotNullOrUndefinedString(this.sortGrid) && IC_Validation.isNotNullOrUndefinedString(this.grid) && this.sortGrid.sortCol === 'stateId') {
                    this.setSortColumn();
                }
            }
        },

        gridSorter: function (a, b) {
            var sortDir = 1,
                x, y;

            x = a[this.sortGrid.sortCol].toLowerCase();
            y = b[this.sortGrid.sortCol].toLowerCase();

            if (this.sortGrid.sortDir !== undefined && this.sortGrid.sortDir !== null) {
                sortDir = this.sortGrid.sortDir;
            }

            return sortDir * (x == y ? 0 : (x > y ? 1 : -1));
        },

        setGridCss: function () {
            //$(".addressBookGrid .grid-canvas").css({ 'height': this.gridScrollHeight + 'px' });
            if (this.tableRow.length > 0) {
                $(".addressBookGrid .slick-viewport").css('height', this.gridScrollHeight + 'px');
            }
        },

        createaddressBookListGrid: function () {
            /// <summary>
            /// Creates Skill List Grid and attaches event handlers
            /// </summary>

            var that = this,
                columnBorderDiv = null,
                gridOptions = {
                    rowHeight: 22,
                    enableColumnReorder: false
                };

            this.tableRow = [];

            this.dataView = new Slick.Data.DataView({
                inlineFilters: true
            });

            this.dataView.getItemMetadata = function (row) {
                var style = {
                    "columns": {
                        0: {
                            "colspan": "*"
                        }
                    },
                    "cssClasses": ""
                },
                    rowData = that.dataView.getItem(row);

                if (rowData.parent !== null) {
                    style.cssClasses = "expandMenu ";
                } else {
                    if (IC_Validation.isValidObject(that.filterArgs) && that.filterArgs.showAddressBookId === rowData.customId) {
                        style.cssClasses = "selectedRow";
                    }
                }
                return style;
            };

            this.grid = new Slick.Grid("#" + this.gridId, this.dataView, this.colModel, gridOptions);

            // wire up model events to drive the grid
            this.dataView.onRowCountChanged.subscribe(function (e, args) {
                that.grid.updateRowCount();
                that.grid.render();
            });

            this.dataView.onRowsChanged.subscribe(function (e, args) {
                that.grid.invalidateRows(args.rows);
                that.grid.render();
            });

            this.grid.onCellChange.subscribe(function (e, args) {
                that.dataView.updateItem(args.item.id, args.item);
            });

            this.grid.onMouseLeave.subscribe(function (e, args) {
                var cell = args.grid.getCellFromEvent(e),
                    item = that.dataView.getItem(cell.row);
                that.setGridCss();

                //Handling the mouse move event when OB skill menu opens                            
                if (IC_Validation.isNotNullOrEmpty(that.isOBSkillMenuOn) && that.isOBSkillMenuOn === true) {
                    that.isOBSkillMenuOn = false;
                    if (that.curRowId !== cell.row) {
                        that.options.container.closeOBSkillsMenu();
                    }
                }
                that.gridFocusOut.flag = false;
            });

            this.grid.onMouseEnter.subscribe(function (e, args) {
                var cell = args.grid.getCellFromEvent(e),
                    item = that.dataView.getItem(cell.row),
                    rowCount = parseInt(cell.row) + 3;

                if (item.parent) { return; }

                // to update the related records
                if (that._isDynamicAddressBook) {
                    if (item.isPartialRecord) {
                        that.dataView.updateItem(item.id, item);
                        item = item.partialRecord;
                    } else {
                        that.dataView.updateItem(item.partialRecord.id, item.partialRecord);
                    }
                }

                if (that.filterArgs.showAddressBookId !== item.customId) {
                    if (item.parent === null) {
                        that.gridFocusOut.flag = true;
                        $('.selectedRow').removeClass('selectedRow');
                        that.filterArgs.showAddressBookId = item.customId;
                        that.gridFocusOut.item = item;
                        that.dataView.updateItem(item.id, item);
                    }

                    that.setGridCss();

                    setTimeout(function () {
                        that.grid.scrollRowIntoView(rowCount, false);
                    }, 500);

                }
            });

            this.grid.onClick.subscribe($.proxy(this.onGridRowClick, this));

            this.grid.onSort.subscribe(function (e, args) {
                that.sortGrid.sortDir = args.sortAsc ? 1 : -1;
                that.sortGrid.sortCol = args.sortCol.field;
                that.sortField = args.sortCol.field + " " + (args.sortAsc ? "asc" : "desc");
                if (that._isDynamicAddressBook === true) {
                    that.sortTableRow();
                } else {
                    that.getAddressBookEntries(that.filter.filterValue);
                }
            });

            this.columnBorderDiv = $('<div style="height: ' + this.gridScrollHeight + 'px' + '"></div>').addClass('columnBorderDiv');
            $('.addressBook .slick-viewport').append(this.columnBorderDiv);

        },

        onSearchTextClick: function () {
            if (this.searchTextInput.val() === this.DefaultSearchText) {
                // Set it to an empty string
                this.searchTextInput.val("");
                this.searchTextInput.removeClass('defaultSearchText')
            }
        },

        onSearchTextBlur: function () {
            if (this.searchTextInput.val() === "") {
                // Set it to an empty string
                this.searchTextInput.val(this.DefaultSearchText);
                this.searchTextInput.addClass('defaultSearchText')
            }
        },

        debounceOnFilterSearch: function(event) {
            var that = this;

            if (event.type === "keyup" && event.keyCode !== 13) {
                return;
            }

            this.searchVal = this.searchTextInput.val();
            this.filterArgs.showAddressBookId = null;

            // clear the previous setTimeout to stop calling API
            this.clearAddressBookSearchTimerId();
            if (event.keyCode === 13) {
                this.onFilterSearch();
            } else {
                this._addressBookSearchTimerId = setTimeout(function () {
                    that.onFilterSearch();
                }, 1000);
            }
        },

        onFilterSearch: function () {
            if (this._isDynamicAddressBook === true) {
                this.updateGrid();
            } else {
                this.getAddressBookEntries(this.filter.filterValue);
            }
        },

        rebindStdAddressBookEntries: function (addressBookEntries, searchVal, filterValue) {
            // call rebindGrid function only if current search text value and the search text value of
            // response are equal and current addressbook id and addressbook id of response are equal
            if (searchVal === this.searchVal && filterValue === this.filter.filterValue) {
                this.rebindGrid(addressBookEntries);
            }
        },

        rebindGrid: function (addressBookEntries) {
            this.addressBookEntries = addressBookEntries;
            this.updateGrid();
        },

        getAddressBookEntries: function (filterValue) {
            if ((IC_Validation.isNotNullOrUndefinedString(this.sortGrid) && IC_Validation.isNotNullOrUndefinedString(this.grid) && this.sortGrid.sortCol === 'stateId') ||
                IC_Validation.isNullOrEmpty(this.sortField)) {
                this.sortField = "FirstName asc";
                this.sortGrid.sortDir = 1;
                this.setSortColumn();
            }
            this.loadingDiv.fadeIn(500);
            this.options.container.getAddressBookEntries(filterValue, $.proxy(this.rebindStdAddressBookEntries, this), this.searchVal, this.sortField);
        },

        setSortColumn: function() {
            this.sortGrid.sortCol = 'FirstName';
            this.grid.setSortColumn(this.sortGrid.sortCol, true);
        },

        onFilterChange: function () {
            var that = this,
                filterType,
                filterValue;
            this._updatedSince = IC_Common.toISODateString(new Date(0));
            filterValue = this.filter.filterValue = this.filterCombo.comboBox('getSelectedItem').id;
            filterType = this.filterCombo.comboBox('getSelectedItem').type;
            if (IC_Validation.isNotNullOrEmpty(this.filter.filterValue)) {
                this.loadingDiv.fadeIn(500);
                if (filterType == "Dynamic") {
                    this._isDynamicAddressBook = true;
                    this.clearAddressBookSearchTimerId();
                    this.options.container.getDynamicAddressBookEntries(filterValue, true, this._updatedSince, function (addressBookEntries, updatedSince, isFullLoad) {
                        if (updatedSince)
                            that._updatedSince = updatedSince;
                        that.rebindGrid(addressBookEntries);
                        that.startPollingDynamicAddressBook();
                    });
                }
                else {
                    this.stopPollingDynamicAddressBook();
                    this._isDynamicAddressBook = false;
                    this.getAddressBookEntries(filterValue);
                }
            };
        },

        updateAddressBookEntries: function (targetFunc) {
            var that = this;
            targetFunc(this.filter.filterValue, false, this._updatedSince, function (latestAddressBookEntries, updatedSince, isFullLoad) {
                if (updatedSince)
                    that._updatedSince = updatedSince;
                if (isFullLoad) 
                    // Bind only the entries that are not deleted. 
                    // API returns the deleted entries in the delta request made after the fullLoad request if the fullLoad request had no content. (The updatedSince time passed from the client is not updated if there is no content)
                    rebindGrid($.grep(latestAddressBookEntries, function (item) { return item.isDeleted == "False"; }));
                else
                    refreshDynamicbookEntries(that.addressBookEntries, latestAddressBookEntries);
                    that.updateGrid();
            });

            function rebindGrid(addressBookEntries) {
                that.addressBookEntries = addressBookEntries;
            }

            function refreshDynamicbookEntries(oldEntries, latestEntries) {
                var newEntry = null, elementIndex = -1;
                oldEntries = oldEntries || [];
                latestEntries = latestEntries || [];

                for (var idx = 0, length = latestEntries.length; idx < length; idx++) {
                    newEntry = latestEntries[idx];
                    elementIndex = getItemIndexById(oldEntries, newEntry);

                    // add the entry to the cache
                    if (elementIndex == -1) {
                        if (newEntry.isDeleted != "True") {
                            oldEntries.push(newEntry);
                        }
                    }
                    // remove the entry from cache
                    else if (newEntry.isDeleted == "True") {
                        oldEntries.splice(elementIndex, 1);
                        // update the existing entry
                    } else {
                        oldEntries[elementIndex] = newEntry;
                    }
                }

                that.addressBookEntries = oldEntries;
                that.updateGrid();
            }


            function getItemIndexById(entries, record) {
                var key = "externalId",
                    id = record[key];
                for (var i = 0, length = entries.length; i < length; i++) {
                    if (entries[i][key] == id) {
                        return i;
                    }
                }
                return -1;
            }
        },
        stopPollingDynamicAddressBook: function () {
            clearInterval(this._addressbookPollId);
        },

        clearAddressBookSearchTimerId: function() {
            clearTimeout(this._addressBookSearchTimerId);
        },

        startPollingDynamicAddressBook: function () {
            var that = this;
            this.stopPollingDynamicAddressBook();
            // polls dynamic address book for every 5 seconds
            this._addressbookPollId = setInterval(function () {
                that.updateAddressBookEntries(that.options.container.getDynamicAddressBookEntries);
            }, 5000);
        },
        onGridRowClick: function (e, args) {
            var cell = args.grid.getCellFromEvent(e),
                entry = this.dataView.getItem(cell.row);

            if (entry.parent !== null && IC_Validation.isNotNullOrEmpty(entry.value)) {
                if (entry.type === 'Mobile' || entry.type === 'Phone') {
                    var numberToDial = this.options.container.formatPhoneNumber(entry.value);
                    this.options.container.dialPhoneNumber(numberToDial, e.clientX, e.clientY);
                }
                else {
                    // Initiate outbound email action
                    this.options.container.createEmailOB(entry.value, e.clientX, e.clientY);
                }
                this.isOBSkillMenuOn = true;
                this.curRowId = cell.row;
            }
        },

        isMatchFound: function (addressBook) {
            /// <summary>
            /// 
            /// </summary>
            /// <param name="agent"></param>
            /// <returns type=""></returns>

            var matchFound = true;
            this.gridFocusOut.flag = true;
            if (IC_Validation.isNotNullOrEmpty(this.searchVal) && this.searchVal !== this.DefaultSearchText) {
                matchFound = matchFound && addressBook.firstName.toLowerCase().indexOf(this.searchVal.toLowerCase()) !== -1 || matchFound && addressBook.lastName.toLowerCase().indexOf(this.searchVal.toLowerCase()) !== -1;
            }

            return matchFound;
        },


        resizeWidget: function (width, height) {
            var header = 25,
                searchTxt = 50,
                border = 30,
                totGridWidth = 0,
                divWidth = 0;

            this.gridHeight = height - (header + searchTxt + border);
            this.gridScrollHeight = this.gridHeight - 25;
            this.addressBookListGrid.css('height', this.gridHeight + 'px');

            totGridWidth = this.addressBookListGrid.width();
            $('.agentConsolePopout .addressBook .columnBorderDiv').css({ 'width': totGridWidth + 'px' });

            // reserve some space for status column from totGridWidth
            if (this._isDynamicAddressBook) {
                totGridWidth = totGridWidth - 50;
            }

            divWidth = totGridWidth / 2;
            this.firstNameColWidth = divWidth;
            this.lastNameColWidth = divWidth;

            this.setGridColumn();
            this.updateGrid();
        },

        updateGrid: function () {
            if (!IC_Validation.isNotNullOrEmptyArray(this.addressBookList)) {
                this.gridFocusOut = {};
                this.addressBookEntries = [];
            }
            var addressBook = this.addressBookEntries,
                addrEntries,
                len = 0,
                i = 0,
                index = 0,
                cssState,
                parentId = '',
                isPopout = this.options.container.isPopout,
                record;

            this.tableRow = [];
            this.parentRows = [];
            this.childRows = {};

            if (IC_Validation.isNotNullOrUndefinedString(addressBook)) {
                len = addressBook.length;
            }

            for (i = 0; i < len; i++) {
                record = addressBook[i];
                if (this._isDynamicAddressBook === false || this.isMatchFound(record)) {
                    parentId = 'id_' + index;
                    addrEntries = {
                        'id': parentId,
                        'customId': parentId,
                        'parent': null,
                        'FirstName': record.firstName,
                        'LastName': record.lastName,
                        'ChildId': {},
                        'stateId': record.stateId,
                        'externalState': record.externalState
                    };
                    this.parentRows.push(addrEntries);

                    this.childRows[parentId] = [];
                    addrEntries = {
                        'id': 'addrMobileId_' + i,
                        'parent': parentId,
                        'type': 'Mobile',
                        'value': record.mobile
                    };
                    this.parentRows[index].ChildId.MobileId = 'addrMobileId_' + i;
                    this.childRows[parentId].push(addrEntries);

                    addrEntries = {
                        'id': 'addrEmailId_' + i,
                        'parent': parentId,
                        'type': 'Email',
                        'value': record.email
                    };
                    this.parentRows[index].ChildId.EmailId = 'addrEmailId_' + i;
                    this.childRows[parentId].push(addrEntries);

                    addrEntries = {
                        'id': 'addrPhoneId_' + i,
                        'parent': parentId,
                        'type': 'Phone',
                        'value': record.phone
                    };
                    this.parentRows[index].ChildId.PhoneId = 'addrPhoneId_' + i;
                    this.childRows[parentId].push(addrEntries);

                    index++;
                }
            }

            if ((this.tableRow.length / 4) > 13) {
                this.addressBookPanelWidth = 152;
                if (!isPopout) {
                    this.firstNameColWidth = 58;
                    this.lastNameColWidth = 100;
                }
            } else {
                this.addressBookPanelWidth = 168;
                if (!isPopout) {
                    this.firstNameColWidth = 58;
                    this.lastNameColWidth = 117;
                }
            }

            if (!isPopout && this._isDynamicAddressBook) {
                this.lastNameColWidth -= this.statusColWidth;
            }
            this.setGridColumn();

            this.loadingDiv.fadeOut(500);
            if (document.getElementById(this.gridId)) {
                if (!IC_Validation.isNotNullOrUndefinedString(this.sortGrid.sortDir)) {
                    this.setSortColumn();
                }

                this.sortTableRow();
                if (this.options.container.isPopout) {
                    this.gridHeight = this.gridHeight || 270;
                } else {
                    this.gridHeight = this.gridHeight || 275;
                }
                //this.grid.setColumns(this.colModel);
                this.dataView.beginUpdate();
                this.dataView.setItems(this.tableRow);
                this.dataView.setFilterArgs(this.filterArgs);
                this.dataView.setFilter(function (item, args) {
                    if (item != undefined) {
                        if (item.parent != null) {
                            var parent = args.context.tableRow[item.parent];
                            if (parent) {
                                if (parent.customId !== args.showAddressBookId) {
                                    return false;
                                }
                            }
                        }
                        return true;
                    }
                });
                //this.columnBorderDiv.css('height', this.gridScrollHeight + 'px');
                this.dataView.endUpdate();
                this.grid.setColumns(this.colModel);
                this.grid.invalidate();
                this.grid.render();
                this.setGridCss();
                this.columnBorderDiv.css('height', this.gridScrollHeight + 'px');
                //$(".addressBookGrid .slick-viewport").mCustomScrollbar("destroy");                                
                //$(".addressBookGrid .slick-viewport").mCustomScrollbar({
                //    scrollButtons: {
                //        enable: true
                //    },
                //    scrollInertia: 0,
                //    advanced: {
                //        autoScrollOnFocus: false,
                //        updateOnContentResize: true
                //    }
                //});
            }
        },

        sortTableRow: function () {

            if (!IC_Validation.isNotNullOrUndefinedString(this.parentRows)) {
                return;
            }

            var i = 0,
                len = this.parentRows.length,
                parentIndex = 0,
                childRecords = null,
                record,
                partialRecord,
                that = this;

            this.tableRow.length = 0;
            this.parentRows.sort($.proxy(this.gridSorter, this));


            var postProcess = this._isDynamicAddressBook ? function (record) {
                partialRecord = {
                    id: record.id + "_",
                    'customId': record.id,
                    'parent': null,
                    'FirstName': record.FirstName,
                    'LastName': record.LastName,
                    'stateId': record.stateId,
                    'externalState': record.externalState,
                    'isPartialRecord': true,
                    'partialRecord': record
                }
                record.partialRecord = partialRecord;
                that.tableRow.push(partialRecord);
            } : function () { };

            for (i = 0; i < len; i++) {
                this.tableRow.push(this.parentRows[i]);
                record = this.parentRows[i];
                postProcess(record);

                parentIndex = this.tableRow.length - 1;

                // Update parent index for all child rows
                childRecords = this.childRows[this.parentRows[i].id];
                if (childRecords) {
                    childRecords[0].parent = parentIndex;
                    childRecords[1].parent = parentIndex;
                    childRecords[2].parent = parentIndex;
                    this.tableRow = this.tableRow.concat(childRecords);
                }
            }

            this.dataView.beginUpdate();
            this.dataView.setItems(this.tableRow);
            this.dataView.endUpdate();
        },

        bindAddressBookComboBox: function () {
            /// <summary>
            /// Binds the Address Book ComboBox
            /// </summary>
            this.filterCombo.comboBox('setStore', this.addressBookList);
            this.onFilterChange();
        },

        updateData: function (addressBookEntries) {
            this.addressBookEntries = addressBookEntries;
            this.updateGrid();
        },

        _isDynamicAddressBook: false,
        _addressbookPollId: '',
        _updatedSince: IC_Common.toISODateString(new Date(0)),
        updateMetaData: function (addressBook) {
            /// <summary>
            /// Load the Contact from the selected Address Book
            /// </summary>

            this.addressBookList = [];
            this.filter.filterType = 'FirstName';
            this.filter.filterValue = '';

            for (var i = 0; i < addressBook.length; i++) {
                this.addressBookList.push({
                    'id': addressBook[i].id,
                    'value': addressBook[i].name,
                    'type': addressBook[i].type
                });
            }

            if (this.addressBookList.length > 0) {
                this.filter.filterValue = this.addressBookList[0].id;
            } else {
                this.loadingDiv.fadeOut(500);
                // If the agent logs out in addressbook view, when logging in back the addressbook entries are not cleared even if no addressbooks. 
                // Hence, update the grid to clear the entries.
                if (IC_Validation.isNotNullOrEmptyArray(this.addressBookEntries)) {
                    this.updateGrid();
                }
            }

            if (IC_Validation.isNotNullOrEmptyArray(this.addressBookList)) {
                this.filterCombo.comboBox('setSelectedItem', this.addressBookList[0]);
            }
            this.bindAddressBookComboBox();

        },

        hideExpandMenu: function (event) {
            var className = event.target.className.split(' ')[0];

            if (IC_Validation.isNotNullOrUndefinedString(this.hideExpandMenuObj[className]) === false) {
                if (IC_Validation.isNotNullOrEmpty(this.gridFocusOut) && IC_Validation.isNotNullOrEmpty(this.gridFocusOut.item) && this.gridFocusOut.flag === false) {
                    $('.selectedRow').removeClass('selectedRow');
                    this.filterArgs.showAddressBookId = null;
                    this.dataView.updateItem(this.gridFocusOut.item.id, this.gridFocusOut.item);
                }
                this.setGridCss();

            }
            //Handling the mouse move event when OB skill menu opens                                    
            if (this.isOBSkillMenuOn !== true) {
                this.isOBSkillMenuOn = false;
                this.curRowId = null;
                this.options.container.closeOBSkillsMenu();
            }
        },

        updatePanelHeight: function (height) {
            var gridPadding = 7,
                filterPnlHt = this.searchAndFilterPanel.outerHeight(true),
                gridHeaderHt = 25,
                addressBookListGridHeight,
                gridScrollHeight;

            addressBookListGridHeight = height - (gridPadding + filterPnlHt);
            gridScrollHeight = addressBookListGridHeight - gridHeaderHt;

            this.contentPanel.css({ 'height': height + 'px' });
            this.addressBookListGrid.css('height', addressBookListGridHeight + 'px');
            this.gridScrollHeight = gridScrollHeight;
        },

        setFocusToAddressBookHeader: function () {
            this.headerPanel.trigger("focus");       // ADA
        },

        onClose: function () {
            this.stopPollingDynamicAddressBook();
            this.clearAddressBookSearchTimerId();
            this.options.container.closeAddressBookAndShowHome();
            IC_Common.removeFocusFromCloseIcon(this.closeBtnIcon, 'closeBtnIconFocus');
        },

        destroy: function () {
            this.stopPollingDynamicAddressBook();
            this.clearAddressBookSearchTimerId();
        }

    });
}(jQuery));
