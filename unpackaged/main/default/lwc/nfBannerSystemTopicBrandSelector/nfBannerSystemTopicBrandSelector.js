import { LightningElement, wire, api } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBrandsAndTopics from "@salesforce/apex/NF_BannerSystemController.getBrandsAndTopics";
import {refreshApex} from '@salesforce/apex';
import {consolePrintList} from 'c/nfConsoleUtil';


export default class NfBannerSystemTopicBrandSelector extends LightningElement {
    @api recordId;
    brandMap = new Map();
    topicMap = new Map();
    brands = [];
    topics = [];
    currentBrandId;
    currentTopicId;
    preview;
    ImageFile;
    MessageContent;

    get ImageFile() {
        return this.ImageFile;
    }

    get MessageContent() {
        return this.MessageContent;
    }

    get brandOptions() {
        console.log("Brand Options");
        return this.brands;
    }
    get topicsOptions() {
        console.log("Topics Options");
        let filteredTopics = [];
        for (let i = 0; i < this.topics.length; i++) {
            if(this.topics[i].NetworkId == this.currentBrandId ){
                filteredTopics.push(this.topics[i]);
            }
        }        
        return filteredTopics;
    }
    get displayTopicSelector() {
        console.log("This is a dropdown for home or topic: " + this.homeOrTopic);
        if (this.homeOrTopic == "Home") {
            return false;
        } else {
            return true;
        }
    }
    get currentBrandLabel() {
        console.log("currentBrand");
        if (this.currentBrandId == undefined || this.currentBrandId == null) {
            return "No brand selected yet";
        }
        let brandValue = this.currentBrandId;
        console.info("brandValue " + brandValue);
        let isBrandValueInMap = this.brandMap.has(brandValue);
        console.info("isBrandValueInMap " + isBrandValueInMap);

        if (isBrandValueInMap) {
            return this.brandMap.get(brandValue);
        } else {
            return "Please Verify the brandId is valid";
        }
    }
    get currentTopicLabel() {
        console.log("currentTopicLabel");
        if (this.currentTopicId == undefined || this.currentTopicId == null) {
            return "No Topic selected yet";
        }
        let topicValue = this.currentTopicId;
        console.info("currentTopicLabel topicValue " + topicValue);
        console.info("currentTopicLabel topicMap " + JSON.stringify(this.topicMap));
        let isTopicValueInMap = this.topicMap.has(topicValue);
        console.info("currentTopicLabel isTopicValueInMap " + isTopicValueInMap);

        if (isTopicValueInMap) {
            return this.topicMap.get(topicValue);
        } else {
            return "Please Verify the TopicId is valid";
        }
    }
    get currentTopicId() {
        console.log("currentTopicId");
        /*
        if(this.currentBrandId == undefined || this.currentBrandId== null){
            return 'No brand selected yet';
        }
        let brandValue = this.currentBrandId;
        console.info('brandValue ' + brandValue);
        let isBrandValueInMap = this.brandMap.has(brandValue);
        console.info('isBrandValueInMap ' + isBrandValueInMap);

        if(isBrandValueInMap){
            
            return  this.brandMap.get(brandValue);
        } else {
            return 'Please Verify the brandId is valid';
        }*/
    }

    /*
    get backgroundColor() {
        return this.backgroundColor;
    }
    */

    @wire(getBrandsAndTopics)
    wireBrandsAndTopics({ error, data }) {
        if (data) {
            console.group("getBrandsAndTopics");

            consolePrintList(data.brands, "Retreived brands");
            consolePrintList(data.topics, "Retreived topics");

            let brandDataCopy = data.brands;
            brandDataCopy.forEach((element) => console.log("brandDataCopy" + element));
            this.brands = brandDataCopy;
            brandDataCopy.forEach((element) => this.brandMap.set(element.Id, element.Name));

            let topicsDataCopy = data.topics;
            let topicsToBeFiltered = JSON.parse(JSON.stringify(topicsDataCopy));
            topicsDataCopy.forEach((element) => this.topicMap.set(element.Id, element.Name));

            console.log("this.currentBrandId " + this.currentBrandId);

            let networkId = this.currentBrandId;

            for (let i = 0; i < topicsToBeFiltered.length; i++) {
                console.log("element.NetworkId  " + topicsToBeFiltered[i].NetworkId);
                console.log("element.Name  " + topicsToBeFiltered[i].Name);
                if(networkId != null){
                    if (networkId == topicsToBeFiltered[i].NetworkId) {
                        this.topics.push(topicsToBeFiltered[i]);
                        console.log(
                            "\n networkId == topicsToBeFiltered[i].NetworkId  " + networkId ==
                                topicsToBeFiltered[i].NetworkId
                        );
                    }
                } else {
                    this.topics.push(topicsToBeFiltered[i]);
                }
            }
            console.groupEnd();
        } else if (error) {
            this.session = undefined;
            throw new Error("Failed to retrieve session");
        }
    }

