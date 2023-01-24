const consolePrintList = (listOfThings, title) => {
    if (title == undefined) {
        title = "Group";
    }
    console.group(title);
    if (listOfThings != undefined) {
        for (let i = 0; i < listOfThings.length; i++) {
            console.log(listOfThings[i]);
        }
    }
    console.groupEnd(title);
};

export { consolePrintList };