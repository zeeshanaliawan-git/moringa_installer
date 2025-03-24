#!/usr/bin/env node

const fs = require("fs-extra");
const execSync = require("child_process").execSync;
//const rimraf = require("rimraf");
const npmAddScript = require("npm-add-script");
const mariadb = require("mariadb");
const path = require("path");
const jsdom = require("jsdom").JSDOM;
const async = require("async");
const constants = require("./constants");

// TODO: load properties from DB.config table AND Schedular.conf file
const WEBAPP_PATH = constants.PATHS.WEBAPP_PATH;
const WEBAPP_CONTEXT = constants.PATHS.WEBAPP_CONTEXT;
const PAGES_WORKING_DIRECTORY = constants.PATHS.COMPILER_DIRECTORY + "/pages";
const PAGES_FINAL_DIRECTORY = WEBAPP_PATH + "/pages";
const COMPILER_DIRECTORY = constants.PATHS.COMPILER_DIRECTORY;
const TEMPLATE_DIRECTORY = COMPILER_DIRECTORY + "/code_template";
const REACT_BUILDER_CODE_DIRECTORY =
  COMPILER_DIRECTORY + "/code_template/reactbuilder";
const NODE_PATH = constants.PATHS.NODE_PATH;
const JS_BASE_PATH = WEBAPP_PATH + "/uploads/js";
const CSS_BASE_PATH = WEBAPP_PATH + "/uploads/css";
const COMPONENT_BASE_PATH = WEBAPP_PATH + "/uploads/components";

const DB = constants.DATABASE;

function getImport(name, path) {
  return "import " + name + ' from "' + path + '";\n';
}

function random(length) {
  if (!length) {
    length = 5;
  }
  var result = "";
  var characters =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  var charactersLength = characters.length;
  for (var i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * charactersLength));
  }
  return result;
}

function setupPageDirectory(state, callback) {
  console.log("********* Setting up page directory *********");
  try {
    //var currentDate = new Date();
    let page = state.page;
    let pageId = page.page_id;
    /*var backupPath = PAGES_WORKING_DIRECTORY + "/" + pageId + "_" + currentDate.getFullYear() + "_" + currentDate.getMonth() + "_" + currentDate.getDate() + "_" + currentDate.getHours() + "_" + currentDate.getMinutes() + "_" + currentDate.getSeconds() + "_" + currentDate.getMilliseconds();
         try{
         fs.moveSync(PAGES_WORKING_DIRECTORY  + '/' + pageId,backupPath);
         }catch(err){
         fs.removeSync(PAGES_WORKING_DIRECTORY  + '/' + pageId);
         }*/
    // pageId = pageId.substring(0, 8); //pageId is a number
    var idDir = PAGES_WORKING_DIRECTORY + "/" + pageId;
    var projectDir =
      PAGES_WORKING_DIRECTORY + "/" + pageId + "/" + page.package_name;
    var srcDir = projectDir + "/src";
    var componentsDir = srcDir + "/components";
    /***uncomment from here for repulishing */
    if (
      !state.page.published_html_file_path ||
      state.page.published_html_file_path === ""
    ) {
      fs.removeSync(idDir);
    }
    if (fs.existsSync(idDir)) {
      state.isNew = false;
      fs.removeSync(srcDir);
      fs.removeSync(projectDir + "/dist");
    } else {
      state.isNew = true;
      fs.mkdirSync(idDir);
      fs.mkdirSync(projectDir);
      fs.copyFileSync(
        TEMPLATE_DIRECTORY + "/webpack.config.js",
        projectDir + "/webpack.config.js"
      );
      fs.copyFileSync(
        TEMPLATE_DIRECTORY + "/.babelrc",
        projectDir + "/.babelrc"
      );
    }

    fs.mkdirSync(srcDir);
    fs.mkdirSync(componentsDir);
    fs.copySync(REACT_BUILDER_CODE_DIRECTORY, srcDir + "/reactbuilder");

    state.projectDir = projectDir;
    callback(null, state);
  } catch (error) {
    callback(error, state);
  }
}

