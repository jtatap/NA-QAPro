/*
* @Author: Apoorv (NeuraFlash)
* @CreatedDate: May'17, 2020
*/

import { LightningElement, api } from 'lwc';
import { subscribe, unsubscribe, onError} from 'lightning/empApi';

export default class EmpApiLWC extends LightningElement {
    channelName = '/event/Log_Event__e';
    isSubscribed;
    @api totalRecords;
    subscription = {};

    renderedCallback(){
        if(!this.isSubscribed){
            this.template.querySelector("[data-id='toggleSubscription']").click();
        }
    }

    handleSubscribe(){
        const messageCallback = (response) => {
            const changeEvt = new CustomEvent('notification',{
                detail:{
                    value:response
                }
            });
            this.dispatchEvent(changeEvt); 
        };
    
        subscribe(this.channelName, -1, messageCallback).then(response => {
            console.log('Successfully subscribed to : ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }

    handleUnsubscribe(){
        unsubscribe(this.subscription, response => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
        });
    }

    handleToggle(){
        if(this.isSubscribed){
            this.isSubscribed = false
            this.handleUnsubscribe();
        } else {
            this.isSubscribed = true
            this.handleSubscribe();
        }
    }

    registerErrorListener() {
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
        });
    }
}