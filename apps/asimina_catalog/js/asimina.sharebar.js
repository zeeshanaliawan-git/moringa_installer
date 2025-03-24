JSShare = {
    /**
     * JS-Share - vanilla javascript social networks and messengers sharing
     * https://github.com/delfimov/JS-Share
     *
     * Copyright (c) 2017 by Dmitry Elfimov
     * Released under the MIT License.
     * http://www.opensource.org/licenses/mit-license.php
     *
     * Minimum setup example:
     *
    <div>Share:
        <button class="social_share" data-type="fb">Facebook</button>
        <button class="social_share" data-type="tw">Twitter</button>
        <button class="social_share" data-type="lj">LiveJournal</button>
        <button class="social_share" data-type="ok">ok.ru</button>
        <button class="social_share" data-type="mr">Mail.Ru</button>
        <button class="social_share" data-type="gg">Google+</button>
        <button class="social_share" data-type="telegram">Telegram</button>
        <button class="social_share" data-type="whatsapp">Whatsapp</button>
        <button class="social_share" data-type="viber">Viber</button>
        <button class="social_share" data-type="email">Email</button>
    </div>

    $(document).on('click', '.social_share', function(){
        return JSShare.go(this);
    });

     *
     * Inline example:
     *
    <a href="#" onclick="return JSShare.go(this)" data-type="fb" data-fb-api-id="123">I like it</a>

     *
     * @param element Object - DOM element
     * @param options Object - optional
     */
    go: function(element, options) {
        var self = JSShare,
            withoutPopup = [
                'unknown',
//              'whatsapp',
                'email'
            ],
            tryLocation = true, // should we try to redirect user to share link
            link,
            defaultOptions = {
                type:        'fb',           // share type
                url:         getMetaContent("property='og:url'"),             // url to share
                title:       getMetaContent("property='og:title'"), // title to share
                image:       getMetaContent("property='og:image'"),             // image to share
              site_name:   getMetaContent("property='og:site_name'"),
                text:        '',             // text to share
                utm_source:  '',
                utm_medium:  '',
                utm_campaign:'',
                popup_width: 626,
                popup_height:436,
                app_id: getMetaContent("property='fb:app_id'"),
                og_title: getMetaContent("property='og:title'"),
                og_description: getMetaContent("property='og:description'"),
                og_image: getMetaContent("property='og:image'"),
                og_locale: getMetaContent("property='og:locale'"),
              twitter_message: (getMetaContent("name='etn:pname'")==""?getMetaContent("property='og:title'"):getMetaContent("name='twitter:message'")),
                twitter_site: getMetaContent("name='twitter:site'"),
                email_subject: getMetaContent("name='email:subject'"),
              email_message: getMetaContent("property='og:description'")
            };

        options = self._extend(
            defaultOptions,                         // default options - low priority
            self._getData(element, defaultOptions), // options from data-* attributes
            options                                 // options from method call - highest proprity
        );

        if (typeof self[options.type] == 'undefined') {
            options.type = 'unknown'
        }

        link = self[options.type](options);

        if (withoutPopup.indexOf(options.type) == -1) {        // if we must try to open a popup window
            tryLocation = self._popup(link, options) === null; // we try, and if we succeed, we will not redirect user to share link location
        }

        if (tryLocation) {                                          // ...otherwise:
            if (element.tagName == 'A' && element.tagName == 'a') { // if element is <a> tag
                element.setAttribute('href', link);                 // set attribute href
                return true;                                        // and return true, so this tag will behave as a usual link
            } else {
                location.href = link;                               // if it's not <a> tag, change location to redirect
                return false;
            }
        } else {
            return false;
        }
    },

    unknown: function(options) {
        return encodeURIComponent(JSShare._getURL(options));
    },

    // Facebook
    fb: function(options) {
        var url = JSShare._getURL(options);
        return 'https://www.facebook.com/sharer/sharer.php?u='+ encodeURIComponent(url);
    },

    // LinkedIn
    in: function(options) {
        var url = JSShare._getURL(options);
      return 'https://www.linkedin.com/shareArticle?mini=true&url='+ encodeURIComponent(url)
          + '&title=' + encodeURIComponent(options.title)
          + '&summary=' + encodeURIComponent(options.twitter_message)
          + '&source=' + encodeURIComponent(options.site_name);
    },

    // Twitter
    tw: function(options) {
        var url = JSShare._getURL(options);
      var via = options.twitter_site/*.substring(1, options.twitter_site.length)*/;
      return 'http://twitter.com/intent/tweet?'
            + 'text=' + encodeURIComponent(options.twitter_message)
            + '&url=' + encodeURIComponent(url)
          + '&via=' + encodeURIComponent(via);
//          + '&lang=' + encodeURIComponent(options.og_locale.substring(0,2));
    },

    whatsapp: function (options) {
      var url = JSShare._getURL(options);
      return 'https://wa.me/?text=' + encodeURIComponent(options.twitter_message)+ " " + encodeURIComponent(url);
    },

    email: function(options) {
      var url = JSShare._getURL(options);
        return 'mailto:?'
          + 'subject=' + encodeURIComponent(options.og_title)
          + '&body='   + encodeURIComponent(options.email_message + "\n")
                       + encodeURIComponent(url);
    },

    _getURL: function(options) {
        if (options.url == '') {
            options.url = location.href;
        }
        var url = options.url,
            utm = '';
        if (options.utm_source != '') {
            utm += '&utm_source=' + options.utm_source;
        }
        if (options.utm_medium != '') {
            utm += '&utm_medium=' + options.utm_medium;
        }
        if (options.utm_campaign != '') {
            utm += '&utm_campaign=' + options.utm_campaign;
        }
        if (utm != '') {
            url = url + '?' + utm;
        }
        return url;
    },

    // Open popup window for sharing
    _popup: function(url, _options) {
        return window.open(url,'','toolbar=0,status=0,scrollbars=1,width=' + _options.popup_width + ',height=' + _options.popup_height);
    },

    /**
     * Object Extending Functionality
     */
    _extend: function(out) {
        out = out || {};
        for (var i = 1; i < arguments.length; i++) {
            if (!arguments[i])
                continue;

            for (var key in arguments[i]) {
                if (arguments[i].hasOwnProperty(key))
                    out[key] = arguments[i][key];
            }
        }
        return out;
    },

    /**
     * Get data-attributes
     */
    _getData: function(el, defaultOptions) {
        var data = {};
        for (var key in defaultOptions) {
            var value = el.getAttribute('data-' + key);
            if (value !== null && typeof value != 'undefined') {
                data[key] = value;
            }
        }
        return data;
    }
};