function setupNode(state, callback) {
  console.log("********* Setting up node, installing node packages *********");
  try {
    console.log("********* Setting up node, is New*********", state.isNew);
    if (state.isNew) {
      process.chdir(state.projectDir);

      execSync("npm init -y", { stdio: "inherit" });

      execSync("npm i webpack --save-dev", { stdio: "inherit" });
      execSync("npm i webpack-cli@^3.0.0 --save-dev", { stdio: "inherit" });
      execSync("npm i html-webpack-plugin html-loader --save-dev", {
        stdio: "inherit",
      });
      execSync(
        "npm i @babel/core babel-loader @babel/preset-env @babel/preset-react --save-dev",
        { stdio: "inherit" }
      );
      execSync(
        "npm install --save @babel/runtime",
        { stdio: "inherit" }
      );
      execSync(
        "npm install --save-dev @babel/plugin-transform-runtime",
        { stdio: "inherit" }
      );
      execSync("npm i @babel/plugin-proposal-class-properties --save-dev", {
        stdio: "inherit",
      });
      execSync("npm i webpack-dev-server --save-dev", { stdio: "inherit" });
      execSync("npm i react react-dom", { stdio: "inherit" });
      execSync("npm i react-grid-layout", { stdio: "inherit" });
      execSync("npm i style-loader", { stdio: "inherit" });
      execSync("npm i css-loader", { stdio: "inherit" });

      npmAddScript({ key: "prod", value: "webpack --mode production" });
      npmAddScript({ key: "dev", value: "webpack --mode development" });
      npmAddScript({
        key: "start",
        value: "webpack-dev-server --open --mode development",
      });
    }
    callback(null, state);
  } catch (error) {
    callback(error, state);
  }
}

function writeIndexJS(state, callback) {
  console.log("********* Writing index JS file *********");
  try {
    fs.writeFileSync(
      state.projectDir + "/src/index.js",
      "import " +
        state.page.class_name +
        ' from "./components/' +
        state.page.class_name +
        '.jsx"'
    );
    callback(null, state);
  } catch (error) {
    callback(error, state);
  }
}

function appendIndexHTML(state,callback){
  console.log("********* appending dist/index.html file *********");
  let pageId = state.page.page_id;
  let fileQuery =
    "SELECT f.id, f.type, f.file_name AS path " +
    " , 'local' AS location, '' AS integrity, '' AS crossorigin  " +
    " , MAX(lf.page_position) AS include_location  " +
    " FROM files f  " +
    " JOIN libraries_files lf ON lf.file_id = f.id  " +
    " JOIN libraries l ON l.id = lf.library_id  " +
    " JOIN component_libraries cl ON cl.library_id = l.id  ";
  if (state.page.layout === "react-grid-layout") {
    fileQuery +=
      " JOIN ( " +
      "     SELECT DISTINCT component_id  " +
      "     FROM page_items " +
      "     WHERE page_id = ? AND component_id > 0 " +
      " ) c ON c.component_id = cl.component_id ";
  } else if (state.page.layout === "css-grid") {
    if (
      Array.isArray(state.cssGridComponentIds) &&
      state.cssGridComponentIds.length > 0
    ) {
      fileQuery +=
        " and cl.component_id in (" +
        getInFromArray(state.cssGridComponentIds) +
        ")";
    } else {
      fileQuery += " and cl.component_id in (-1)";
    }
  }
  fileQuery +=
    " GROUP BY f.id " + " ORDER BY lf.page_position DESC, lf.sort_order ASC";
  console.log(fileQuery);

  state.connection
    .query(fileQuery, [pageId])
    .then(function (result) {
      let head = "";
      let body = "";      
      if (Array.isArray(result)) {
        console.log("inside files for page",pageId,result.length);
        result.forEach(function (file, index) {
          let tag;
          let fileLocation;
          if (file.location === "web") {
            fileLocation = file.path;
          } else if (file.location === "local") {
            fileLocation =
              WEBAPP_CONTEXT +
              "/uploads/" +
              state.page.site_id +
              "/" +
              file.type +
              "/" +
              file.path;
          }
          console.log("filelocation",fileLocation,"state.page.site_id",state.page.site_id);
          if (fileLocation) {
            if (file.type === "js") {
              tag = "<script src='" + fileLocation + "' ";
            } else if (file.type === "css") {
              tag = "<link rel='stylesheet' href='" + fileLocation + "' ";
            }
            if (tag) {
              if (file.integrity) {
                tag += "integrity='" + file.integrity + "' ";
              }
              if (file.crossorigin) {
                tag += "crossorigin='" + file.crossorigin + "' ";
              }
              if (file.type === "js") {
                tag += "></script>";
              } else if (file.type === "css") {
                tag += "></link>";
              }
              
              if (file.include_location === "head") {
                head += tag;
              } else if (file.include_location === "body") {
                body += tag;
              }
            }
          }
        });
      }
      if(head || body){
        var html = fs.readFileSync(
          state.projectDir + "/dist/index.html",
          "utf8"
        );
        html = html.replace('<script defer="defer" src="main.js"></script>',head + '<script defer="defer" src="main.js"></script>');
        html = html.replace('</body>',body + '</body>');
        fs.removeSync(state.projectDir + "/dist/index.html");
        fs.writeFileSync(state.projectDir + "/dist/index.html", html);

      }      
      callback(null, state);
    })
    .catch(function (error) {
      callback(error, state);
    });
  
}

