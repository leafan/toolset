// init a user and a collection.

db = db.getSiblingDB("admin");
db.createUser({user: "root",pwd: "root123456",roles: [ { role: "root", db: "admin" } ]})


db.auth("root", "root123456");
db = db.getSiblingDB("info");
db.createUser({
    user: "user",
    pwd: "user123456",
    roles: [ { role: "readWrite", db: "info"} ]
});


db.createCollection("info");

// db.info.createIndex({number:-1})
// db.info.createIndex({timestamp:-1})
// db.info.createIndex({miner:-1})
// db.info.createIndex({hash:-1},{unique:true})
