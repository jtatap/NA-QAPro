import { LightningElement, api, wire, track } from "lwc";
import retrieveTiles from "@salesforce/apex/NF_TilesController.getTiles";

export default class NfContactActions extends LightningElement {
    @api retrievedTileData;
    @api ComponentKey;
    @api maxwidth;
    @api columns;
    @api backgroundColor;
    @api tileStyle;
    @api innerPadding;

    @track loaded = false;
    @track maxWidthClass = "";
    @track columnClass = "slds-col slds-var-p-around_large slds-size_1-of-1 slds-medium-size_4-of-12";
    @track innerPaddingClass = "slds-var-p-around_large";

    connectedCallback() {
        this.loaded = true;
        this.maxWidthClass = "max-width: " + this.maxwidth + "px;margin-left: auto; margin-right: auto;";
    }

    @wire(retrieveTiles) getTilesFunction(result) {
        this.loaded = true;
        if (result.data) {
            this.error = undefined;
            this.retrievedTileData = this.filterAndSortTiles(result.data);
        } else if (result.error) {
            this.error = result.error;
            this.retrievedTileData = [];
        }

        switch (this.columns) {
            case 1:
                this.columnClass = "slds-col nfTileDynamicPadding slds-size_1-of-1 slds-medium-size_12-of-12";
                break;
            case 2:
                this.columnClass = "slds-col nfTileDynamicPadding slds-size_1-of-1 slds-medium-size_6-of-12";
                break;
            case 3:
                this.columnClass = "slds-col nfTileDynamicPadding slds-size_1-of-1 slds-medium-size_4-of-12";
                break;
            case 4:
                this.columnClass = "slds-col nfTileDynamicPadding slds-size_1-of-1 slds-medium-size_3-of-12";
                break;
            default:
                this.columnClass = "slds-col nfTileDynamicPadding slds-size_1-of-1 slds-medium-size_4-of-12";
        }
        switch (this.innerPadding) {
            case "small":
                this.innerPaddingClass = "slds-var-p-around_small";
                break;
            case "medium":
                this.innerPaddingClass = "slds-var-p-around_medium";
                break;
            case "large":
                this.innerPaddingClass = "slds-var-p-around_large";
                break;
            case "xlarge":
                this.innerPaddingClass = "slds-var-p-around_x-large";
                break;
            case "xxlarge":
                this.innerPaddingClass = "slds-var-p-around_xx-large";
                break;
            default:
                this.innerPaddingClass = "slds-var-p-around_medium";
        }
    }

    // hanlder function to open the chat or links
    openSalesforceChat(event) {
        debugger;
        let typeOfAction = event.currentTarget.dataset.arg1;
        let LinkToOpen = event.currentTarget.dataset.linktoopen;
        let buttonclass = event.currentTarget.dataset.buttonclass;
        if (typeOfAction == "ButtonToPress") {
            debugger;
            document.dispatchEvent(
                new CustomEvent("buttonPress", { detail: { buttonClassToPress: buttonclass, label: "Press Button" } })
            );
            if (document.getElementsByClassName(buttonclass).length > 0) {
                document.getElementsByClassName(buttonclass)[0].click();
            }
        }
        if (typeOfAction == "OpenLink" && LinkToOpen) {
            document.dispatchEvent(new CustomEvent("openLink", { detail: { link: LinkToOpen, label: "Open Link" } }));
            window.open(LinkToOpen,'_blank');
        }
    }

    //Filter out any tiles not to be displayed
    filterAndSortTiles(allTiles) {
        if (allTiles.length == 0) {
            return;
        }
        let tilesToBeSorted = JSON.parse(JSON.stringify(allTiles));
        let filteredTiles = [];
        for (let i = 0; i < tilesToBeSorted.length; i++) {
            if (tilesToBeSorted[i].ComponentKey__c == this.ComponentKey) {
                filteredTiles.push(tilesToBeSorted[i]);
            }
        }
        if (filteredTiles.length == 0) {
            return;
        }
        let sortedTiles = filteredTiles.sort(this.compareTileSort);
        return sortedTiles;
    }

    //Sorts the tiles based on the sort order
    compareTileSort(firstVal, secondVal) {
        if (firstVal.SortOrder__c > secondVal.SortOrder__c) return 1;
        if (secondVal.SortOrder__c > firstVal.SortOrder__c) return -1;
        return 0;
    }
}