function writeIndexHTML(state, callback) {
  console.log("********* Writing index html file *********");
  try {
    var pageId = state.page.page_id;
    var html = fs.readFileSync(
      TEMPLATE_DIRECTORY + "/index-template.html",
      "utf8"
    );
    var dom = new jsdom(html);
    dom.window.document.head.innerHTML +=
      "<meta name='asimina-dynamic-page-id' content='" + pageId + "'/>";
    dom.window.document.head.innerHTML +=
      "<title>" + state.page.title + "</title>";
    fs.writeFileSync(state.projectDir + "/src/index.html", dom.serialize());
    callback(null, state);
  } catch (error) {
    callback(error, state);
  }
  /*
  // let fileQuery = "select DISTINCT f.id, f.type, f.file_name AS path "
  //         + " , 'local' AS location, '' AS integrity, '' AS crossorigin "
  //         + " , lf.page_position AS include_location "
  //         + " from files f "
  //         + " JOIN libraries_files lf ON lf.file_id = f.id "
  //         + " JOIN libraries l ON l.id = lf.library_id "
  //         + " JOIN page_libraries pl ON pl.library_id = l.id and page_id = ? "
  //         + " ORDER BY lf.sort_order";
  let fileQuery =
    "SELECT f.id, f.type, f.file_name AS path " +
    " , 'local' AS location, '' AS integrity, '' AS crossorigin  " +
    " , MAX(lf.page_position) AS include_location  " +
    " FROM files f  " +
    " JOIN libraries_files lf ON lf.file_id = f.id  " +
    " JOIN libraries l ON l.id = lf.library_id  " +
    " JOIN component_libraries cl ON cl.library_id = l.id  " +
    " JOIN ( " +
    "     SELECT DISTINCT component_id  " +
    "     FROM page_items " +
    "     WHERE page_id = ? AND component_id > 0 " +
    " ) c ON c.component_id = cl.component_id " +
    " GROUP BY f.id " +
    " ORDER BY lf.page_position DESC, lf.sort_order ASC";

  state.connection
    .query(fileQuery, [pageId])
    .then(function (result) {
      if (Array.isArray(result)) {
        result.forEach(function (file, index) {
          let tag;
          let fileLocation;
          if (file.location === "web") {
            fileLocation = file.path;
          } else if (file.location === "local") {
            fileLocation =
              WEBAPP_CONTEXT + "/uploads/" + file.type + "/" + file.path;
          }
          if (fileLocation) {
            if (file.type === "js") {
              tag = "<script src='" + fileLocation + "' ";
            } else if (file.type === "css") {
              tag = "<link rel='stylesheet' href='" + fileLocation + "' ";
            }
            if (tag) {
              if (file.integrity) {
                tag += "integrity='" + file.integrity + "' ";
              }
              if (file.crossorigin) {
                tag += "crossorigin='" + file.crossorigin + "' ";
              }
              tag += "/>";

              if (file.include_location === "head") {
                dom.window.document.head.innerHTML += tag;
              } else if (file.include_location === "body") {
                dom.window.document.body.innerHTML += tag;
              }
            }
          }
        });
      }
      fs.writeFileSync(state.projectDir + "/src/index.html", dom.serialize());
      callback(null, state);
    })
    .catch(function (error) {
      callback(error, state);
    });*/
}

