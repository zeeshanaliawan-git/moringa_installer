#!/usr/bin/env node

const fs = require('fs-extra');
const execSync = require('child_process').execSync;
//const rimraf = require("rimraf");
const npmAddScript = require('npm-add-script');
const mariadb = require('mariadb');
const path = require('path');
const jsdom = require('jsdom').JSDOM;
const async = require('async');
const constants = require("./constants");
const puppeteer = require('puppeteer');


// TODO: load properties from DB.config table AND Schedular.conf file
const WEBAPP_PATH = constants.PATHS.WEBAPP_PATH;
const WEBAPP_CONTEXT = constants.PATHS.WEBAPP_CONTEXT;
const PAGES_WORKING_DIRECTORY = constants.PATHS.COMPILER_DIRECTORY + "/pages_images";
const PAGES_FINAL_DIRECTORY = WEBAPP_PATH + '/pages';
const COMPILER_DIRECTORY = constants.PATHS.COMPILER_DIRECTORY;
const TEMPLATE_DIRECTORY = COMPILER_DIRECTORY + "/code_template";
const REACT_BUILDER_CODE_DIRECTORY = COMPILER_DIRECTORY + "/code_template/reactbuilder";
const NODE_PATH = constants.PATHS.NODE_PATH;
const JS_BASE_PATH = WEBAPP_PATH + "/uploads/js";
const CSS_BASE_PATH = WEBAPP_PATH + "/uploads/css";
const COMPONENT_BASE_PATH = WEBAPP_PATH + "/uploads/components";


const DB = constants.DATABASE;

function getImport(name, path) {
    return 'import ' + name + ' from "' + path + '";\n';
}

function random(length) {
    if (!length) {
        length = 5;
    }
    var result = '';
    var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
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
        var idDir = PAGES_WORKING_DIRECTORY + '/' + pageId;
        var projectDir = PAGES_WORKING_DIRECTORY + '/' + pageId + '/' + page.package_name;
        var srcDir = projectDir + "/src";
        var componentsDir = srcDir + "/components";

        fs.removeSync(idDir);
        fs.mkdirSync(idDir);
        fs.mkdirSync(projectDir);


        fs.copyFileSync(TEMPLATE_DIRECTORY + "/webpack.config.js", projectDir + "/webpack.config.js");
        fs.copyFileSync(TEMPLATE_DIRECTORY + "/.babelrc", projectDir + "/.babelrc");
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
        process.chdir(state.projectDir);

        execSync("npm init -y",{stdio: 'inherit'});

        execSync("npm i webpack --save-dev",{stdio: 'inherit'});
        execSync("npm i webpack-cli@^3.0.0 --save-dev",{stdio: 'inherit'});
        execSync("npm i html-webpack-plugin html-loader --save-dev",{stdio: 'inherit'});
        execSync("npm i @babel/core babel-loader @babel/preset-env @babel/preset-react --save-dev",{stdio: 'inherit'});
        execSync("npm i @babel/plugin-proposal-class-properties --save-dev",{stdio: 'inherit'});
        execSync("npm i webpack-dev-server --save-dev",{stdio: 'inherit'});
        execSync("npm i react react-dom",{stdio: 'inherit'});
        execSync("npm i react-grid-layout",{stdio: 'inherit'});
        execSync("npm i style-loader",{stdio: 'inherit'});
        execSync("npm i css-loader",{stdio: 'inherit'});

        npmAddScript({key: "prod", value: "webpack --mode production"});
        npmAddScript({key: "dev", value: "webpack --mode development"});
        npmAddScript({key: "start", value: "webpack-dev-server --open --mode development"});
        callback(null, state);
    } catch (error) {
        callback(error, state);
    }
}

function writeIndexJS(state, callback) {
    console.log("********* Writing index JS file *********");
    try {
        fs.writeFileSync(state.projectDir + "/src/index.js", 'import ' + state.page.class_name + ' from "./components/' + state.page.class_name + '.jsx"');
        callback(null, state);
    } catch (error) {
        callback(error, state);
    }
}

