/**
 * MySQL pool for ts-ticket-office-service.
 * All connection settings come from the environment (e.g. .env); no defaults in code.
 */

var REQUIRED_MYSQL = [
  'TICKET_OFFICE_MYSQL_HOST',
  'TICKET_OFFICE_MYSQL_PORT',
  'TICKET_OFFICE_MYSQL_USER',
  'TICKET_OFFICE_MYSQL_PASSWORD',
  'TICKET_OFFICE_MYSQL_DATABASE'
];

(function requireMysqlEnv() {
  var missing = REQUIRED_MYSQL.filter(function (name) {
    var v = process.env[name];
    return v === undefined || String(v).trim() === '';
  });
  if (missing.length) {
    console.error('[ts-ticket-office-service] Missing required environment variables:');
    missing.forEach(function (m) {
      console.error('  - ' + m);
    });
    console.error('Copy .env.example to .env and fill in values.');
    process.exit(1);
  }
})();

var HOST = process.env.TICKET_OFFICE_MYSQL_HOST;
var PORT = parseInt(process.env.TICKET_OFFICE_MYSQL_PORT, 10);
if (isNaN(PORT)) {
  console.error('TICKET_OFFICE_MYSQL_PORT must be a number.');
  process.exit(1);
}
var USER = process.env.TICKET_OFFICE_MYSQL_USER;
var PASSWORD = process.env.TICKET_OFFICE_MYSQL_PASSWORD;
var DATABASE = process.env.TICKET_OFFICE_MYSQL_DATABASE;

console.log(
  '[ts-ticket-office-service] MySQL:',
  USER + '@' + HOST + ':' + PORT + '/' + DATABASE
);

var pool = require('mysql').createPool({
    host: HOST,
    port: PORT,
    user: USER,
    password: PASSWORD,
    database: DATABASE,
    connectionLimit: 5
});

var initData = function(callback){
    pool.query("SELECT 1", function (err, result) {
        if (err) {
            console.error("MySQL connection error:", err.message || err);
            callback({ok: false});
            return;
        }
        console.log("Database connection verified");
        callback({ok: true});
    });
};

var getAllOffices = function(db, callback){
    pool.query("SELECT * FROM office", function (err, result, fields) {
        if (err) throw err;
        console.log(result);
        callback(result);
    });
};

/*根据省市区信息获取该地区的代售点列表*/
var getSpecificOffices = function(province, city, region, db, callback){
    var where_sql= "WHERE province = '" + province + "' AND city = '" + city + "' AND region = '" + region + "'";
    var sql = "SELECT * FROM office " + where_sql;
    console.log("getSpecificOffices sql:", sql);
    pool.query(sql, function (err, result, fields) {
        if (err) throw err;
        console.log(result);
        callback(result);
    });
};

/*根据省市区信息添加代售点*/
var addOffice = function(province, city, region, office, db, callback){
    insertEntry(office.name, city, province, region, office.address, office.workTime, office.windowNum);
    callback("insert succeed.")
};

/*根据省市区和代售点名称删除代售点*/
var deleteOffice = function(province, city, region, officeName, db, callback){
    var where_sql= "WHERE name = '" + officeName + "' AND province = '" + province + "' AND city = '" + city + "' AND region = '" + region + "'";
    var sql = "DELETE FROM office " + where_sql;
    pool.query(sql, function (err, result) {
        if (err) throw err;
        console.log("Number of records deleted: " + result.affectedRows);
        callback(result);
    });
};


/*根据省市区代售点信息更新代售点*/
var updateOffice = function(province, city, region, oldOfficeName, newOffice, db, callback){
    var where_sql= "WHERE name = '" + oldOfficeName + "' AND province = '" + province + "' AND city = '" + city + "' AND region = '" + region + "'";
    var set_sql = "SET name = '" + newOffice.name + "', address = '" + newOffice.address + "', workTime = '" + newOffice.workTime + "', windowNum = " + newOffice.windowNum;
    var sql = "UPDATE office " + set_sql + " " + where_sql;
    console.log("update sql:", sql);
    pool.query(sql, function (err, result) {
        if (err) throw err;
        console.log("Number of records updated: " + result.affectedRows);
        callback(result);
    });

};

var insertEntry = function(name, city, province, region, address, workTime, windowNum){
    values = "('" + name + "','" + city +"','" + province + "','" + region +"','"+address +"','"+workTime +"',"+windowNum+")";
    var sql = "INSERT INTO office (name, city, province, region, address, workTime, windowNum)" +
        " VALUES " + values;
    console.log("insert sql", sql);
    pool.query(sql, function (err, result) {
        if (err) throw err;
        console.log("1 record inserted, ", result);
    });
}

exports.initMysql = function(callback){
    initData(function(result){
        if (result.ok) console.log("initMysql connected.");
        callback(result);
    });
};

exports.getAll = function(callback){
    getAllOffices(null, function(result){
        callback(result);
    });
};

exports.getSpecificOffices = function(province, city, region, callback){
    getSpecificOffices(province, city, region, null, function(result){
        callback(result);
    });
};

exports.addOffice = function(province, city, region, office, callback){
    addOffice(province, city, region, office, null, function(result){
        callback(result);
    });
};

exports.deleteOffice = function(province, city, region, officeName, callback){
    deleteOffice(province, city, region, officeName, null, function(result){
        callback(result);
    });
};

exports.updateOffice = function(province, city, region, oldOfficeName, newOffice, callback){
    updateOffice(province, city, region, oldOfficeName, newOffice, null, function(result){
        callback(result);
    });
};
