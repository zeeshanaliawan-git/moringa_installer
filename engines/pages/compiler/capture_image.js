#!/usr/bin/env node

const async1 = require('async');
const mariadb = require('mariadb');
const fs = require('fs-extra');
const execSync = require('child_process').execSync;
const npmAddScript = require('npm-add-script');
const jsdom = require('jsdom').JSDOM;
const path = require('path');
const puppeteer = require('puppeteer');

const constants = require("./constants");

const DB = constants.DATABASE;

const NODE_PATH = constants.PATHS.NODE_PATH;
const COMPILER_DIRECTORY = constants.PATHS.COMPILER_DIRECTORY;
const WORKING_DIRECTORY = COMPILER_DIRECTORY + "/components";
const TEMPLATE_DIRECTORY = COMPILER_DIRECTORY + "/code_template";
const PARENT_CLASS_NAME = "____ComponentParent";
const WEBAPP_PATH = constants.PATHS.WEBAPP_PATH;
const WEBAPP_CONTEXT = constants.PATHS.WEBAPP_CONTEXT;
const COMPONENT_BASE_PATH = WEBAPP_PATH + "/uploads/components";
const COMPONENT_IMG_PATH = WEBAPP_PATH + "/uploads/component_images";
const REACT_BUILDER_CODE_DIRECTORY = COMPILER_DIRECTORY + "/code_template/reactbuilder";

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

function getComponent(state, callback) {
    console.log("********* Getting component from database *********");

    state.connection
        .query('SELECT id AS component_id,name,site_id,file_path FROM components WHERE id = ?', [process.argv[2]])
        .then(function(result) {
            if (result && result.length && result[0]) {                
                state.component = result[0];
                callback(null, state);
            } else {
                callback("No component found", state);
            }
        })
        .catch(function(error) {
            callback(error, state);
        })
}

function setupComponentDirectory(state, callback) {
    console.log("********* Setting up page directory *********");
    try {
        
        let componentId = state.component.component_id;        
        
        var projectDir = WORKING_DIRECTORY + '/' + componentId;        
        var srcDir = projectDir + "/src";
        var componentsDir = srcDir + "/components";

        fs.removeSync(projectDir);        
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
        execSync("npm i webpack-cli --save-dev",{stdio: 'inherit'});
        execSync("npm i html-webpack-plugin html-loader --save-dev",{stdio: 'inherit'});
        execSync("npm i @babel/core babel-loader @babel/preset-env @babel/preset-react --save-dev",{stdio: 'inherit'});
        execSync("npm i @babel/plugin-proposal-class-properties --save-dev",{stdio: 'inherit'});
        execSync("npm i webpack-dev-server --save-dev",{stdio: 'inherit'});
        execSync("npm i react react-dom",{stdio: 'inherit'});
        execSync("npm i style-loader",{stdio: 'inherit'});
        execSync("npm i css-loader",{stdio: 'inherit'});

        npmAddScript({key: "prod", value: "webpack --mode production"});
       
        callback(null, state);
    } catch (error) {
        callback(error, state);
    }
}

function writeIndexJS(state, callback) {
    console.log("********* Writing index JS file *********");
    try {
        fs.writeFileSync(state.projectDir + "/src/index.js", 'import ' + PARENT_CLASS_NAME + ' from "./components/' + PARENT_CLASS_NAME + '.jsx"');
        callback(null, state);
    } catch (error) {
        callback(error, state);
    }
}

function writeIndexHTML(state, callback) {
    console.log("********* Writing index html file *********");

    
    var html = fs.readFileSync(TEMPLATE_DIRECTORY + '/index-template.html', 'utf8');
    var dom = new jsdom(html);
    dom.window.document.head.innerHTML += "<title>" + state.component.name + "</title>";
    fs.writeFileSync(state.projectDir + "/src/index.html", dom.serialize());
    
    let fileQuery = "SELECT f.id, f.type, f.file_name AS path "
                + " , 'local' AS location, '' AS integrity, '' AS crossorigin  "
                + " , MAX(lf.page_position) AS include_location  "
                + " FROM files f  "
                + " JOIN libraries_files lf ON lf.file_id = f.id  "
                + " JOIN libraries l ON l.id = lf.library_id  "
                + " JOIN component_libraries cl ON cl.library_id = l.id  and cl.component_id = ? "                
                + " GROUP BY f.id "
                + " ORDER BY lf.page_position DESC, lf.sort_order ASC";

    state.connection
        .query(fileQuery, [state.component.component_id])
        .then(function(result) {
            state.files = result;                
            callback(null, state);
        })
        .catch(function(error) {
            callback(error, state);
        });
}

function copyPageComponent(state, callback) { 
    try{  
        let component = state.component;
        copyComponent(component.site_id, component.file_path, state.projectDir);
        state.imports = getImport(component.name, "./" + path.basename(component.file_path));
        callback(null, state);
    }catch(error) {
        callback(error, state);
    }
}

