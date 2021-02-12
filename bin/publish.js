process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

const axios = require("axios");
const fs = require("fs");
const yaml = require("js-yaml");
const https = require("https");

const API_KEY = process.env.SWAGGERHUB_KEY;

const openAPIPath = "./yaml-resolved/swagger.yaml";
const owner = "SmartBear_Org";
const api = "Book";
const version = getVersion();

const PUBLISH_URL = `https://swaggerhub.mwhiggins.com/v1/apis/${owner}/${api}/${version}/settings/lifecycle?force=false`;
const MARK_DEFAULT_URL = `https://swaggerhub.mwhiggins.com/v1/apis/${owner}/${api}/settings/default`;

function getVersion() {
  const doc = yaml.safeLoad(fs.readFileSync(openAPIPath, "utf8"));
  return doc.info.version;
}

async function publish() {
  const instance = axios.create({
    httpsAgent: new https.Agent({  
      rejectUnauthorized: false
    })
  });
  
  try {
    // Publish
    console.log(`Publishing ${version}`);
    await instance({
      url: PUBLISH_URL,
      method: "PUT",
      headers: {
        authorization: API_KEY,
        "Content-Type": "application/json",
      },
      data: {
        published: true,
      },
    });

    console.log(`Marking ${version} as default`);
    await instance({
      url: MARK_DEFAULT_URL,
      method: "PUT",
      headers: {
        authorization: API_KEY,
        "Content-Type": "application/json",
      },
      data: {
        version,
      },
    });
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
  console.log("Complete!");
}

(async function () {
  await publish();
})();