function writeIndexHTML(state, callback) {
    console.log("********* Writing index html file *********");

    var pageId = state.page.page_id;
    var html = fs.readFileSync(TEMPLATE_DIRECTORY + '/index-template.html', 'utf8');
    var dom = new jsdom(html);
    dom.window.document.head.innerHTML += "<meta name='asimina-dynamic-page-id' content='" + pageId + "'/>";
    dom.window.document.head.innerHTML += "<title>" + state.page.title + "</title>";
    fs.writeFileSync(state.projectDir + "/src/index.html", dom.serialize());
    
    let fileQuery = "SELECT f.id, f.type, f.file_name AS path "
                + " , 'local' AS location, '' AS integrity, '' AS crossorigin  "
                + " , MAX(lf.page_position) AS include_location  "
                + " FROM files f  "
                + " JOIN libraries_files lf ON lf.file_id = f.id  "
                + " JOIN libraries l ON l.id = lf.library_id  "
                + " JOIN component_libraries cl ON cl.library_id = l.id  "
                + " JOIN ( "
                + "     SELECT DISTINCT component_id  "
                + "     FROM page_items "
                + "     WHERE page_id = ? AND component_id > 0 "
                + " ) c ON c.component_id = cl.component_id "
                + " GROUP BY f.id "
                + " ORDER BY lf.page_position DESC, lf.sort_order ASC";

    state.connection.query(fileQuery, [pageId])
            .then(function(result) {
                state.files = result;                
                callback(null, state);
            })
            .catch(function(error) {
                callback(error, state);
            });
}

function copyPageComponents(state, callback) {
    console.log("********* Copying page components *********");
    let pageId = state.page.page_id;
    let compQuery = "select distinct c.id ,c.name,c.file_path "
            + " from page_items pi "
            + " join components c on pi.component_id = c.id "
            + " where page_id = ?";
    state.connection.query(compQuery, [pageId])
            .then(function(result) {
                state.componentIds = [];
                state.componentMap = {};
                var imports = getImport("ReactBuilderParent", "../reactbuilder/ReactBuilderParent.jsx");
                result.forEach(function(component, index) {
                    //fs.copyFileSync(component.file_path,state.projectDir + "/src/components/" + path.basename(component.file_path));
                    copyComponent(state.page.site_id, component.file_path, state.projectDir);
                    imports += getImport(component.name, "./" + path.basename(component.file_path));
                    state.componentIds.push(component.id);
                    state.componentMap[component.id] = component;
                });
                state.imports = imports;
                callback(null, state);
            })
            .catch(function(error) {
                callback(error, state);
            });
}

function copyComponent(siteId, filePath, projectDir) {
    let componentPath = path.join(COMPONENT_BASE_PATH, "" + siteId, filePath);
    fs.copyFileSync(componentPath, projectDir + "/src/components/" + path.basename(filePath));
}

function copyDependantComponents(state, callback) {
    console.log("********* Copying dependant components *********");
    if (state.componentIds && state.componentIds.length) {
        let query = ""
                + " select c.id,c.name,c.file_path from components c join ( "
                + "    select cd1.main_component_id component_id_1,cd2.main_component_id component_id_2,cd3.main_component_id component_id_3,cd4.main_component_id component_id_4,cd5.main_component_id component_id_5 "
                + "    from component_dependencies cd1 "
                + "    left join component_dependencies cd2 on cd2.dependant_component_id = cd1.main_component_id "
                + "    left join component_dependencies cd3 on cd3.dependant_component_id = cd2.main_component_id "
                + "    left join component_dependencies cd4 on cd4.dependant_component_id = cd3.main_component_id "
                + "    left join component_dependencies cd5 on cd5.dependant_component_id = cd4.main_component_id "
                + "    where cd1.dependant_component_id in (" + getInFromArray(state.componentIds) + ") ) cd "
                + " where c.id = cd.component_id_1 "
                + "  or c.id = cd.component_id_2 "
                + "  or c.id = cd.component_id_3 "
                + "  or c.id = cd.component_id_4 "
                + "  or c.id = cd.component_id_5 ";

        state.connection.query(query)
                .then(function(result) {
                    result.forEach(function(component) {
                        copyComponent(state.page.site_id, component.file_path, state.projectDir);
                    });
                    callback(null, state);
                })
                .catch(function(error) {
                    callback(error, state);
                });
    } else {
        callback(null, state);
    }
}

