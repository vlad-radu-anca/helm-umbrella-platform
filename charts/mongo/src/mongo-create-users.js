// mongosh --verbose --nodb --norc --file mongo-create-users.js
// mongosh --verbose --norc "$mongodbUrl" --file mongo-create-users.js

/*
Example cfg
    {
        "mongoUri": "mongodb://mongo-tenant:27017/?serverSelectionTimeoutMS=4000&replicaSet=rs0",
        "credsDir": "/opt/ems/config/mongo/admin",
        "users": [
            {
                "credsDir": "/opt/ems/config/mongo/spcdb",
                "dbName": "spcdb"
            }
        ],
        "skipUpdate": true
    }
*/
const cfg = readJson("cfg.json");
if(cfg === null) {
    console.log("Configuration file cfg.json missing");
    exit(1);
}

skipConnect = false;
try {
   console.log("Already connected to Mongo db, name:" + db.getName());
   skipConnect = true;
} catch (notconnected) {

}

if(!skipConnect && (cfg.mongoUri === null || cfg.credsDir === null)) {
    console.log("Configuration missing mongoUri or credsDir");
    exit(1);
}

if(cfg.users === null) {
    console.log("Configuration missing users");
    exit(1);
}

skipUpdate = true;
if(cfg.skipUdpate != null)
    skipUpdate = cfg.skipUdpate;

connUser = cfg.credsUsername;
connPassword = readFile(cfg.credsDir + "/" + "mongodb-root-password");

if(skipConnect || (connUser !== null && connPassword !== null)) {
    if(!skipConnect) {
        console.log("Connecting to Mongo db:" + cfg.mongoUri);
        db = connect(cfg.mongoUri, connUser, connPassword);
        console.log("Connected to Mongo db, name:" + db.getName());
    }
    console.log("Reading mongo user credentials from filesystem");
    for(i in cfg.users) {
        user = cfg.users[i];
        if(user.credsDir !== null && user.dbName !== null) {
            console.log("Processing user[" + i + "] from " + user.credsDir + " for database: " + user.dbName);
            userName = readFile(user.credsDir + "/" + "mongo-username");
            password = readFile(user.credsDir + "/" + "mongo-password");
            if(userName !== null && password !== null) {
                createUser(db, user.dbName, userName, password, "readWrite", !skipUpdate);
            } else {
                console.log("Skipping user[" + i + "] from " + user.credsDir + ", mongo-username or mongo-password not found");
            }
        } else {
                console.log("Skipping user[" + i + "], no credsDir or dbName specified");
        }
    }
} else {
    console.log("Cannot connect to mongo, mongo-username or mongo-password not found in " + cfg.credsDir);
    exit(2);
}

function readJson(fileName) {
    jsonFile = readFile(fileName)
    if (jsonFile === null){
        return null;
    }
    return JSON.parse(jsonFile);
}

function readFile(fileName) {
    var fs = require("fs");
    if(fs.existsSync(fileName)){
        console.log("Reading file " + fileName);
        var text = fs.readFileSync(fileName, "utf-8");
        return text;
    }
    console.log("File " + fileName + " does not exist");
    return null;
}

function createUser(db, dbName, user, password, role, updateIfExists){
    sdb = db.getSiblingDB(dbName);
    if(sdb.getUser(user) == null){
        sdb.createUser(
          {
	        user: user, 
	        pwd: password, 
	        roles: [
		        {role: role, db: dbName}
            ]
          }
        )
        console.log("User " + user + " in " + dbName + " created");
    } else if (updateIfExists){
        sdb.changeUserPassword(user, password)
        console.log("User " + user + " in " + dbName + " updated");
    } else {
        console.log("Skipping user " + user + " in " + dbName + ", already exists");
    }
    return db;
}
