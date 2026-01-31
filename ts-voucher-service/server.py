#coding:utf-8
import os

from dotenv import load_dotenv
load_dotenv()

import tornado.ioloop
import tornado.web
import json
import pymysql
import urllib
import urllib.request

mysql_config = {}

class GetVoucherHandler(tornado.web.RequestHandler):

    def post(self, *args, **kwargs):
        #Analyze the data transferred: order id and model indicator (0 stands for ordinary, 1 stands for bullet trains and high-speed trains)
        data = json.loads(self.request.body)
        orderId = data["orderId"]
        type = data["type"]
        #Query for the existence of a corresponding credential based on the order id
        queryVoucher = self.fetchVoucherByOrderId(orderId)

        if(queryVoucher == None):
            #Request the order details based on the order id
            orderResult = self.queryOrderByIdAndType(orderId,type)
            order = orderResult['data']

            # jsonStr = json.dumps(orderResult)
            # self.write(jsonStr)

            #Insert vouchers table into a voucher
            global mysql_config
            conn = pymysql.connect(**mysql_config)
            cur = conn.cursor()
            #Insert statement
            sql = 'INSERT INTO voucher (order_id,travelDate,travelTime,contactName,trainNumber,seatClass,seatNumber,startStation,destStation,price)VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)'
            try:
                cur.execute(sql,(order['id'],order['travelDate'],order['travelTime'],order['contactsName'],order['trainNumber'],order['seatClass'],order['seatNumber'],order['from'],order['to'],order['price']))
                conn.commit()
            finally:
                conn.close()
            #Query again to get the credential information just inserted
            self.write(self.fetchVoucherByOrderId(orderId))
        else:
            self.write(queryVoucher)

    def queryOrderByIdAndType(self,orderId,type):
        # Because nacos-sdk-python does not support nacos 2.x yet, we still use environment variables
        # to set order-service url.
        type = int(type)
        #ordinary train
        order_url = 'http://ts-order-service:12031'
        order_other_url = 'http://ts-order-other-service:12032'
        if(os.getenv("ORDER_SERVICE_URL") is not None):
            order_url = os.getenv("ORDER_SERVICE_URL")

        if(os.getenv("ORDER_OTHER_SERVICE_URL") is not None):
            order_other_url = os.getenv("ORDER_OTHER_SERVICE_URL")

        if(type == 0):
            url=order_other_url + '/api/v1/orderOtherService/orderOther/' + orderId
        else:
            url=order_url + '/api/v1/orderservice/order/'+orderId
        header_dict = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko',"Content-Type": "application/json"}
        req = urllib.request.Request(url=url,headers=header_dict)# Generate the full data for the page request
        response = urllib.request.urlopen(req)# Send page request
        return json.loads(response.read())# Gets the page information returned by the server

    def fetchVoucherByOrderId(self,orderId):
        #Check the voucher for reimbursement for orderId from the voucher table
        global mysql_config
        conn = pymysql.connect(**mysql_config)
        cur = conn.cursor()
        #query statement
        sql = 'SELECT * FROM voucher where order_id = %s'
        try:
            cur.execute(sql,(orderId))
            voucher = cur.fetchone()
            conn.commit()
            #Build return data
            if(cur.rowcount < 1):
                return None
            else:
                voucherData = {}
                voucherData['voucher_id'] = voucher[0]
                voucherData['order_id'] = voucher[1]
                voucherData['travelDate'] = voucher[2]
                voucherData['contactName'] = voucher[4]
                voucherData['train_number'] = voucher[5]
                voucherData['seat_number'] = voucher[7]
                voucherData['start_station'] = voucher[8]
                voucherData['dest_station'] = voucher[9]
                voucherData['price'] = voucher[10]
                jsonStr = json.dumps(voucherData)
                print(jsonStr)
                return jsonStr
        finally:
            conn.close()

def make_app():
    return tornado.web.Application([
        (r"/getVoucher", GetVoucherHandler)
    ])

def initMysqlConfig():
    global mysql_config
    host = "ts-voucher-mysql"
    port = 3306
    user = "root"
    password = "Abcd1234#"
    db = "ts-voucher-mysql"
    if(os.getenv("VOUCHER_MYSQL_HOST") is not None):
        host = os.getenv("VOUCHER_MYSQL_HOST")
    if(os.getenv("VOUCHER_MYSQL_PORT") is not None):
        port = int(os.getenv("VOUCHER_MYSQL_PORT"))
    if(os.getenv("VOUCHER_MYSQL_USER") is not None):
        user = os.getenv("VOUCHER_MYSQL_USER")
    if(os.getenv("VOUCHER_MYSQL_PASSWORD") is not None):
        password = os.getenv("VOUCHER_MYSQL_PASSWORD")
    if(os.getenv("VOUCHER_MYSQL_DATABASE") is not None):
        db = os.getenv("VOUCHER_MYSQL_DATABASE")

    mysql_config = {
        'host': host,
        'port': port,
        'user': user,
        'password': password,
        'db': db
    }


if __name__ == "__main__":
    # Database schema managed by Liquibase - see liquibase/mysql/ts-voucher/
    initMysqlConfig()
    print("MySQL config:", {k: v for k, v in mysql_config.items() if k != 'password'})
    app = make_app()
    app.listen(16101)
    tornado.ioloop.IOLoop.current().start()


    