function getPageItems(state, callback) {
    console.log("********* Getting page items from database *********");

    let query = ""
            + " select page_id, pi.id AS page_item_id, component_id, index_key, "
            + " x_cord, y_cord, width, height, css_classes, css_style, "
            + " property_id, name, type, value "
            + " from page_items pi "
            + " left join ( "
            + "     select page_item_id, pv.property_id, p.name, p.type, pv.value "
            + "     from page_item_property_values pv "
            + "     join component_properties p on p.id = pv.property_id "
            + " ) piv on pi.id = piv.page_item_id "
            + " where page_id = ?";

    state.connection.query(query, [state.page.page_id])
            .then(function(result) {
                let pageItems = {};
                result.forEach(function(record) {
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
                            properties: []
                        };
                    }
                    if (record.property_id) {
                        pageItems[record.page_item_id].properties.push({property_id: record.property_id, name: record.name, type: record.type, value: record.value});
                    }
                });
                state.pageItems = pageItems;
                callback(null, state);
            })
            .catch(function(error) {
                callback(error, state);
            });
}

function getPageInitUrls(state,callback){
    console.log("********* Getting page init urls from database *********");
    let query = "select js_key `key`,url from pages_urls where page_id = ? and type = 'init'";
    state.connection.query(query, [state.page.page_id])
            .then(function(result) {                
                state.pageInitUrls = result;
                callback(null, state);
            })
            .catch(function(error) {
                callback(error, state);
            });
}

function getRender(state, callback) {
    console.log("********* Getting render *********");

    try {
        let render = "";
        //render += "<ReactBuilderParent __initContext={" + JSON.stringify(state.pageInitUrls) + "} __context={{'page': " + JSON.stringify(state.page) + "}}>"
        render += "<ResponsiveGridLayout {...defaultLayoutProps}>";
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
                static: true
            });            
            render += "{this.isHidden('" + pageItem.index + "')?<div/>:";
            render += "<div id='" + divId + "' key='" + pageItem.index + "' ";
            if(pageItem.className){
                render += " className='" + pageItem.className + "'";
            }
            render += ">";

            if(pageItem.style){
                styles[divId] = JSON.parse(pageItem.style);
            }

            if (componentMap[pageItem.component_id] && componentMap[pageItem.component_id].name !== "MoringaAuthentication") {
                let component = componentMap[pageItem.component_id];
                let componentStr = "<" + component.name + " changeLayout={this.changeLayout} gotoDefaultLayout={this.gotoDefaultLayout}";

                pageItem.properties.forEach(function(property) {
                    componentStr += " " + property.name + "=";
                    if (property.type === 'json' || property.type === 'number' || property.type === 'boolean') {
                        componentStr += "{" + property.value + "}";
                    } else if (property.type === 'string') {
                        componentStr += "{'" + property.value + "'}";
                    }
                });

                componentStr += "/>";
                render += componentStr;
            }
            render += "</div>}";
        }
        render += "</ResponsiveGridLayout>";
        //render += "</ReactBuilderParent>";
        state.render = render;
        //console.log(render);
        //state.render = "<div>Hello world</div>";
        state.layout = layout;
        state.styles = styles;
        callback(null, state);
    } catch (error) {
        callback(error, state);
    }
}

