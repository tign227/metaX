const fs = require("fs");
const path = require("path");

const PATHS = {
  CONFIG: path.join(__dirname, '..', 'config'),
  ADDRESS: path.join(__dirname, '..', 'address')
}


function fromJson(filePath, fileName) {
  const finalFilePath = path.join(filePath, fileName);
  const data = fs.readFileSync(finalFilePath);
  const jsonData = JSON.parse(data);
  return jsonData;
}

function toJson(filePath, data, fileName) {
  const finalFilePath = path.join(filePath, fileName);
  const jsonData = JSON.stringify(data, null, 2);
  try {
    fs.writeFileSync(finalFilePath, jsonData, "utf8");
  } catch (error) {
    console.error(`Error writing: `, error);
  }
}

module.exports = { fromJson, toJson, PATHS };
