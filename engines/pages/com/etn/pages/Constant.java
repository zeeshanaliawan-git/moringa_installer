package com.etn.pages;

/**
 * Constant literals
 *
 * @author Ali Adnan
 */
public class Constant {

    //template types
    public static final String TEMPLATE_CLASSIC_BLOCK = "block";
    public static final String TEMPLATE_FEED_VIEW = "feed_view";
    public static final String TEMPLATE_STRUCTURED_CONTENT = "structured_content";
    public static final String TEMPLATE_STRUCTURED_PAGE = "structured_page";
    public static final String TEMPLATE_STORE = "store";

    //system template types
    public static final String SYSTEM_TEMPLATE_MENU = "menu";

    public static final String SYSTEM_TEMPLATE_SIMPLE_PRODUCT = "simple_product";
    public static final String SYSTEM_TEMPLATE_SIMPLE_VIRTUAL_PRODUCT = "simple_virtual_product";
    public static final String SYSTEM_TEMPLATE_CONFIGURABLE_PRODUCT = "configurable_product";
    public static final String SYSTEM_TEMPLATE_CONFIGURABLE_VIRTUAL_PRODUCT = "configurable_virtual_product";

    public static String[] getTemplateTypes() {
        return new String[]{TEMPLATE_CLASSIC_BLOCK, TEMPLATE_FEED_VIEW,
            TEMPLATE_STRUCTURED_CONTENT, TEMPLATE_STRUCTURED_PAGE, TEMPLATE_STORE,
            SYSTEM_TEMPLATE_MENU, SYSTEM_TEMPLATE_SIMPLE_PRODUCT,SYSTEM_TEMPLATE_SIMPLE_VIRTUAL_PRODUCT,
            SYSTEM_TEMPLATE_CONFIGURABLE_PRODUCT,SYSTEM_TEMPLATE_CONFIGURABLE_VIRTUAL_PRODUCT};
    }

    public static String[] getSystemTemplateTypes() {
        return new String[]{SYSTEM_TEMPLATE_MENU, SYSTEM_TEMPLATE_SIMPLE_PRODUCT,SYSTEM_TEMPLATE_SIMPLE_VIRTUAL_PRODUCT,
            SYSTEM_TEMPLATE_CONFIGURABLE_PRODUCT,SYSTEM_TEMPLATE_CONFIGURABLE_VIRTUAL_PRODUCT};
    }

    //page types
    public static final String PAGE_TYPE_FREEMARKER = "freemarker";
    public static final String PAGE_TYPE_REACT = "react";
    public static final String PAGE_TYPE_STRUCTURED = "structured";

    //folders types
    public static final String FOLDER_TYPE_PAGES = "pages";
    public static final String FOLDER_TYPE_CONTENTS = "contents";
    public static final String FOLDER_TYPE_STORE = "stores";

    //structure type
    public static final String STRUCTURE_TYPE_CONTENT = "content";
    public static final String STRUCTURE_TYPE_PAGE = "page";

    //page layouts
    public static final String PAGE_LAYOUT_REACT = "react-grid-layout";
    public static final String PAGE_LAYOUT_CSS_GRID = "css-grid";

    // theme contents
    public static final  String THEME_CONTENT_TEMPLATES = "templates";
    public static final  String THEME_CONTENT_SYSTEM_TEMPLATES = "system templates";
    public static final  String THEME_CONTENT_FILES = "files";
    public static final  String THEME_CONTENT_PAGE_TEMPALTES = "page templates";
    public static final  String THEME_CONTENT_MEDIA = "media";
    public static final  String THEME_CONTENT_LIBRARIES = "libraries";

    // theme status
    public static final  String THEME_LOCKED = "locked";
    public static final  String THEME_OPENED = "opened";


    // screen types for reusing screens
    public static final  String SCREEN_TYPE_BLOCKS = "bloc";
    public static final  String SCREEN_TYPE_MENUS = "menu";


}