function copyDependantComponents(state, callback) {
    console.log("********* Copying dependant components *********");    
    let query = ""
            + " select c.id,c.name,c.file_path from components c join ( "
            + "    select cd1.main_component_id component_id_1,cd2.main_component_id component_id_2,cd3.main_component_id component_id_3,cd4.main_component_id component_id_4,cd5.main_component_id component_id_5 "
            + "    from component_dependencies cd1 "
            + "    left join component_dependencies cd2 on cd2.dependant_component_id = cd1.main_component_id "
            + "    left join component_dependencies cd3 on cd3.dependant_component_id = cd2.main_component_id "
            + "    left join component_dependencies cd4 on cd4.dependant_component_id = cd3.main_component_id "
            + "    left join component_dependencies cd5 on cd5.dependant_component_id = cd4.main_component_id "
            + "    where cd1.dependant_component_id = '" + state.component.component_id + "' ) cd "
            + " where c.id = cd.component_id_1 "
            + "  or c.id = cd.component_id_2 "
            + "  or c.id = cd.component_id_3 "
            + "  or c.id = cd.component_id_4 "
            + "  or c.id = cd.component_id_5 ";

        
    state.connection.query(query)
            .then(function(result) {
                result.forEach(function(component) {
                    copyComponent(state.component.site_id, component.file_path, state.projectDir);
                });
                callback(null, state);
            })
            .catch(function(error) {
                callback(error, state);
            });
}

function getRender(state, callback) {
    console.log("********* Getting render *********");
    try {        
        state.render = "<" + state.component.name + " />";        
        callback(null, state);
    } catch (error) {
        callback(error, state);
    }
}

function writeMainComponent(state, callback) {
    console.log("********* Writing main component *********");
    try {
        var component = fs.readFileSync(TEMPLATE_DIRECTORY + '/component-component-template.jsx', 'utf8');        
        component = component.replace(/\/\*\*\*___IMPORTS___\*\*\*\//g, state.imports);
        component = component.replace(/\/\*\*\*___RENDER___\*\*\*\//g, state.render);        
        fs.writeFileSync(state.projectDir + "/src/components/" + PARENT_CLASS_NAME + ".jsx", component);
        callback(null, state);
    } catch (error) {
        callback(error, state);
    }
}

function installComponentNodePackages(state, callback) {
    console.log("********* Install dependant components node packages *********");
    if (state.component && state.component.component_id) {
        let query = "select package_name from component_packages where component_id = ?";                
        console.log(query);

        process.chdir(state.projectDir);
        state.connection.query(query,[state.component.component_id])
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

function installOtherNodePackages(state, callback) {
    console.log("********* Install dependant components node packages *********");
    if (state.component && state.component.component_id) {
        let query = ""
                + "select distinct p.package_name from component_packages p join ( "
                + " select cd1.dependant_component_id component_id_0,cd1.main_component_id component_id_1,cd2.main_component_id component_id_2,cd3.main_component_id component_id_3,cd4.main_component_id component_id_4,cd5.main_component_id component_id_5 "
                + "  from component_dependencies cd1 "
                + "  left join component_dependencies cd2 on cd2.dependant_component_id = cd1.main_component_id "
                + "  left join component_dependencies cd3 on cd3.dependant_component_id = cd2.main_component_id "
                + "  left join component_dependencies cd4 on cd4.dependant_component_id = cd3.main_component_id "
                + "  left join component_dependencies cd5 on cd5.dependant_component_id = cd4.main_component_id "
                + "  where cd1.dependant_component_id = ? ) cd "
                + " where p.component_id = cd.component_id_0 "
                + "  or p.component_id = cd.component_id_1 "
                + "   or p.component_id = cd.component_id_2 "
                + "   or p.component_id = cd.component_id_3 "
                + "   or p.component_id = cd.component_id_4 "
                + "  or p.component_id = cd.component_id_5";

        console.log(query);

        process.chdir(state.projectDir);
        state.connection.query(query,[state.component.component_id])
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

function updateHtml(state, callback) {
    console.log("********* Install dependant components node packages *********");
    if (state.component && state.component.component_id) {
        let query = "update components set html = ? where id = ?";                
        
        state.connection.query(query,[state.html,state.component.component_id])
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

function captureImage(state,callback){
    console.log("********* capturing image *********");
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
            visible: true,
          });
          
          
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
                    path: COMPONENT_IMG_PATH + '/' + state.component.component_id + '.png',
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
          fs.writeFileSync(COMPONENT_IMG_PATH + '/' + state.component.component_id + '.html', html);
          state.html = await page.evaluate(el => el.innerHTML, await page.$('#____componentParent'));
          await browser.close();
          callback(null,state);
      }catch (e) {
          await browser.close();      
        callback(e,state);
      }
    })();
}

function cleanup(state) {
    console.log("********* Cleaning up *********");

    if (state && state.connection) {
        state.connection.destroy();
    }
}

function copyComponent(siteId, filePath, projectDir) {
    let componentPath = path.join(COMPONENT_BASE_PATH, "" + siteId, filePath);
    fs.copyFileSync(componentPath, projectDir + "/src/components/" + path.basename(filePath));
}



function getImport(name, path) {
    return 'import ' + name + ' from "' + path + '";\n';
}


const argv = process.argv;
if (argv.length != 3) {
    console.log("Usage node capture_image.js component_id");
} else {
    process.env.PATH = NODE_PATH + ":" + process.env.PATH;
    async1.waterfall(
            [
                getDBConnection,
                getComponent,
                setupComponentDirectory,
                setupNode,
                writeIndexJS,
                writeIndexHTML,
                copyPageComponent,
                copyDependantComponents,
                /*getPageItems,*/
                getRender,
                writeMainComponent,
                installComponentNodePackages,
                installOtherNodePackages,
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