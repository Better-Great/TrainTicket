/**
 * Data access for ts-ticket-office-service.
 * Modes:
 *   - mysql (default): TICKET_OFFICE_MYSQL_* required
 *   - file: TICKET_OFFICE_DATA_MODE=file — uses bin/office.json (no MySQL)
 */

var fs = require('fs')
var path = require('path')

var MODE = (process.env.TICKET_OFFICE_DATA_MODE || 'mysql').toLowerCase()
var officeFile = path.join(__dirname, 'office.json')
var fileStore = null
var pool = null

function loadFileStore() {
  if (fileStore) return fileStore
  fileStore = JSON.parse(fs.readFileSync(officeFile, 'utf8'))
  return fileStore
}

function initMysqlMode(callback) {
  var REQUIRED_MYSQL = [
    'TICKET_OFFICE_MYSQL_HOST',
    'TICKET_OFFICE_MYSQL_PORT',
    'TICKET_OFFICE_MYSQL_USER',
    'TICKET_OFFICE_MYSQL_PASSWORD',
    'TICKET_OFFICE_MYSQL_DATABASE',
  ]
  var missing = REQUIRED_MYSQL.filter(function (name) {
    var v = process.env[name]
    return v === undefined || String(v).trim() === ''
  })
  if (missing.length) {
    console.error('[ts-ticket-office-service] Missing required environment variables:')
    missing.forEach(function (m) {
      console.error('  - ' + m)
    })
    callback({ ok: false })
    return
  }

  var HOST = process.env.TICKET_OFFICE_MYSQL_HOST
  var PORT = parseInt(process.env.TICKET_OFFICE_MYSQL_PORT, 10)
  if (isNaN(PORT)) {
    console.error('TICKET_OFFICE_MYSQL_PORT must be a number.')
    callback({ ok: false })
    return
  }
  var USER = process.env.TICKET_OFFICE_MYSQL_USER
  var PASSWORD = process.env.TICKET_OFFICE_MYSQL_PASSWORD
  var DATABASE = process.env.TICKET_OFFICE_MYSQL_DATABASE

  console.log(
    '[ts-ticket-office-service] MySQL:',
    USER + '@' + HOST + ':' + PORT + '/' + DATABASE,
  )

  pool = require('mysql').createPool({
    host: HOST,
    port: PORT,
    user: USER,
    password: PASSWORD,
    database: DATABASE,
    connectionLimit: 5,
  })

  pool.query('SELECT 1', function (err) {
    if (err) {
      console.error('MySQL connection error:', err.message || err)
      callback({ ok: false })
      return
    }
    console.log('Database connection verified')
    callback({ ok: true })
  })
}

exports.initMysql = function (callback) {
  if (MODE === 'file') {
    try {
      loadFileStore()
      console.log('[ts-ticket-office-service] DATA_MODE=file using', officeFile)
      callback({ ok: true })
    } catch (e) {
      console.error('Failed to load office.json:', e.message || e)
      callback({ ok: false })
    }
    return
  }
  initMysqlMode(callback)
}

exports.getAll = function (callback) {
  if (MODE === 'file') {
    callback(loadFileStore())
    return
  }
  pool.query('SELECT * FROM office', function (err, result) {
    if (err) throw err
    callback(result)
  })
}

exports.getSpecificOffices = function (province, city, region, callback) {
  if (MODE === 'file') {
    var rows = loadFileStore().filter(function (row) {
      return row.province === province && row.city === city && row.region === region
    })
    var offices = []
    rows.forEach(function (row) {
      ;(row.offices || []).forEach(function (o) {
        offices.push(o)
      })
    })
    callback(offices)
    return
  }
  var sql =
    'SELECT * FROM office WHERE province = ? AND city = ? AND region = ?'
  pool.query(sql, [province, city, region], function (err, result) {
    if (err) throw err
    callback(result)
  })
}

exports.addOffice = function (province, city, region, office, callback) {
  if (MODE === 'file') {
    var store = loadFileStore()
    var row = store.find(function (r) {
      return r.province === province && r.city === city && r.region === region
    })
    if (!row) {
      row = { province: province, city: city, region: region, offices: [] }
      store.push(row)
    }
    row.offices = row.offices || []
    row.offices.push({
      officeName: office.name || office.officeName,
      address: office.address,
      workTime: office.workTime,
      windowNum: office.windowNum,
    })
    fs.writeFileSync(officeFile, JSON.stringify(store, null, 2))
    callback('insert succeed.')
    return
  }
  var values = [
    office.name,
    city,
    province,
    region,
    office.address,
    office.workTime,
    office.windowNum,
  ]
  pool.query(
    'INSERT INTO office (name, city, province, region, address, workTime, windowNum) VALUES (?,?,?,?,?,?,?)',
    values,
    function (err) {
      if (err) throw err
      callback('insert succeed.')
    },
  )
}

exports.deleteOffice = function (province, city, region, officeName, callback) {
  if (MODE === 'file') {
    var store = loadFileStore()
    store.forEach(function (row) {
      if (row.province === province && row.city === city && row.region === region) {
        row.offices = (row.offices || []).filter(function (o) {
          return o.officeName !== officeName
        })
      }
    })
    fs.writeFileSync(officeFile, JSON.stringify(store, null, 2))
    callback({ affectedRows: 1 })
    return
  }
  pool.query(
    'DELETE FROM office WHERE name = ? AND province = ? AND city = ? AND region = ?',
    [officeName, province, city, region],
    function (err, result) {
      if (err) throw err
      callback(result)
    },
  )
}

exports.updateOffice = function (province, city, region, oldOfficeName, newOffice, callback) {
  if (MODE === 'file') {
    var store = loadFileStore()
    store.forEach(function (row) {
      if (row.province === province && row.city === city && row.region === region) {
        ;(row.offices || []).forEach(function (o) {
          if (o.officeName === oldOfficeName) {
            o.officeName = newOffice.name || newOffice.officeName
            o.address = newOffice.address
            o.workTime = newOffice.workTime
            o.windowNum = newOffice.windowNum
          }
        })
      }
    })
    fs.writeFileSync(officeFile, JSON.stringify(store, null, 2))
    callback({ affectedRows: 1 })
    return
  }
  pool.query(
    'UPDATE office SET name = ?, address = ?, workTime = ?, windowNum = ? WHERE name = ? AND province = ? AND city = ? AND region = ?',
    [
      newOffice.name,
      newOffice.address,
      newOffice.workTime,
      newOffice.windowNum,
      oldOfficeName,
      province,
      city,
      region,
    ],
    function (err, result) {
      if (err) throw err
      callback(result)
    },
  )
}
