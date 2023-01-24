if (!window.isLoaded) {
    window.isLoaded = true;
    var lwcData;
    let div = document.createElement("div");

    const HTMLCLASS = {
        mainClass: 'ebcm_lightbox',
        closeClass: 'ebcm_close',
        prevClass: 'ebcm_prev',
        nextClass: 'ebcm_next',
        modalId: 'ebcm_myModal',
        imageClass: 'ebcm_enhance',
        captionClass: 'ebcm_caption',
        modalContentClass: 'ebcm_modal-content',
        summaryClass: 'ebcm_has-summary'
    }

    div.innerHTML = '<div id="ebcm_myModal" class="ebcm_modal"><span class="ebcm_close ebcm_cursor" onclick="closeModal()">&times;</span><div class="ebcm_modal-content"><div class="mySlides"><img src="" style="width:100%" class="ebcm_enhance" data-key=""></div><span class="ebcm_prev" onclick="prevSlide()">&#10094;</span><span class="ebcm_next" onclick="nextSlide()">&#10095;</span><div class="ebcm_caption-container"><p id="ebcm_caption"></p></div></div></div>';
    div.classList.add(HTMLCLASS.mainClass);

    try {
        document.body.appendChild(div);
        document.getElementsByClassName(HTMLCLASS.closeClass)[0].addEventListener('click', e => {
            closeModal();
        });
        document.getElementsByClassName(HTMLCLASS.prevClass)[0].addEventListener('click', e => {
            prevSlide();
        });
        document.getElementsByClassName(HTMLCLASS.nextClass)[0].addEventListener('click', e => {
            nextSlide();
        });
    }
    catch (e) {
        console.log(e);
    }

    function openModal() {
        document.getElementById(HTMLCLASS.modalId).style.display = "block";
    }

    function closeModal() {
        document.getElementById(HTMLCLASS.modalId).style.display = "none";
    }

    function imageIndex() {
        return parseInt(imageTag().dataset.key);
    }

    function imageTag() {
        return document.getElementsByClassName(HTMLCLASS.imageClass)[0];
    }

    function captionTag() {
        return document.getElementById(HTMLCLASS.captionClass);
    }

    function modalContent() {
        return document.getElementsByClassName(HTMLCLASS.modalContentClass)[0];
    }

    function nextSlide() {
        if (lwcData) {
            let currentKey = imageIndex();
            if (imageIndex() === lwcData.allUrl.length - 1) {
                currentKey = -1;
            }
            let requiredElement = lwcData.allUrl.find(element => element.key === parseInt(currentKey) + 1);
            setDivValues(requiredElement);
        }
    }

    function prevSlide() {
        if (lwcData) {
            let currentKey = imageIndex();
            if (imageIndex() === 0) {
                currentKey = lwcData.allUrl.length;
            }
            let requiredElement = lwcData.allUrl.find(element => element.key === parseInt(currentKey) - 1);
            setDivValues(requiredElement);
        }
    }

    function setDivValues(requiredElement) {
        imageTag().src = requiredElement.imgURL;
        imageTag().dataset.key = requiredElement.key;
        captionTag().innerHTML = requiredElement.summary ? requiredElement.summary : '';
        requiredElement.summary !== '' ? modalContent().classList.add(HTMLCLASS.summaryClass) : modalContent().classList.remove(HTMLCLASS.summaryClass);
    }

    window.addEventListener('ebcm__imageClicked', event => {
        lwcData = event.detail;
        let requiredElement = event.detail.allUrl.find(element => element.key === parseInt(event.detail.key));
        setDivValues(requiredElement);
        openModal();
    });
}


