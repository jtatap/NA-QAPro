/*
* @Author: Apoorv (NeuraFlash)
* @CreatedDate: May'10, 2020
*/

import { LightningElement ,api,track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLogs from '@salesforce/apex/LogSelector.getLogs';
 
export default class DatatableComponent extends LightningElement {
    @track columns;
    @track error;
    @track data ;
    @track loadMoreStatus;
    @api totalNumberOfRows;
    @track sortBy;
    @track sortDirection;
    @track totalNumberOfRows;
    @track queryfilters;
    @track refreshView;
    @track lastLoadedRecord;
    @track alreadyLoadedData;
    @track totalAttempt;

    connectedCallback(){
        this.queryfilters = null;
        this.handleLoad();
    }

    @api
    handleLoad(queryFilter, showToast){
        this.queryfilters = queryFilter;
        getLogs({
            queryFilters : JSON.stringify(this.queryfilters),
            lastRecord : null
        })
        .then(result => {
            if(showToast && this.totalNumberOfRows != result.totalRecordCount){
                this.refreshView = true;
                this.refreshUI();
            }
            this.lastLoadedRecord = null;
            this.alreadyLoadedData = null;
            var dataTableColumns = (new Function("return " + result.dataTablePayload+ ";")());
            this.columns = dataTableColumns;
            this.totalNumberOfRows = result.totalRecordCount;
            var records = result.dataTableRecords;
            records.forEach(function(record){
                record.recordLink = '/'+record.Id;
            });
            this.data = records;
            if(records.length > 0){
                this.lastLoadedRecord = records[records.length -1].Name;
            }
        })
        .catch(error => {
            this.error = error;
            console.log('Error : ' + JSON.stringify(error));
        });
    }

    loadMoreData(event) {
        if (this.data.length >= this.totalNumberOfRows) {
            this.loadMoreStatus = 'No more data to load';
        } else {
            event.target.isLoading = true;
            this.loadMoreStatus = 'Loading';
            const currentData = this.data;
            if(this.lastLoadedRecord == null){
                this.lastLoadedRecord = currentData[currentData.length - 1].Name;
            }
            if(this.lastLoadedRecord != this.alreadyLoadedData){ 
                this.alreadyLoadedData = this.lastLoadedRecord;
                getLogs({
                    queryFilters : JSON.stringify(this.queryfilters),
                    lastRecord : this.lastLoadedRecord
                })
                .then((result) => {
                    const currentData = this.data;
                    var records = result.dataTableRecords;
                    records.forEach(function(record){
                        record.recordLink = '/'+record.Id;
                    });
                    const newData = currentData.concat(records);
                    this.data = newData;
                    this.lastLoadedRecord = newData[newData.length - 1].Name;
                    this.loadMoreStatus = '';
                })
                .catch(error => {
                    this.error = error;
                    console.log('Error : ' + JSON.stringify(error));
                });
            }
            event.target.isLoading = false;
        }
    }

    handleSortdata(event){
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction){
        let parseData = JSON.parse(JSON.stringify(this.data));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
    }

    handlenotification(event){
        this.totalAttempt = 0;
        var loglevel = 'FATAL';
        if(this.queryfilters){
            loglevel = this.queryfilters.loglevel;
        }
        if(event.detail.value && event.detail.value.data.payload.Level__c == loglevel){
            this.refreshUI();
        }
    }

    refreshUI(){
        this.totalAttempt += 1;
        if(this.totalAttempt <= 5){
            if(this.refreshView){
                this.refreshView = false;
                this.showToast();
            } else {
                this.handleLoad(this.queryfilters, true); 
            }
        }
    }

    showToast(){
        const event = new ShowToastEvent({
            title: 'Log View Updated.',
            message: 'New log entries created in the system that meet the criteria',
            variant: 'warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}