    /*
    @wire(getBrandList)
    wiredBrands({ error, data }) {
        if (data) {
            let dataCopy = data;
            //let wiredBrands = [];
            console.log("Retrieved Data 1.2 : " + JSON.stringify(dataCopy));
            dataCopy.forEach((element) => console.log("DataCopy" + element));
            this.brands = dataCopy;
            dataCopy.forEach((element) => this.brandMap.set(element.Id, element.Name));
            this.brandMap.forEach(function (value, key) {
                console.log(key + " = " + value);
            });
            this.brands.forEach((element) => console.log("this.brands" + element));
        } else if (error) {
            this.session = undefined;
            throw new Error("Failed to retrieve session");
        }
    }
    @wire(getTopicList) getTopicsFunction(result) {
        if (result.data) {
            console.log("3 BRANDTEST    " + this.currentBrandId);
            let networkId = this.currentBrandId;
            let dataCopy = result.data;

            let topicsToBeFiltered = JSON.parse(JSON.stringify(dataCopy));

            dataCopy.forEach((element) => this.topicMap.set(element.Id, element.Name));
            this.topicMap.forEach(function (value, key) {
                console.log("topicMap " + key + " = " + value);
            });

            for (let i = 0; i < topicsToBeFiltered.length; i++) {
                console.log("this.currentBrandId " + networkId);
                console.log("element.NetworkId  " + topicsToBeFiltered[i].NetworkId);
                console.log("element.Name  " + topicsToBeFiltered[i].Name);
                if (networkId == topicsToBeFiltered[i].NetworkId) {
                    this.topics.push(topicsToBeFiltered[i]);
                    console.log(
                        "\n networkId == topicsToBeFiltered[i].NetworkId  " + networkId ==
                            topicsToBeFiltered[i].NetworkId
                    );
                }
            }
        } else if (result.error) {
            this.session = undefined;
            throw new Error("Failed to retrieve session");
        }
    }
    */
    selectionChangeHandler(event) {
        console.info(event.target.value);
        this.template.querySelector(".brandToBeSaved").value = event.target.value;
        this.currentBrandId = event.target.value;
    }
    selectionTopicChangeHandler(event) {
        console.info("selectionTopicChangeHandler " + event.target.value);
        this.template.querySelector(".topicsToBeSaved").value = event.target.value;
    }
    /*
    backgroundColorChangeHandler(event) {
        console.info("backgroundColorChangeHandler event.target.value");
        console.info(event.target.value);
        this.backgroundColor = this.template.querySelector(".backgroundToBeSaved").value;
        this.template.querySelector(".backgroundToBeSaved").value = event.target.value;
    }
    */
    handleOnLoad(event) {
        console.log("handleOnLoad | brandToBeSaved " + this.template.querySelector(".brandToBeSaved").value);
        console.log("handleOnLoad | topicsToBeSaved " + this.template.querySelector(".topicsToBeSaved").value);
        console.log("handleOnLoad | ImageFile " + this.template.querySelector(".ImageFile").value);
        console.log("handleOnLoad | MessageContent " + this.template.querySelector(".MessageContent").value);

        this.currentBrandId = this.template.querySelector(".brandToBeSaved").value;
        this.currentTopicId = this.template.querySelector(".topicsToBeSaved").value;
        this.ImageFile = this.template.querySelector(".ImageFile").value;
        this.MessageContent = this.template.querySelector(".MessageContent").value;

    }
    handleSuccess(){
        this.showNotification('Saved successful','This record has been saved','success');

        refreshApex(this.wiredBrands);
        refreshApex(this.getTopicsFunction);
    }
    showNotification(t,m,v) {
        // info succcess warning error
        const evt = new ShowToastEvent({
            title: t,
            message: m,
            variant: v,
        });
        this.dispatchEvent(evt);
    }
}