import {vec2, vec3} from 'gl-matrix';
import * as Stats from 'stats-js';
import * as DAT from 'dat-gui';
import Square from './geometry/Square';
import Plane from './geometry/Plane';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';
import { cpuUsage } from 'process';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 5,
  'Load Scene': loadScene, // A function pointer, essentially
};

let square: Square;
let plane : Plane;
let wPressed: boolean;
let aPressed: boolean;
let sPressed: boolean;
let dPressed: boolean;
let planePos: vec2;

//trying to add GUI elements 
let heightGUI: number;
let biomeGUI: number; 
let opacityGUI: number; 
let grayscaleGUI: boolean; 
let color1: vec3; 
let color2: vec3; 

function loadScene() {
  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();
  plane = new Plane(vec3.fromValues(0,0,0), vec2.fromValues(100,100), 20);
  plane.create();

  wPressed = false;
  aPressed = false;
  sPressed = false;
  dPressed = false;
  planePos = vec2.fromValues(0,0);
}

function main() {
  window.addEventListener('keypress', function (e) {
    // console.log(e.key);
    switch(e.key) {
      case 'w':
      wPressed = true;
      break;
      case 'a':
      aPressed = true;
      break;
      case 's':
      sPressed = true;
      break;
      case 'd':
      dPressed = true;
      break;
    }
  }, false);

  window.addEventListener('keyup', function (e) {
    switch(e.key) {
      case 'w':
      wPressed = false;
      break;
      case 'a':
      aPressed = false;
      break;
      case 's':
      sPressed = false;
      break;
      case 'd':
      dPressed = false;
      break;
    }
  }, false);

  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // Add controls to the gui
  const gui = new DAT.GUI({});

    //for the biome types 
 var bType =
 {
     biomeType: 1,
 }
 var bt = gui.add(bType, 'biomeType', { DreadMountains: 1, CottonCandyHills: 2, FlatWasteLand: 3 } );
 biomeGUI = bType.biomeType; 


    //add controls for height 
  var h = {height: 50}; 
  var h_gui = gui.add(h, 'height', 0, 100); 
  h_gui.onChange = function (newHeight) {
    console.log("Value changed to:  ", newHeight);
    alert("Value changed to:  " + newHeight);
  };
  h_gui.listen(); 
  heightGUI = h.height; 

  //add controls for opacity
  var o = {opacity: 100}; 
  var o_gui = gui.add(o, 'opacity', 0, 100); 
  opacityGUI = 50; //setting this to a diff number so that it changes in the tick loop 


//example for passing through changing values 
//   var person = {
//     name: 'Anne',
//     oldName: 'Anne',
//     setName: function() {
//       var oldName = this.oldName;
//       var newName = this.name;
//       alert('Changing ' + oldName + " to " + newName);
//       this.oldName = this.name;
//     }
// };

// gui.add(person, 'name');
// gui.add(person, 'setName');
//end example  

var gs = {grayscale: true};
var gs_gui = gui.add(gs, 'grayscale', true);
grayscaleGUI = !gs.grayscale; 


  var palette = {
    color1: "#0080ff", 
    color2: "#00ffff"

  };

  color1 = vec3.fromValues(0, 0, 0);
  color2 = vec3.fromValues(0, 0, 0);  


  gui.addColor(palette, 'color1');
  gui.addColor(palette, 'color2');





  // get canvas and webgl context
  const canvas = <HTMLCanvasElement> document.getElementById('canvas');
  const gl = <WebGL2RenderingContext> canvas.getContext('webgl2');
  if (!gl) {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  // Initial call to load scene
  loadScene();

  const camera = new Camera(vec3.fromValues(0, 10, -20), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(164.0 / 255.0, 233.0 / 255.0, 1.0, 1);
  gl.enable(gl.DEPTH_TEST);

  const lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/terrain-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/terrain-frag.glsl')),
  ]);

  const flat = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/flat-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/flat-frag.glsl')),
  ]);

  function processKeyPresses() {
    let velocity: vec2 = vec2.fromValues(0,0);
    if(wPressed) {
      velocity[1] += 1.0;
    }
    if(aPressed) {
      velocity[0] += 1.0;
    }
    if(sPressed) {
      velocity[1] -= 1.0;
    }
    if(dPressed) {
      velocity[0] -= 1.0;
    }
    let newPos: vec2 = vec2.fromValues(0,0);
    vec2.add(newPos, velocity, planePos);
    lambert.setPlanePos(newPos);
    planePos = newPos;
  }

  var hexToRgb = function(hex : string) {
    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
    } : null;
  }

  // This function will be called every frame
  function tick() {
   
    //functions which will update the GUI 
   if (heightGUI != h.height) {
     heightGUI = h.height; 
     lambert.setHeight(heightGUI); 
   }

  if (bType.biomeType != biomeGUI) {
   // console.log(biomeGUI); 
    biomeGUI = bType.biomeType; 
    lambert.setBiomeType(biomeGUI); 
  }

  if (opacityGUI != o.opacity) {
    opacityGUI = o.opacity; 
    lambert.setOpacity(opacityGUI); 
  }

  //check for grayscale 
  if (grayscaleGUI != gs.grayscale) {
    grayscaleGUI = !grayscaleGUI; 
    
    if (grayscaleGUI) {
      //pass in a 1 for true
      lambert.setGrayscale(1);

    } else {
      //pass in a 0 for false 
      lambert.setGrayscale(0); 

    }
    
  } 


  //check for color changing 

 var rgbColor1 = hexToRgb(palette.color1); 
 lambert.setColorOne(vec3.fromValues(rgbColor1.r, rgbColor1.g, rgbColor1.b)); 

 var rgbColor2 = hexToRgb(palette.color2); 
 lambert.setColorTwo(vec3.fromValues(rgbColor2.r, rgbColor2.g, rgbColor2.b)); 

  // if (color1 != vec3.fromValues(palette.color1[0], palette.color1[1], palette.color1[2])) {
  //   //update color1
  //   color1 = vec3.fromValues(palette.color1[0], palette.color1[1], palette.color1[2]); 
    
  //   console.log('x: ' + palette.color1[0] + ', y: ' + palette.color1[1] + ', z: ' + palette.color1[2] + ', w: ' + palette.color1[3]); 
  //   lambert.setColorOne(color1); 
  //   //console.log('color1: '+ color1); 
  //   console.log(color1); 

  // }

  // if (color2 != vec3.fromValues(palette.color2[0], palette.color2[1], palette.color2[2])) {
  //   //update color2
  //   color2 = vec3.fromValues(palette.color2[0], palette.color2[1], palette.color2[2]); 
  //   lambert.setColorTwo(color2); 

  // }

    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();
    processKeyPresses();
    renderer.render(camera, lambert, [
      plane,
    ]);
    renderer.render(camera, flat, [
      square,
    ]);
    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();

  // Start the render loop
  tick();
}

main();
