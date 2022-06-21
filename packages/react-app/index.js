const basePath = process.cwd();
const { startCreating, buildSetup } = require(`${basePath}/src/main.js`);

(() => {
  buildSetup();
  startCreating();
})();


// const fs = require("fs");
// const path = require("path");
// const basePath = process.cwd();
// const parentDir = path;
// const newPath = path.join(path.basename(path.dirname(basePath)), '..', 'node_modules');
// console.log(`${path.basename(path.dirname(basePath))}/node_modules/sha1`);
// console.log(newPath);