function getComponentListFromChildren(gridItem, state) {
  if (gridItem && Array.isArray(gridItem.children))
    gridItem.children.forEach(function (child, index) {
      if (child.type === "gridItem" && child.compId) {
        state.cssGridComponentIds.push(child.compId);
      }
      getComponentListFromChildren(child, state);
    });
  console.log("-----name", gridItem.name);
  console.log("-----ids", state.cssGridComponentIds);
}

function getComponentProperties(state, callback) {
  console.log("********* Getting component properties *********");
  console.log("****** components are:", state.cssGridComponentIds);
  state.componentPropertiesMap = {};
  if (state.cssGridComponentIds.length > 0) {
    let query =
      "select * from component_properties where component_id in (" +
      getInFromArray(state.cssGridComponentIds) +
      ")";
    state.connection
      .query(query)
      .then(function (result) {
        result.forEach(function (componentProperty, index) {
          state.componentPropertiesMap[
            componentProperty.id
          ] = componentProperty;
        });
        callback(null, state);
      })
      .catch(function (error) {
        callback(error, state);
      });
  } else {
    callback(null, state);
  }
}

function getComponentList(state, callback) {
  try {
    state.cssGridComponentIds = [];
    getComponentListFromChildren(state.layout_data, state);
    callback(null, state);
  } catch (error) {
    callback(error, state);
  }
}

function copyPageComponents(state, callback) {
  console.log("********* Copying page components *********");
  console.log("state.cssGridComponentIds", state.cssGridComponentIds);
  let pageId = state.page.page_id;
  let compQuery;
  let params = [];
  if (state.page.layout === "react-grid-layout") {
    compQuery =
      "select distinct c.id ,c.name,c.file_path " +
      " from page_items pi " +
      " join components c on pi.component_id = c.id " +
      " where page_id = ?";
    params = [pageId];
  } else if (state.page.layout === "css-grid") {
    if (state.cssGridComponentIds.length > 0) {
      compQuery =
        "select c.id ,c.name,c.file_path " +
        " from components c " +
        " where c.id in ( " +
        getInFromArray(state.cssGridComponentIds) +
        ") ";
    } else {
      //dummy query so other things can work.
      compQuery =
        "select c.id ,c.name,c.file_path " +
        " from components c " +
        " where 1 = 0 ";
    }
    params = [];
  }
  if (compQuery) {
    state.connection
      .query(compQuery, params)
      .then(function (result) {
        state.componentIds = [];
        state.componentMap = {};
        var imports = getImport(
          "ReactBuilderParent",
          "../reactbuilder/ReactBuilderParent.jsx"
        );
        result.forEach(function (component, index) {
          //fs.copyFileSync(component.file_path,state.projectDir + "/src/components/" + path.basename(component.file_path));
          copyComponent(
            state.page.site_id,
            component.file_path,
            state.projectDir
          );
          imports += getImport(
            component.name,
            "./" + path.basename(component.file_path)
          );
          state.componentIds.push(component.id);
          state.componentMap[component.id] = component;
        });
        state.imports = imports;
        callback(null, state);
      })
      .catch(function (error) {
        callback(error, state);
      });
  } else {
    calback("invalid layout type", state);
  }
}

function copyComponent(siteId, filePath, projectDir) {
  let componentPath = path.join(
    WEBAPP_PATH,
    "uploads",
    "" + siteId,
    "components",
    filePath
  );
  fs.copyFileSync(
    componentPath,
    projectDir + "/src/components/" + path.basename(filePath)
  );
}

