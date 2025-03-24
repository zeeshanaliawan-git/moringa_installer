const puppeteer = require('puppeteer');
const execSync = require('child_process').execSync;
const fs = require('fs-extra');

const files = [
  {
    id: 51,
    type: 'js',
    path: 'jquery-3.4.1.min.js',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'head'
  },
  {
    id: 34,
    type: 'css',
    path: 'bootstrap.min.css',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'head'
  },
  {
    id: 44,
    type: 'css',
    path: 'normalize.min.css',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'head'
  },
  {
    id: 40,
    type: 'css',
    path: 'jquery-ui-1.8.19.custom.css',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'head'
  },
  {
    id: 38,
    type: 'css',
    path: 'crm_react.css',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'head'
  },
  {
    id: 37,
    type: 'css',
    path: 'cem_oml_menu.css',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'head'
  },
  {
    id: 39,
    type: 'css',
    path: 'jquery.json-viewer.css',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'head'
  },
  {
    id: 1,
    type: 'css',
    path: 'boosted.min.css',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'head'
  },
  {
    id: 31,
    type: 'css',
    path: 'all.css',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'head'
  },
  {
    id: 45,
    type: 'css',
    path: 'fontawesome.css',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'head'
  },
  {
    id: 41,
    type: 'css',
    path: 'Myboosted.css',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'head'
  },
  {
    id: 33,
    type: 'js',
    path: 'boosted.bundle.min.js',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'head'
  },
  {
    id: 35,
    type: 'css',
    path: 'bootstrap-toggle.min.css',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'head'
  },
  {
    id: 36,
    type: 'js',
    path: 'bootstrap-toggle.min.js',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'head'
  },
  {
    id: 32,
    type: 'js',
    path: 'all.js',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'head'
  },
  {
    id: 43,
    type: 'js',
    path: 'tarteaucitron.js',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'head'
  },
  {
    id: 47,
    type: 'js',
    path: 'popper.min.js',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'body'
  },
  {
    id: 49,
    type: 'js',
    path: 'bootstrap.min.js',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'body'
  },
  {
    id: 48,
    type: 'js',
    path: 'boosted.js',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'body'
  },
  {
    id: 11,
    type: 'js',
    path: 'boosted.min.js',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'body'
  },
  {
    id: 46,
    type: 'js',
    path: 'bootstrap.bundle.min.js',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'body'
  },
  {
    id: 55,
    type: 'css',
    path: 'swiper-small.css',
    location: 'local',
    integrity: '',
    crossorigin: '',
    include_location: 'body'
  }
];

const WEBAPP_PATH = '/home/amea/tomcat/webapps/crm_pages';

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
                    path: state.projectDir + '/page.png',
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

          
          //await screenshotDOMElement('____componentParent', 0);
          
          const html = await page.content();
          fs.writeFileSync(state.projectDir + '/page.html', html);
          state.html = await page.evaluate(el => el.innerHTML, await page.$('#____componentParent'));
          await browser.close();
          callback(null,state);
      }catch (e) {
        await browser.close();      
        callback(e,state);
      }
    })();
}

function createDist(state, callback) {
    console.log("********* Creating distribution *********");
    try {
        process.chdir(state.projectDir);
        execSync("npm run dev",{stdio: 'inherit'});
        callback(null, state);
    } catch (error) {
        callback(error, state);
    }
}

createDist({files,projectDir:"/home/amea/pjt/crm_engines/pages/compiler/pages_images/32/crm"},function(error,state){
  if(error)console.log(error);
  else{
    captureImage(state,function(error,state){
      if(error)console.log(error);
      console.log(state.html);
    });
  }
});


