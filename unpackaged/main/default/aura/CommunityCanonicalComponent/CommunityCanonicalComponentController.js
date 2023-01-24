({
  init: function(component, event, helper) {
    var canonicalUrl = component.get("v.canonicalUrl");
     
    var linkTag = document.querySelector('head link[rel="canonical"]');
      
    if (linkTag) {
      linkTag.setAttribute("href", canonicalUrl);
    } else {
      var headTag = document.querySelector("head");
      var newLinkTag = document.createElement("link");
      newLinkTag.rel = "canonical";
      newLinkTag.href = canonicalUrl;
       
        
      headTag.appendChild(newLinkTag);
        
        
    }
  }
});