function copyDependantComponents(state, callback) {
  console.log("********* Copying dependant components *********");
  if (state.componentIds && state.componentIds.length) {
    let query =
      "" +
      " select c.id,c.name,c.file_path from components c join ( " +
      "    select cd1.main_component_id component_id_1,cd2.main_component_id component_id_2,cd3.main_component_id component_id_3,cd4.main_component_id component_id_4,cd5.main_component_id component_id_5 " +
      "    from component_dependencies cd1 " +
      "    left join component_dependencies cd2 on cd2.dependant_component_id = cd1.main_component_id " +
      "    left join component_dependencies cd3 on cd3.dependant_component_id = cd2.main_component_id " +
      "    left join component_dependencies cd4 on cd4.dependant_component_id = cd3.main_component_id " +
      "    left join component_dependencies cd5 on cd5.dependant_component_id = cd4.main_component_id " +
      "    where cd1.dependant_component_id in (" +
      getInFromArray(state.componentIds) +
      ") ) cd " +
      " where c.id = cd.component_id_1 " +
      "  or c.id = cd.component_id_2 " +
      "  or c.id = cd.component_id_3 " +
      "  or c.id = cd.component_id_4 " +
      "  or c.id = cd.component_id_5 ";

    state.connection
      .query(query)
      .then(function (result) {
        result.forEach(function (component) {
          copyComponent(
            state.page.site_id,
            component.file_path,
            state.projectDir
          );
        });
        callback(null, state);
      })
      .catch(function (error) {
        callback(error, state);
      });
  } else {
    callback(null, state);
  }
}

function getPageItems(state, callback) {
  console.log("********* Getting page items from database *********");

  let query =
    "" +
    " select page_id, pi.id AS page_item_id, component_id, index_key, " +
    " x_cord, y_cord, width, height, css_classes, css_style, " +
    " property_id, name, type, value " +
    " from page_items pi " +
    " left join ( " +
    "     select page_item_id, pv.property_id, p.name, p.type, pv.value " +
    "     from page_item_property_values pv " +
    "     join component_properties p on p.id = pv.property_id " +
    " ) piv on pi.id = piv.page_item_id " +
    " where page_id = ?";

  state.connection
    .query(query, [state.page.page_id])
    .then(function (result) {
      let pageItems = {};
      result.forEach(function (record) {
        if (!pageItems[record.page_item_id]) {
          pageItems[record.page_item_id] = {
            page_item_id: record.page_item_id,
            component_id: record.component_id,
            index: record.index_key,
            x: record.x_cord,
            y: record.y_cord,
            width: record.width,
            height: record.height,
            className: record.css_classes,
            style: record.css_style,
            properties: [],
          };
        }
        if (record.property_id) {
          pageItems[record.page_item_id].properties.push({
            property_id: record.property_id,
            name: record.name,
            type: record.type,
            value: record.value,
          });
        }
      });
      state.pageItems = pageItems;
      callback(null, state);
    })
    .catch(function (error) {
      callback(error, state);
    });
}

function getPageInitUrls(state, callback) {
  console.log("********* Getting page init urls from database *********");
  let query =
    "select js_key `key`,url from pages_urls where page_id = ? and type = 'init'";
  state.connection
    .query(query, [state.page.page_id])
    .then(function (result) {
      state.pageInitUrls = result;
      callback(null, state);
    })
    .catch(function (error) {
      callback(error, state);
    });
}

function getRender(state, callback) {
  console.log("********* Getting render *********");
  if (state.page.layout === "css-grid") {
    getCSSGridLayoutRender(state, function (error, state) {
      callback(error, state);
    });
  } else if (state.page.layout === "react-grid-layout") {
    getReactGridLayourRender(state, function (error, state) {
      callback(error, state);
    });
  }
}