window.initSharebar=  function (selector = '.__sharebar', label = 'Partager sur'){
    var sharebarHtml = `<div class="DetailsNews-socialNetworks"><div class=\"SocialNetworks isLight\">
            <span class=\"SocialNetworks-title\">`+label+`</span>
            <a href=\"#\" class=\"social_share\" data-type=\"fb\">
                <span><svg xmlns=\"http://www.w3.org/2000/svg\" width=\"20\" height=\"20\" viewBox=\"0 0 20 20\">
                    <path fill=\"#000\" fill-rule=\"evenodd\" d=\"M13.37 4H15V1.13c-.79-.09-1.585-.133-2.38-.13-2.35 0-4 1.49-4 4.23v2.36H6v3.2h2.66V19h3.18v-8.21h2.66l.39-3.2h-3.05v-2c0-.97.25-1.59 1.53-1.59z\"></path>
                    </svg></span>
                <span class=\"SocialNetworks-background\" style=\"background-color:#1877f2;\"></span>
                <span class=\"SocialNetworks-colorfulCircle\" style=\"border-color:#1877f2;\"></span>
                <span class=\"SocialNetworks-backgroundCircle\"></span>
            </a>
            <a href=\"#\" class=\"social_share\" style="display:none">
                <span><svg xmlns=\"http://www.w3.org/2000/svg\" width=\"20\" height=\"20\" viewBox=\"0 0 20 20\">
                    <path fill=\"#000\" fill-rule=\"evenodd\" d=\"M17.301 13.579a3.723 3.723 0 0 1-3.723 3.723H6.42A3.723 3.723 0 0 1 2.7 13.58V6.422A3.723 3.723 0 0 1 6.42 2.7h7.157A3.723 3.723 0 0 1 17.3 6.423v7.156zM19 6.422A5.423 5.423 0 0 0 13.578 1H6.42A5.422 5.422 0 0 0 1 6.423v7.156A5.421 5.421 0 0 0 6.421 19h7.157A5.422 5.422 0 0 0 19 13.579V6.422zm-8.97 6.542a2.852 2.852 0 0 1-2.847-2.848A2.85 2.85 0 0 1 10.03 7.27a2.85 2.85 0 0 1 2.848 2.846 2.851 2.851 0 0 1-2.848 2.848zm0-7.293a4.45 4.45 0 0 0-4.444 4.445 4.45 4.45 0 0 0 4.444 4.446 4.45 4.45 0 0 0 4.445-4.446A4.45 4.45 0 0 0 10.03 5.67zm4.705-1.357a1.058 1.058 0 1 0 0 2.117 1.058 1.058 0 0 0 0-2.117z\"></path>
                    </svg></span>
                <span class=\"SocialNetworks-background\" style=\"background-color:#C13584\"></span>
                <span class=\"SocialNetworks-colorfulCircle\" style=\"border-color:#C13584;\"></span>
                <span class=\"SocialNetworks-backgroundCircle\"></span>
            </a>
            <a href=\"#\" class=\"social_share\" data-type=\"in\">
                <span><svg xmlns=\"http://www.w3.org/2000/svg\" width=\"20\" height=\"20\" viewBox=\"0 0 20 20\">
                    <path fill=\"#000\" fill-rule=\"evenodd\" d=\"M1.32 19h3.7V7h-3.7v12zM3.18 1a2.17 2.17 0 1 0-.02 4.34A2.17 2.17 0 0 0 3.18 1zm11.37 5.68a3.9 3.9 0 0 0-3.53 1.94V7H7.44v12h3.73v-5.95c0-1.57.29-3.08 2.23-3.08s1.94 1.79 1.94 3.18V19h3.68v-6.59c0-3.24-.7-5.73-4.47-5.73z\"></path>
                    </svg></span>
                <span class=\"SocialNetworks-background\" style=\"background-color:#007bb5\"></span>
                <span class=\"SocialNetworks-colorfulCircle\" style=\"border-color:#007bb5;\"></span>
                <span class=\"SocialNetworks-backgroundCircle\"></span>
            </a>
            <a href=\"#\" class=\"social_share\" data-type=\"email\">
                <span><svg xmlns=\"http://www.w3.org/2000/svg\" width=\"20\" height=\"20\" viewBox=\"0 0 20 20\">
                    <path fill=\"#000\" fill-rule=\"nonzero\" d=\"M17.788 2H0v13.425a2.201 2.201 0 0 0 2.21 2.2H20V4.157C20 2.937 19.008 2 17.788 2zm.337 4.691l-5.906 5.684h-.005c-.579.575-1.364.874-2.228.874-.865 0-1.65-.299-2.23-.874h-.015l-5.866-5.68V4.532C4.225 6.854 8.5 11 8.5 11H8.5c.383.4.903.57 1.478.57.609 0 1.157-.245 1.544-.67h.003l6.599-6.399v2.19z\"></path>
                    </svg></span>
                <span class=\"SocialNetworks-background\" style=\"background-color:#f16e00\"></span>
                <span class=\"SocialNetworks-colorfulCircle\" style=\"border-color:#f16e00;\"></span>
                <span class=\"SocialNetworks-backgroundCircle\"></span>
            </a>
            <a href=\"#\" class=\"social_share\" data-type=\"tw\">
                <span><svg xmlns=\"http://www.w3.org/2000/svg\" width=\"20\" height=\"20\" viewBox=\"0 0 20 20\">
                    <path fill=\"#000\" fill-rule=\"evenodd\" d=\"M19.12 3.89a7.61 7.61 0 0 1-2.26.64 4 4 0 0 0 1.73-2.23 8 8 0 0 1-2.5 1A3.88 3.88 0 0 0 13.21 2a4 4 0 0 0-3.83 5 11.1 11.1 0 0 1-8.12-4.22 4.1 4.1 0 0 0-.54 2 4.06 4.06 0 0 0 1.8 3.35 3.87 3.87 0 0 1-1.79-.5v.05a4 4 0 0 0 3.16 4 4 4 0 0 1-1 .14 4.53 4.53 0 0 1-.74-.07 4 4 0 0 0 3.68 2.8 7.73 7.73 0 0 1-4.89 1.73H0a11 11 0 0 0 6 1.81c7.24 0 11.21-6.15 11.21-11.49v-.53a8 8 0 0 0 1.91-2.18z\"></path>
                    </svg></span>
                <span class=\"SocialNetworks-background\" style=\"background-color:#1da1f2\"></span>
                <span class=\"SocialNetworks-colorfulCircle\" style=\"border-color:#1da1f2;\"></span>
                <span class=\"SocialNetworks-backgroundCircle\"></span>
            </a>
            <a href=\"#\" class=\"social_share\" data-type=\"whatsapp\">
                <span><svg xmlns=\"http://www.w3.org/2000/svg\" width=\"20\" height=\"20\" viewBox=\"0 0 20 20\">
                    <path fill=\"#000\" fill-rule=\"evenodd\" d=\"M10.143 1c5.041 0 9.143 4.1 9.143 9.143 0 5.041-4.102 9.143-9.143 9.143a9.141 9.141 0 0 1-4.306-1.08l-3.827 1.05a.8.8 0 0 1-.938-1.1l1.389-3.058A9.079 9.079 0 0 1 1 10.143C1 5.1 5.102 1 10.143 1zm0 1.597c-4.16 0-7.546 3.385-7.546 7.546 0 1.593.492 3.118 1.424 4.408a.798.798 0 0 1 .08.796l-.871 1.92 2.5-.688a.79.79 0 0 1 .614.082 7.536 7.536 0 0 0 3.799 1.027c4.161 0 7.546-3.385 7.546-7.545 0-4.161-3.385-7.546-7.546-7.546zm-2.89 3.37c.145 0 .286.032.414.104.392.222.595.778.776 1.17l.062.137c.123.282.234.62.183.915-.058.343-.33.633-.547.888-.147.171-.168.318-.046.504.716 1.194 1.712 2.062 3.01 2.58a.48.48 0 0 0 .178.038.314.314 0 0 0 .252-.131c.224-.277.446-.82.79-.96a.863.863 0 0 1 .332-.064c.352 0 .711.19 1.001.364.357.213.952.475 1.05.915.045.213.004.438-.08.64-.28.682-.977 1.118-1.684 1.254a2.237 2.237 0 0 1-.41.038c-.5 0-.953-.169-1.448-.332a7.715 7.715 0 0 1-1.597-.76 9.1 9.1 0 0 1-2.56-2.376c-.212-.288-.409-.589-.59-.899-.24-.409-.454-.84-.565-1.303a2.61 2.61 0 0 1-.073-.588c-.01-.7.258-1.407.812-1.858.207-.168.478-.276.74-.276z\"></path>
                    </svg></span>
                <span class=\"SocialNetworks-background\" style=\"background-color:#25d366\"></span>
                <span class=\"SocialNetworks-colorfulCircle\" style=\"border-color:#25d366;\"></span>
                <span class=\"SocialNetworks-backgroundCircle\"></span>
            </a>
            <a href=\"#\" class=\"social_share\" style="display:none">
                <span><svg xmlns=\"http://www.w3.org/2000/svg\" width=\"20\" height=\"20\" viewBox=\"0 0 20 20\">
                    <path fill=\"#000\" fill-rule=\"evenodd\" d=\"M8 13V7l5.196 3L8 13zm11.582-7.814a2.505 2.505 0 0 0-1.768-1.768C16.254 3 10 3 10 3s-6.254 0-7.814.418c-.86.23-1.538.908-1.768 1.768C0 6.746 0 10 0 10s0 3.254.418 4.814c.23.86.908 1.538 1.768 1.768C3.746 17 10 17 10 17s6.254 0 7.814-.418a2.504 2.504 0 0 0 1.768-1.768C20 13.254 20 10 20 10s0-3.254-.418-4.814z\"></path>
                    </svg></span>
                <span class=\"SocialNetworks-background\" style=\"background-color:#ff0000\"></span>
                <span class=\"SocialNetworks-colorfulCircle\" style=\"border-color:#ff0000;\"></span>
                <span class=\"SocialNetworks-backgroundCircle\"></span>
            </a>
        </div></div>`;
    
        $(selector).html(sharebarHtml);
    
        $(selector).find(".DetailsNews-socialNetworks").on('click', '.social_share', function(){
            return JSShare.go(this);
        });
}

function getMetaContent(meta){
    var content = $("meta["+meta+"]").attr("content");
    if(typeof content === 'undefined') content = '';
    return content;
}