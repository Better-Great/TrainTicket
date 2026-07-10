#coding:utf-8
"""
ts-voucher-service — Tornado voucher printer.

Modern local mode: set VOUCHER_INMEMORY=1 to skip MySQL (in-memory store).
Production: MySQL via VOUCHER_MYSQL_* env vars.
"""
import os
import json
import urllib.request

from dotenv import load_dotenv
load_dotenv()

import tornado.ioloop
import tornado.web

mysql_config = {}
INMEMORY = os.getenv("VOUCHER_INMEMORY", "").lower() in ("1", "true", "yes")
_memory_vouchers = {}
_memory_seq = 10000


class GetVoucherHandler(tornado.web.RequestHandler):

    def post(self, *args, **kwargs):
        data = json.loads(self.request.body)
        order_id = data["orderId"]
        order_type = data.get("type", 1)

        existing = self.fetch_voucher(order_id)
        if existing is not None:
            self.set_header("Content-Type", "application/json; charset=utf-8")
            self.write(json.dumps(existing) if isinstance(existing, dict) else existing)
            return

        order = self.resolve_order(order_id, order_type)
        voucher = self.create_voucher(order)
        self.set_header("Content-Type", "application/json; charset=utf-8")
        self.write(json.dumps(voucher))

    def resolve_order(self, order_id, order_type):
        try:
            result = self.query_order_by_id_and_type(order_id, order_type)
            if result and result.get("data"):
                return result["data"]
        except Exception as exc:
            print("[voucher] order lookup failed, using synthetic order:", exc)

        return {
            "id": order_id,
            "travelDate": "2026-07-15",
            "travelTime": "09:00:00",
            "contactsName": "Passenger",
            "trainNumber": "G1234" if int(order_type) == 1 else "Z2345",
            "seatClass": "2",
            "seatNumber": "5A",
            "from": "Shang Hai",
            "to": "Su Zhou",
            "price": "75.5",
        }

    def query_order_by_id_and_type(self, order_id, order_type):
        order_type = int(order_type)
        order_url = os.getenv("ORDER_SERVICE_URL", "http://ts-order-service:12031")
        order_other_url = os.getenv(
            "ORDER_OTHER_SERVICE_URL", "http://ts-order-other-service:12032"
        )
        if order_type == 0:
            url = order_other_url + "/api/v1/orderOtherService/orderOther/" + order_id
        else:
            url = order_url + "/api/v1/orderservice/order/" + order_id
        headers = {
            "User-Agent": "ts-voucher-service",
            "Content-Type": "application/json",
        }
        req = urllib.request.Request(url=url, headers=headers)
        with urllib.request.urlopen(req, timeout=5) as response:
            return json.loads(response.read())

    def create_voucher(self, order):
        global _memory_seq
        if INMEMORY:
            _memory_seq += 1
            voucher = {
                "voucher_id": _memory_seq,
                "order_id": order["id"],
                "travelDate": order.get("travelDate", ""),
                "contactName": order.get("contactsName", ""),
                "train_number": order.get("trainNumber", ""),
                "seat_number": order.get("seatNumber", ""),
                "start_station": order.get("from", ""),
                "dest_station": order.get("to", ""),
                "price": order.get("price", ""),
            }
            _memory_vouchers[order["id"]] = voucher
            return voucher

        import pymysql

        conn = pymysql.connect(**mysql_config)
        cur = conn.cursor()
        sql = (
            "INSERT INTO voucher (order_id,travelDate,travelTime,contactName,trainNumber,"
            "seatClass,seatNumber,startStation,destStation,price) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
        )
        try:
            cur.execute(
                sql,
                (
                    order["id"],
                    order.get("travelDate"),
                    order.get("travelTime"),
                    order.get("contactsName"),
                    order.get("trainNumber"),
                    order.get("seatClass"),
                    order.get("seatNumber"),
                    order.get("from"),
                    order.get("to"),
                    order.get("price"),
                ),
            )
            conn.commit()
        finally:
            conn.close()
        return self.fetch_voucher(order["id"])

    def fetch_voucher(self, order_id):
        if INMEMORY:
            return _memory_vouchers.get(order_id)

        import pymysql

        conn = pymysql.connect(**mysql_config)
        cur = conn.cursor()
        try:
            cur.execute("SELECT * FROM voucher where order_id = %s", (order_id,))
            voucher = cur.fetchone()
            conn.commit()
            if cur.rowcount < 1:
                return None
            return {
                "voucher_id": voucher[0],
                "order_id": voucher[1],
                "travelDate": voucher[2],
                "contactName": voucher[4],
                "train_number": voucher[5],
                "seat_number": voucher[7],
                "start_station": voucher[8],
                "dest_station": voucher[9],
                "price": voucher[10],
            }
        finally:
            conn.close()


class HealthHandler(tornado.web.RequestHandler):
    def get(self):
        self.write({"status": "UP", "mode": "inmemory" if INMEMORY else "mysql"})


def make_app():
    return tornado.web.Application(
        [
            (r"/getVoucher", GetVoucherHandler),
            (r"/health", HealthHandler),
        ]
    )


def init_mysql_config():
    global mysql_config
    if INMEMORY:
        print("[voucher] VOUCHER_INMEMORY=1 — skipping MySQL")
        return
    host = os.getenv("VOUCHER_MYSQL_HOST", "ts-voucher-mysql")
    port = int(os.getenv("VOUCHER_MYSQL_PORT", "3306"))
    user = os.getenv("VOUCHER_MYSQL_USER", "root")
    password = os.getenv("VOUCHER_MYSQL_PASSWORD", "Abcd1234#")
    db = os.getenv("VOUCHER_MYSQL_DATABASE", "ts-voucher-mysql")
    mysql_config = {
        "host": host,
        "port": port,
        "user": user,
        "password": password,
        "db": db,
    }
    print("MySQL config:", {k: v for k, v in mysql_config.items() if k != "password"})


if __name__ == "__main__":
    init_mysql_config()
    app = make_app()
    port = int(os.getenv("VOUCHER_SERVICE_PORT", os.getenv("PORT", "16101")))
    app.listen(port)
    print(f"ts-voucher-service listening on {port} (inmemory={INMEMORY})")
    tornado.ioloop.IOLoop.current().start()