function getTemplateRowCol(data) {
  let css = "";
  if (Array.isArray(data)) {
    data.forEach(function (row) {
      css += " " + row.join("");
    });
  }
  return css;
}
function getSingleCSSGridDivRender(gridItem, state) {
  let render = "";
  let componentMap = state.componentMap;

  if (gridItem) {
    let divId = "d" + random();
    let style = {};
    if (gridItem.gridProps) {
      if (gridItem.type === "grid") {
        style.display = "grid";
      }
      if (Array.isArray(gridItem.gridProps.columns)) {
        style.gridTemplateColumns = getTemplateRowCol(
          gridItem.gridProps.columns
        );
      }
      if (Array.isArray(gridItem.gridProps.rows)) {
        style.gridTemplateRows = getTemplateRowCol(gridItem.gridProps.rows);
      }
      if (Array.isArray(gridItem.gridProps.rowGap)) {
        style.rowGap = gridItem.gridProps.rowGap.join("");
      }
      if (Array.isArray(gridItem.gridProps.columnGap)) {
        style.columnGap = gridItem.gridProps.columnGap.join("");
      }
      if (gridItem.gridProps.alignItems) {
        style.alignItems = gridItem.gridProps.alignItems;
      }
      if (gridItem.gridProps.justifyItems) {
        style.justifyItems = gridItem.gridProps.justifyItems;
      }
    }

    if (gridItem.itemProps) {
      if (gridItem.itemProps["grid-row-start"]) {
        style.gridRowStart = gridItem.itemProps["grid-row-start"];
      }
      if (gridItem.itemProps["grid-row-end"]) {
        style.gridRowEnd = gridItem.itemProps["grid-row-end"];
      }
      if (gridItem.itemProps["grid-column-start"]) {
        style.gridColumnStart = gridItem.itemProps["grid-column-start"];
      }
      if (gridItem.itemProps["grid-column-end"]) {
        style.gridColumnEnd = gridItem.itemProps["grid-column-end"];
      }
    }

    if (gridItem.cssStyle) {
      state.styles[divId] = JSON.parse(gridItem.cssStyle);
    }

    render += "<div id='" + divId + "' ";

    if (gridItem.cssClasses) {
      render += "className='" + gridItem.cssClasses + "'";
    }

    render += "style={" + JSON.stringify(style) + "}>";
    //render += "<div>";

    if (
      gridItem.type === "gridItem" &&
      gridItem.compId &&
      componentMap[gridItem.compId]
    ) {
      render += "<" + componentMap[gridItem.compId].name;
      for (var propertyId in gridItem.compPropValues) {
        if (state.componentPropertiesMap[propertyId]) {
          render += " " + state.componentPropertiesMap[propertyId].name + "=";
          if (
            state.componentPropertiesMap[propertyId].type === "json" ||
            state.componentPropertiesMap[propertyId].type === "number" ||
            state.componentPropertiesMap[propertyId].type === "boolean"
          ) {
            render += "{" + gridItem.compPropValues[propertyId] + "}";
          } else if (
            state.componentPropertiesMap[propertyId].type === "string"
          ) {
            render += "{'" + gridItem.compPropValues[propertyId] + "'}";
          }
        }
      }
      render += "/>";
    }
    if (Array.isArray(gridItem.children)) {
      gridItem.children.forEach(function (child, index) {
        render += getSingleCSSGridDivRender(child, state);
      });
    }
    render += "</div>";
  }
  return render;
}

function getCSSGridLayoutRender(state, callback) {
  console.log("********* Getting css grid layout render *********");
  try {
    state.styles = {}; //extracted for each single item and set.
    let render =
      "<ReactBuilderParent __initContext={" +
      JSON.stringify(state.pageInitUrls) +
      "} __context={{'page': " +
      JSON.stringify(state.page) +
      "}}>";
    render += getSingleCSSGridDivRender(state.layout_data, state);
    render += "</ReactBuilderParent>";

    state.render = render;

    callback(null, state);
  } catch (error) {
    callback(error, state);
  }
}

