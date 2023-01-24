import { LightningElement, api, wire, track } from "lwc";
import networkId from "@salesforce/community/Id";
import getMessages from "@salesforce/apex/NF_BannerSystemController.getMessages";
import {consolePrintList} from 'c/nfConsoleUtil';

export default class NfBannerSystemWrapper extends LightningElement {
    @api homeOrTopic;
    @api recordId = "";
    @api topicId;
    @api pageKey = "";
    @api messageStyle = "max-width:1200px;margin-left: auto;margin-right: auto;";

    filteredMessages = [];

    get filteredMessages() {
        return this.filteredMessages;
    }

    @wire(getMessages, { homeOrTopic: "$homeOrTopic", recordId: "$recordId", pageKey: "$pageKey" })
    retrieveMessages(result) {
        let filteredMessagesByBrand = [];
        if (result.data) {
            consolePrintList(result.data, "Result Data:");
            filteredMessagesByBrand = this.filterOutByBrand(result.data);
            let filteredMessagesByHomeTopicOrArticles = [];
            if (this.homeOrTopic == "home") {
                filteredMessagesByHomeTopicOrArticles = this.filterOutHomeMessages(filteredMessagesByBrand);
            }
            if (this.homeOrTopic == "topic") {
                filteredMessagesByHomeTopicOrArticles = this.filterOutTopicPage(filteredMessagesByBrand);
            }
            if (this.homeOrTopic == "article") {
                filteredMessagesByHomeTopicOrArticles = filteredMessagesByBrand;
            }
            if (this.homeOrTopic == "custompage") {
                filteredMessagesByHomeTopicOrArticles = filteredMessagesByBrand;
            }
            consolePrintList(filteredMessagesByHomeTopicOrArticles, "filteredMessagesByHomeTopicOrArticles");
            this.filteredMessages = filteredMessagesByHomeTopicOrArticles;
        } else if (result.error) {
            console.error("%c Error Data! " + JSON.stringify(result.error), "color: red");
        }
    }
    filterOutHomeMessages(allMessages) {
        console.groupCollapsed("filterOutHomeMessages");
        if (allMessages === undefined ) {
            return;
        }
        consolePrintList(allMessages, "filterOutHomeMessages(allMessages)");
        let messages = [];
        for (let i = 0; i < allMessages.length; i++) {
            if (allMessages[i].DisplayonHomepageorTopic__c == "Home") {
                messages.push(allMessages[i]);
            }
        }
        console.groupEnd();
        return messages;
    }
    filterOutTopicPage(allMessages) {
        console.groupCollapsed("filterOutTopicPage");
        if (allMessages === undefined) {
            return;
        }
        consolePrintList(allMessages, "filterOutTopicPage");
        let messages = [];
        for (let i = 0; i < allMessages.length; i++) {
            if (allMessages[i].DisplayonHomepageorTopic__c != "Home") {
                if (allMessages[i].TopicId__c == this.topicId) {
                    messages.push(allMessages[i]);
                }
            }
        }
        console.groupEnd();
        return messages;
    }
    filterOutByBrand(allMessages) {
        console.groupCollapsed("filterOutByBrand");
        consolePrintList(allMessages,"filterOutByBrand(allMessages)");
        if (allMessages === undefined) {
            return;
        }
        if (allMessages.length == 0) {
            return;
        }
        let messagesToBeSorted = JSON.parse(JSON.stringify(allMessages));
        let filteredMessages = [];
        for (let i = 0; i < messagesToBeSorted.length; i++) {
            if (messagesToBeSorted[i].Brand__c.includes(networkId)) {
                filteredMessages.push(messagesToBeSorted[i]);
            }
        }
        if (filteredMessages.length == 0) {
            return;
        }
        console.groupEnd();
        return filteredMessages;
    }
    renderedCallback() {
        consolePrintList(this.filteredMessages, "Rendered Callback ");
    }
    consolePrintList(listOfThings, title) {
        if (title == undefined) {
            title = "Group";
        }
        console.groupCollapsed(title);
        if (listOfThings != undefined) {
            for (let i = 0; i < listOfThings.length; i++) {
                console.log(listOfThings[i]);
            }
        }
        console.groupEnd();
    }
}