function getInFromArray(arr) {
    var inStr = "";
    arr.forEach(function(o) {
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
        var component = fs.readFileSync(TEMPLATE_DIRECTORY + '/page-html-template.jsx', 'utf8');
        component = component.replace(/\/\*\*\*___CLASS_NAME___\*\*\*\//g, state.page.class_name);
        component = component.replace(/\/\*\*\*___IMPORTS___\*\*\*\//g, state.imports);
        component = component.replace(/\/\*\*\*___RENDER___\*\*\*\//g, state.render);
        component = component.replace(/\/\*\*\*___LAYOUT___\*\*\*\//g, JSON.stringify(state.layout));
        component = component.replace(/\/\*\*\*___STYLES___\*\*\*\//g, JSON.stringify(state.styles));
        component = component.replace(/\/\*\*\*___ROW_HEIGHT___\*\*\*\//g, state.page.row_height);
        component = component.replace(/\/\*\*\*___PAGE_MARGIN_X___\*\*\*\//g, state.page.item_margin_x);
        component = component.replace(/\/\*\*\*___PAGE_MARGIN_Y___\*\*\*\//g, state.page.item_margin_y);
        component = component.replace(/\/\*\*\*___CONTAINER_PADDING_X___\*\*\*\//g, state.page.container_padding_x);
        component = component.replace(/\/\*\*\*___CONTAINER_PADDING_Y___\*\*\*\//g, state.page.container_padding_y);
        fs.writeFileSync(state.projectDir + "/src/components/" + state.page.class_name + ".jsx", component);
        callback(null, state);
    } catch (error) {
        callback(error, state);
    }
}

function installNodePackages(state, callback) {
    console.log("********* Install dependant components node packages *********");
    if (state.componentIds && state.componentIds.length) {
        let query = ""
                + "select distinct p.package_name from component_packages p join ( "
                + " select cd1.dependant_component_id component_id_0,cd1.main_component_id component_id_1,cd2.main_component_id component_id_2,cd3.main_component_id component_id_3,cd4.main_component_id component_id_4,cd5.main_component_id component_id_5 "
                + "  from component_dependencies cd1 "
                + "  left join component_dependencies cd2 on cd2.dependant_component_id = cd1.main_component_id "
                + "  left join component_dependencies cd3 on cd3.dependant_component_id = cd2.main_component_id "
                + "  left join component_dependencies cd4 on cd4.dependant_component_id = cd3.main_component_id "
                + "  left join component_dependencies cd5 on cd5.dependant_component_id = cd4.main_component_id "
                + "  where cd1.dependant_component_id in (" + getInFromArray(state.componentIds) + ") ) cd "
                + " where p.component_id = cd.component_id_0 "
                + "  or p.component_id = cd.component_id_1 "
                + "   or p.component_id = cd.component_id_2 "
                + "   or p.component_id = cd.component_id_3 "
                + "   or p.component_id = cd.component_id_4 "
                + "  or p.component_id = cd.component_id_5";

        process.chdir(state.projectDir);
        state.connection.query(query)
                .then(function(result) {
                    result.forEach(function(packageName) {
                        execSync("npm i " + packageName.package_name,{stdio: 'inherit'});
                    });
                    callback(null, state);
                })
                .catch(function(error) {
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
        execSync("npm run prod",{stdio: 'inherit'});
        callback(null, state);
    } catch (error) {
        callback(error, state);
    }
}

function copyDist(state, callback) {
    console.log("********* Creating distribution *********");
    try {
        let destPath = path.join(PAGES_FINAL_DIRECTORY, "" + state.page.site_id, state.page.langue_code, state.page.variant, state.page.path);
        let srcPath = path.join(state.projectDir, 'dist');
        fs.copySync(srcPath, destPath);
        callback(null, state);
    } catch (error) {
        callback(error, state);
    }
}

function captureImage(state,callback){
    console.log("********* capturing image *********");
    console.log(state.files);
    (async () => {
      const browser = await puppeteer.launch({args: ['--disable-setuid-sandbox', '--no-sandbox']});
      const page = await browser.newPage();     
      page
          .on('console', message =>
            console.log(`${message.type().substr(0, 3).toUpperCase()} ${message.text()}`))
          .on('pageerror', ({ message }) => console.log(message))
          .on('response', response =>
            console.log(`${response.status()} ${response.url()}`))
          .on('requestfailed', request =>
            console.log(`${request.failure().errorText} ${request.url()}`))
      try {
          await page.goto('file://' + state.projectDir + "/dist/index.html");
          if(Array.isArray(state.files)){
              for(var i=0; i < state.files.length; i++){          
                let file = state.files[i];
                let fileLocation = WEBAPP_PATH + "/uploads/" + file.type + "/" + file.path;
                console.log(fileLocation);
                if (file.type === 'js') { 
                    console.log("adding js file",fileLocation);
                    await page.addScriptTag({path: fileLocation});
                } else if (file.type === 'css') {
                    console.log("adding css file",fileLocation);
                    await page.addStyleTag({path: fileLocation});
                }
              }
          }
          
          
          await page.waitForSelector('#____componentParent', {
            visible: true 
          });
          
          /*
          await page.evaluate(() =>
            Boolean(document.querySelector('#____componentParent'))
          );       
          */
          
          async function screenshotDOMElement(elementId, padding = 0) {
              console.log("----here");
              const rect = await page.evaluate(elementId => {
                const element = document.getElementById(elementId).firstChild;
                console.log(element.getBoundingClientRect());
                const {x, y, width, height} = element.getBoundingClientRect();
                return {left: x, top: y, width, height, id: element.id};
              }, elementId);

              console.log(rect);
              if(rect.height && rect.width){
                  return await page.screenshot({
                    path: state.projectDir + '/screenshot.png',
                    clip: {
                      x: rect.left - padding,
                      y: rect.top - padding,
                      width: rect.width + padding * 2,
                      height: rect.height + padding * 2
                    }
                  });
              }
              return null;
            }

          
          await screenshotDOMElement('____componentParent', 0);
          
          const html = await page.content();
          fs.writeFileSync(state.projectDir + '/screenshot.html', html);
          state.html = await page.evaluate(el => el.innerHTML, await page.$('#____componentParent'));
          await browser.close();
          callback(null,state);
      }catch (e) {
          await browser.close();      
        callback(e,state);
      }
    })();
}

function updateHtml(state, callback) {
    console.log("********* Install dependant components node packages *********");
    if (state.html && state.page.page_id) {
        let query = "update pages set dynamic_html = ? where id = ?";                
        
        state.connection.query(query,[state.html,state.page.page_id])
                .then(function(result) {                    
                    callback(null, state);
                })
                .catch(function(error) {
                    callback(error, state);
                });
    } else {
        callback(null, state);
    }
}

function getDBConnection(callback) {
    console.log("********* Getting database connection *********");

    mariadb.createConnection(DB)
            .then(function(connection) {
                callback(null, {connection});
            })
            .catch(function(error) {
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

    state.connection.query('SELECT id AS page_id,package_name,class_name,title,layout,site_id,path,langue_code,variant,row_height,item_margin_x,item_margin_y,container_padding_x,container_padding_y FROM pages WHERE id = ?', [process.argv[2]])
            .then(function(result) {
                if (result && result.length && result[0]) {
                    state.page = result[0];
                    callback(null, state);
                } else {
                    callback("No page found", state);
                }
            })
            .catch(function(error) {
                callback(error, state);
            })
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
                writeIndexJS,
                writeIndexHTML,
                copyPageComponents,
                copyDependantComponents,
                getPageItems,
                getPageInitUrls,
                getRender,
                writeMainComponent,
                installNodePackages,
                createDist,
                captureImage,
                updateHtml
            ],
            function(error, state) {
                cleanup(state);
                if (error) {
                    console.error(error);
                    process.exit(1);
                } else {
                    process.exit(0);
                }
            });
}