function getReactGridLayourRender(state, callback) {
  console.log("********* Getting react grid layout render *********");

  try {
    let render =
      "<ReactBuilderParent __initContext={" +
      JSON.stringify(state.pageInitUrls) +
      "} __context={{'page': " +
      JSON.stringify(state.page) +
      "}}><ResponsiveGridLayout {...defaultLayoutProps}>";
    let componentMap = state.componentMap;
    let layout = [];
    let styles = {};
    for (var pageItemId in state.pageItems) {
      let divId = "d" + random();
      let pageItem = state.pageItems[pageItemId];
      layout.push({
        x: pageItem.x,
        y: pageItem.y,
        w: pageItem.width,
        h: pageItem.height,
        i: "" + pageItem.index,
        static: true,
      });
      render += "{this.isHidden('" + pageItem.index + "')?<div/>:";
      render += "<div id='" + divId + "' key='" + pageItem.index + "' ";
      if (pageItem.className) {
        render += " className='" + pageItem.className + "'";
      }
      render += ">";

      if (pageItem.style) {
        styles[divId] = JSON.parse(pageItem.style);
      }

      if (componentMap[pageItem.component_id]) {
        let component = componentMap[pageItem.component_id];
        let componentStr =
          "<" +
          component.name +
          " gridIndex={'" +
          pageItem.index +
          "'}  currentLayout={this.state.layout}  defaultLayout={this.state.defaultLayout} changeLayout={this.changeLayout} gotoDefaultLayout={this.gotoDefaultLayout}";

        pageItem.properties.forEach(function (property) {
          componentStr += " " + property.name + "=";
          if (
            property.type === "json" ||
            property.type === "number" ||
            property.type === "boolean"
          ) {
            componentStr += "{" + property.value + "}";
          } else if (property.type === "string") {
            componentStr += "{'" + property.value + "'}";
          }
        });

        componentStr += "/>";
        render += componentStr;
      }
      render += "</div>}";
    }
    render += "</ResponsiveGridLayout></ReactBuilderParent>";
    state.render = render;
    state.layout = layout;
    state.styles = styles;
    callback(null, state);
  } catch (error) {
    callback(error, state);
  }
}

function getInFromArray(arr) {
  var inStr = "";
  arr.forEach(function (o) {
    if (inStr) {
      inStr += ",";
    }
    inStr += "'" + o + "'";
  });
  return inStr;
}

function writeMainComponent(state, callback) {
  console.log("********* Writing main component *********");
  try {
    var component = fs.readFileSync(
      TEMPLATE_DIRECTORY +
        "/" +
        state.page.layout +
        "/page-component-template.jsx",
      "utf8"
    );
    component = component.replace(
      /\/\*\*\*___CLASS_NAME___\*\*\*\//g,
      state.page.class_name
    );
    component = component.replace(
      /\/\*\*\*___IMPORTS___\*\*\*\//g,
      state.imports
    );
    component = component.replace(
      /\/\*\*\*___RENDER___\*\*\*\//g,
      state.render
    );
    component = component.replace(
      /\/\*\*\*___LAYOUT___\*\*\*\//g,
      JSON.stringify(state.layout)
    );
    component = component.replace(
      /\/\*\*\*___STYLES___\*\*\*\//g,
      JSON.stringify(state.styles)
    );
    component = component.replace(
      /\/\*\*\*___ROW_HEIGHT___\*\*\*\//g,
      state.page.row_height
    );
    component = component.replace(
      /\/\*\*\*___PAGE_MARGIN_X___\*\*\*\//g,
      state.page.item_margin_x
    );
    component = component.replace(
      /\/\*\*\*___PAGE_MARGIN_Y___\*\*\*\//g,
      state.page.item_margin_y
    );
    component = component.replace(
      /\/\*\*\*___CONTAINER_PADDING_X___\*\*\*\//g,
      state.page.container_padding_x
    );
    component = component.replace(
      /\/\*\*\*___CONTAINER_PADDING_Y___\*\*\*\//g,
      state.page.container_padding_y
    );
    fs.writeFileSync(
      state.projectDir + "/src/components/" + state.page.class_name + ".jsx",
      component
    );
    callback(null, state);
  } catch (error) {
    callback(error, state);
  }
}

