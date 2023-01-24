/**
 *  02/23/2018  BE  Created (00150552)
 *  
 *  Icon Util is used for dynamically creating the path for an svg. The ICON_PATH_MAP contains the paths for each icon. When calling
 *  create path, use the corresponding name for the iconName parameter. If you want the lightbulb for example, use 'lightbulb'.
**/
var ICON_UTIL = {
    NS : "http://www.w3.org/2000/svg",

    ICON_PATH_MAP :  {
        add: 'M13.8 13.4h7.7c.3 0 .7-.3.7-.7v-1.4c0-.4-.4-.7-.7-.7h-7.7c-.2 0-.4-.2-.4-.4V2.5c0-.3-.3-.7-.7-.7h-1.4c-.4 0-.7.4-.7.7v7.7c0 .2-.2.4-.4.4H2.5c-.3 0-.7.3-.7.7v1.4c0 .4.4.7.7.7h7.7c.2 0 .4.2.4.4v7.7c0 .3.3.7.7.7h1.4c.4 0 .7-.4.7-.7v-7.7c0-.2.2-.4.4-.4z',
        back : 'M22.4 10.6H7.1c-.4 0-.6-.5-.3-.8l4.4-4.4c.3-.3.3-.7 0-1l-1-1c-.3-.3-.7-.3-1 0l-8 8.1c-.3.3-.3.7 0 1l8 8.1c.3.3.7.3 1 0l1-1c.2-.3.2-.7 0-1l-4.5-4.4c-.2-.3-.1-.8.4-.8h15.3c.4 0 .7-.3.7-.7v-1.3c0-.4-.3-.8-.7-.8z',
        ban: 'M12 .9C5.9.9.9 5.9.9 12s5 11.1 11.1 11.1 11.1-5 11.1-11.1S18.1.9 12 .9zM3.7 12c0-4.6 3.7-8.3 8.3-8.3 1.8 0 3.5.5 4.8 1.5L5.2 16.8c-1-1.3-1.5-3-1.5-4.8zm8.3 8.3c-1.8 0-3.5-.5-4.8-1.5L18.8 7.2c1 1.3 1.5 3 1.5 4.8 0 4.6-3.7 8.3-8.3 8.3z',
        check : 'M8.8 19.6L1.2 12c-.3-.3-.3-.8 0-1.1l1-1c.3-.3.8-.3 1 0L9 15.7c.1.2.5.2.6 0L20.9 4.4c.2-.3.7-.3 1 0l1 1c.3.3.3.7 0 1L9.8 19.6c-.2.3-.7.3-1 0z',
        close : 'M14.3 11.7l6-6c.3-.3.3-.7 0-1l-.9-1c-.3-.2-.7-.2-1 0l-6 6.1c-.2.2-.5.2-.7 0l-6-6.1c-.3-.3-.7-.3-1 0l-1 1c-.2.2-.2.7 0 .9l6.1 6.1c.2.2.2.4 0 .6l-6.1 6.1c-.3.3-.3.7 0 1l1 1c.2.2.7.2.9 0l6.1-6.1c.2-.2.4-.2.6 0l6.1 6.1c.2.2.7.2.9 0l1-1c.3-.3.3-.7 0-1l-6-6c-.2-.2-.2-.5 0-.7z',
        foward : 'M1.6 13.4h15.3c.4 0 .6.5.3.8l-4.4 4.4c-.3.3-.3.7 0 1l1 1c.3.3.7.3 1 0l8-8.1c.3-.3.3-.7 0-1l-8-8.1c-.3-.3-.7-.3-1 0l-1 1c-.2.3-.2.7 0 1l4.5 4.4c.2.3.1.8-.4.8H1.6c-.4 0-.7.3-.7.7v1.3c0 .4.3.8.7.8z',
        lightbulb : 'M11.1 1.2a7.4 7.4 0 0 0-6.6 6.6 7.3 7.3 0 0 0 2.7 6.3 2.3 2.3 0 0 1 .8 1.8 1.8 1.8 0 0 0 1.9 1.9h4.2a1.8 1.8 0 0 0 1.8-1.9 2.3 2.3 0 0 1 .9-1.8 7.3 7.3 0 0 0 2.7-5.6c.1-4.3-3.8-7.7-8.4-7.3zm4.1 18.7H8.8a.7.7 0 0 0-.8.7 2.2 2.2 0 0 0 2.2 2.2h3.6a2.2 2.2 0 0 0 2.2-2.2.7.7 0 0 0-.8-.7z',      
        info : 'M12 .9C5.9.9.9 5.9.9 12s5 11.1 11.1 11.1 11.1-5 11.1-11.1S18.1.9 12 .9zm0 5.6c.8 0 1.4.6 1.4 1.4s-.6 1.4-1.4 1.4-1.4-.6-1.4-1.4.6-1.4 1.4-1.4zm2.3 9.7c0 .2-.2.4-.5.4h-3.6c-.3 0-.5-.1-.5-.4v-.9c0-.3.2-.5.5-.5.2 0 .4-.2.4-.4v-1.9c0-.2-.2-.5-.4-.5-.3 0-.5-.1-.5-.4v-.9c0-.3.2-.5.5-.5h2.7c.3 0 .5.2.5.5v3.7c0 .2.2.4.4.4.3 0 .5.2.5.5v.9z',
        infoAlt : 'M12 .9C5.9.9.9 5.9.9 12s5 11.1 11.1 11.1 11.1-5 11.1-11.1S18.1.9 12 .9zm0 19.4c-4.6 0-8.3-3.7-8.3-8.3S7.4 3.7 12 3.7s8.3 3.7 8.3 8.3-3.7 8.3-8.3 8.3zm0-13.8c.8 0 1.4.6 1.4 1.4s-.6 1.4-1.4 1.4-1.4-.6-1.4-1.4.6-1.4 1.4-1.4zm2.3 9.7c0 .2-.2.4-.5.4h-3.6c-.3 0-.5-.1-.5-.4v-.9c0-.3.2-.5.5-.5.2 0 .4-.2.4-.4v-1.9c0-.2-.2-.5-.4-.5-.3 0-.5-.1-.5-.4v-.9c0-.3.2-.5.5-.5h2.7c.3 0 .5.2.5.5v3.7c0 .2.2.4.4.4.3 0 .5.2.5.5v.9z',
        offline: 'M16 16.7c.2-.3.2-.6 0-.9l-.8-.8c-.2-.2-.6-.2-.8 0l-2.1 2c-.1.2-.4.2-.5 0l-2.1-2c-.2-.2-.6-.2-.8 0l-.8.8c-.3.3-.3.6 0 .9l2 2c.1.1.1.4 0 .5l-2 2.1c-.3.2-.3.6 0 .8l.8.8c.2.3.6.3.8 0l2.1-2c.1-.1.4-.1.5 0l2.1 2c.2.3.6.3.8 0l.8-.8c.2-.2.2-.6 0-.8l-2-2.1c-.2-.1-.2-.4 0-.5l2-2zm6-11.3C19.5 2.5 15.9 1 12 1S4.6 2.5 2.1 5.4c-.2.1-.2.5 0 .6l1.4 1.2c.2.2.5.1.7 0C6.2 5 9 3.7 12 3.7s5.9 1.3 7.9 3.5c.2.1.5.1.7 0L22 6c.2-.2.2-.5 0-.6zm-10 2c-1.9 0-3.7.9-5 2.3-.2.2-.2.5 0 .7l1.5 1.1c.2.2.5.2.6 0 .8-.8 1.8-1.3 2.9-1.3s2.2.5 3 1.2c.1.2.4.2.6.1l1.4-1.1c.3-.2.3-.5.1-.7C15.8 8.3 14 7.4 12 7.4z',
        switch : 'M22 8.2l-9.5 9.6c-.3.2-.7.2-1 0L2 8.2c-.2-.3-.2-.7 0-1l1-1c.3-.3.8-.3 1.1 0l7.4 7.5c.3.3.7.3 1 0l7.4-7.5c.3-.3.8-.3 1.1 0l1 1c.2.3.2.7 0 1z',
        warning : 'M23.7 19.6L13.2 2.5c-.6-.9-1.8-.9-2.4 0L.3 19.6c-.7 1.1 0 2.6 1.1 2.6h21.2c1.1 0 1.8-1.5 1.1-2.6zM12 18.5c-.8 0-1.4-.6-1.4-1.4s.6-1.4 1.4-1.4 1.4.6 1.4 1.4-.6 1.4-1.4 1.4zm1.4-4.2c0 .3-.2.5-.5.5h-1.8c-.3 0-.5-.2-.5-.5v-6c0-.3.2-.5.5-.5h1.8c.3 0 .5.2.5.5v6z',
        gears: 'M13 12.7l-.3-.5c-.1-.2-.3-.3-.6-.3 0 0-.1.1-.2.1l-.8.3c-.3-.3-.7-.5-1.1-.6l-.2-.9c0-.3-.3-.5-.6-.5h-.6c-.2 0-.5.2-.6.5l-.1.9c-.4.1-.8.3-1.1.6L6 12h-.3c-.2 0-.4.1-.5.3l-.3.5c-.1.2-.1.5.2.7l.7.6c-.1.2-.1.4-.1.6s0 .5.1.7l-.7.6c-.3.2-.3.5-.2.7l.3.5c.1.2.3.3.5.3H6l.8-.3c.3.3.7.5 1.1.6l.1.9c.1.3.4.5.6.5h.6c.3 0 .6-.2.6-.5l.2-.9c.4-.1.8-.4 1.1-.7l.8.3c.1.1.2.1.2.1.3 0 .5-.1.6-.3l.3-.5c.1-.2.1-.6-.2-.8l-.7-.5c.1-.3.1-.5.1-.7 0-.2 0-.4-.1-.6l.7-.6c.2-.2.3-.5.2-.8zm-4.1 3.7c-.9 0-1.6-.7-1.6-1.6s.7-1.7 1.6-1.7c.9 0 1.7.7 1.7 1.7s-.8 1.6-1.7 1.6zm10.1-7l-.5-.5v-.5-.5l.5-.5c.2-.1.2-.4.1-.6l-.2-.4c-.1-.1-.3-.2-.4-.2h-.2l-.7.3c-.3-.3-.6-.5-.9-.5l-.1-.8c-.1-.2-.3-.4-.5-.4h-.5c-.2 0-.4.2-.5.4l-.1.7c-.3.1-.6.3-.9.6l-.7-.4h-.1c-.2 0-.4.1-.5.3l-.2.4c-.1.2-.1.4.1.6l.6.4c-.1.2-.1.4-.1.6 0 .1 0 .3.1.5l-.6.4c-.2.2-.2.4-.1.6l.2.4c.1.2.3.3.5.3h.1l.7-.3c.3.2.6.4.9.5l.1.7c.1.2.3.4.5.4h.5c.2 0 .5-.2.5-.4l.1-.7c.3-.1.7-.3.9-.6l.7.3h.2c.1 0 .3-.1.4-.2l.2-.4c.1-.1.1-.4-.1-.5zm-3.1.3c-.8 0-1.4-.6-1.4-1.3s.6-1.3 1.4-1.3 1.3.6 1.3 1.3-.6 1.3-1.3 1.3z'
    },

    isUndefined : function(v) {
        return typeof(v) === 'undefined';
    },
    
    createPath : function(iconName) {
        if(!this.isUndefined(this.ICON_PATH_MAP[iconName])) {
            var path = document.createElementNS(this.NS,'path');
            path.setAttributeNS(null,'d', this.ICON_PATH_MAP[iconName]);
            return path;
        }
        return false;
    }
}