function installNodePackages(state, callback) {
  console.log("********* Install dependant components node packages *********");
  if (state.componentIds && state.componentIds.length) {
    let query =
      "" +
      "select distinct p.package_name from component_packages p join ( " +
      " select cd1.dependant_component_id component_id_0,cd1.main_component_id component_id_1,cd2.main_component_id component_id_2,cd3.main_component_id component_id_3,cd4.main_component_id component_id_4,cd5.main_component_id component_id_5 " +
      "  from component_dependencies cd1 " +
      "  left join component_dependencies cd2 on cd2.dependant_component_id = cd1.main_component_id " +
      "  left join component_dependencies cd3 on cd3.dependant_component_id = cd2.main_component_id " +
      "  left join component_dependencies cd4 on cd4.dependant_component_id = cd3.main_component_id " +
      "  left join component_dependencies cd5 on cd5.dependant_component_id = cd4.main_component_id " +
      "  where cd1.dependant_component_id in (" +
      getInFromArray(state.componentIds) +
      ") ) cd " +
      " where p.component_id = cd.component_id_0 " +
      "  or p.component_id = cd.component_id_1 " +
      "   or p.component_id = cd.component_id_2 " +
      "   or p.component_id = cd.component_id_3 " +
      "   or p.component_id = cd.component_id_4 " +
      "  or p.component_id = cd.component_id_5";

    process.chdir(state.projectDir);
    state.connection
      .query(query)
      .then(function (result) {
        result.forEach(function (packageName) {
          execSync("npm i " + packageName.package_name, { stdio: "inherit" });
        });
        callback(null, state);
      })
      .catch(function (error) {
        callback(error, state);
      });
  } else {
    callback(null, state);
  }
}

function createDist(state, callback) {
  console.log("********* Creating distribution *********");
  try {
    process.chdir(state.projectDir);
    execSync("npm run prod", { stdio: "inherit" });
    callback(null, state);
  } catch (error) {
    callback(error, state);
  }
}

function copyDist(state, callback) {
  console.log("********* Creating distribution *********");
  try {
    let destPath = path.join(
      PAGES_FINAL_DIRECTORY,
      "" + state.page.site_id,
      state.page.langue_code,
      state.page.variant,
      state.page.path
    );
    let srcPath = path.join(state.projectDir, "dist");
    fs.copySync(srcPath, destPath);
    callback(null, state);
  } catch (error) {
    callback(error, state);
  }
}

function getDBConnection(callback) {
  console.log("********* Getting database connection *********");

  mariadb
    .createConnection(DB)
    .then(function (connection) {
      callback(null, { connection });
    })
    .catch(function (error) {
      callback(error);
    });
}

function cleanup(state) {
  console.log("********* Cleaning up *********");

  if (state && state.connection) {
    state.connection.destroy();
  }
}

function getPage(state, callback) {
  console.log("********* Getting page from database *********");

  state.connection
    .query(
      "SELECT id AS page_id,package_name,class_name,title,layout,site_id,path,langue_code,variant,row_height,item_margin_x,item_margin_y,container_padding_x,container_padding_y,published_html_file_path,layout_data FROM pages WHERE id = ?",
      [process.argv[2]]
    )
    .then(function (result) {
      if (result && result.length && result[0]) {
        state.page = result[0];
        state.page.layout_data = state.page.layout_data.replace(
          /#slash#/g,
          "\\"
        );
        state.layout_data = JSON.parse(state.page.layout_data);
        callback(null, state);
      } else {
        callback("No page found", state);
      }
    })
    .catch(function (error) {
      callback(error, state);
    });
}

const argv = process.argv;
if (argv.length != 3) {
  console.log("Usage node compiler.js page_id");
} else {
  process.env.PATH = NODE_PATH + ":" + process.env.PATH;
  async.waterfall(
    [
      getDBConnection,
      getPage,
      setupPageDirectory,
      setupNode,
      getComponentList,
      writeIndexJS,
      writeIndexHTML,
      getComponentProperties,
      copyPageComponents,
      copyDependantComponents,
      getPageItems,
      getPageInitUrls,
      getRender,
      writeMainComponent,
      installNodePackages,
      createDist,
      appendIndexHTML,
      copyDist,
    ],
    function (error, state) {
      cleanup(state);
      if (error) {
        console.error(error);
        process.exit(1);
      } else {
        process.exit(0);
      }
    }
  );
}
